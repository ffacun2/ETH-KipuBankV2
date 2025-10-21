// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title Contrato bancario
 * @author Facundo Criado
*/
contract KipuBank is Ownable {

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                            DECLARACIONES DE TIPOS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Configuracion para cada token permitido en el banco.
     * @param priceFeed La direccion del oraculo de Chainlink.
     * @param decimals Los decimales del token.
     */
    struct TokenConfig {
        address priceFeed;
        uint8 decimals;
    }

    /*//////////////////////////////////////////////////////////////
                            VARIABLES CONSTANT
    //////////////////////////////////////////////////////////////*/

    /// @notice Direccion reservada para representar Ether nativo.
    address public constant ETH_ADDRESS = address(0);

    /// @notice Los decimales estandar para los precios en USD de Chainlink.
    uint8 public constant USD_DECIMALS = 8;

    /// @notice Precision para calculos con USD (10**8).
    uint256 public constant USD_PRECISION = 10**USD_DECIMALS;

    /*//////////////////////////////////////////////////////////////
                            VARIABLES DE ESTADO
    //////////////////////////////////////////////////////////////*/

    /// @notice Limite de capitalizacion del banco en USD (con 8 decimales).
    uint256 public immutable i_bankCapUSD;

    /// @notice Limite de retiro por transaccion en USD (con 8 decimales).
    uint256 public immutable i_withdrawalLimitUSD;

    /// @notice Valor total de todos los activos en el banco, en USD (con 8 decimales).
    uint256 public s_totalBankValueUSD;

    /// @notice Cantidad de depositos que se realizaron en el contrato.
    uint256 public s_depositCount; 

    /// @notice Cantidad de retiros que se realizaron en el contrato.
    uint256 public s_withdrawalCount; 

    /// @notice Mapping anidado para la contabilidad multi-token.
    /// @dev (tokenAddress => userAddress => balance)
    mapping(address => mapping(address => uint256)) public s_balances;

    /// @notice Mapping para almacenar la configuracion (price feed y decimales) de cada token permitido.
    mapping(address => TokenConfig) public s_tokenConfig;

    /*//////////////////////////////////////////////////////////////
                                EVENTOS
    //////////////////////////////////////////////////////////////*/

    event Deposited(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 valueUSD
    );
    event Withdrawn(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 valueUSD
    );
    event TokenAllowed(
        address indexed token,
        address indexed priceFeed,
        uint8 decimals
    );
    event TokenPriceFeedUpdated(
        address indexed token,
        address indexed newPriceFeed
    );

    /*//////////////////////////////////////////////////////////////
                                ERRORES
    //////////////////////////////////////////////////////////////*/

    error KipuBank__ZeroAmount();
    error KipuBank__TokenNotAllowed(address token);
    error KipuBank__InvalidPriceFeed(address priceFeed);
    error KipuBank__BankCapExceeded(
        uint256 currentBalanceUSD,
        uint256 depositValueUSD,
        uint256 capUSD
    );
    error KipuBank__WithdrawLimitExceeded(
        uint256 withdrawValueUSD,
        uint256 limitUSD
    );
    error KipuBank__InsufficientBalance(
        uint256 requiredAmount,
        uint256 availableAmount
    );
    error KipuBank__TransferFailed();
    error KipuBank__MustUseDepositEth();
    error KipuBank__FallbackNotAllowed();

    /*//////////////////////////////////////////////////////////////
                            MODIFICADORES
    //////////////////////////////////////////////////////////////*/

    /// @dev Modificador que asegura que el valor del parametro no es cero.
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) revert KipuBank__ZeroAmount();
        _;
    }

    /// @dev Modificador que asegura que el msg.value no es cero.
    modifier nonZeroValue() {
        if (msg.value == 0) revert KipuBank__ZeroAmount();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @param _bankCapUSD Limite de capitalizacion del banco en USD.
     * @param _withdrawalLimitUSD Limite de retiro por tx en USD.
     * @param _ethUsdPriceFeed Direccion del oraculo ETH/USD de Chainlink.
     */
    constructor(
        uint256 _bankCapUSD,
        uint256 _withdrawalLimitUSD,
        address _ethUsdPriceFeed
    ) Ownable(msg.sender) {
        if (_ethUsdPriceFeed == address(0)) {
            revert KipuBank__InvalidPriceFeed(_ethUsdPriceFeed);
        }

        i_bankCapUSD = _bankCapUSD;
        i_withdrawalLimitUSD = _withdrawalLimitUSD;

        // Configurar ETH como primer token permitido
        s_tokenConfig[ETH_ADDRESS] = TokenConfig({
            priceFeed: _ethUsdPriceFeed,
            decimals: 18 // ETH siempre tiene 18 decimales
        });
        emit TokenAllowed(ETH_ADDRESS, _ethUsdPriceFeed, 18);
    }

    /*//////////////////////////////////////////////////////////////
                            FUNCIONES CORE
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Permite a un usuario depositar Ether nativo.
     * @dev Usa `msg.value` como la cantidad a depositar.
     */
    function depositEth() external payable nonZeroValue { 
        _handleDeposit(ETH_ADDRESS, msg.value);
    }

    /**
     * @notice Permite a un usuario depositar tokens ERC-20 permitidos.
     * @dev El usuario debe haber aprobado al contrato previamente.
     * @param _token La direccion del contrato ERC-20.
     * @param _amount La cantidad de tokens a depositar (en la unidad mas pequeña del token).
     */
    function depositToken(address _token, uint256 _amount) external nonZeroAmount(_amount) { 
        if (_token == ETH_ADDRESS) revert KipuBank__MustUseDepositEth();
        _handleDeposit(_token, _amount);
    }

    /**
     * @notice Logica interna unificada para depositos.
     */
    function _handleDeposit(address _token, uint256 _amount) private {
        // --- Checks ---
        // El check de ZeroAmount es manejado por los modificadores en las funciones públicas
        _checkTokenAllowed(_token);

        uint256 depositValueUSD = getTokenValueUSD(_token, _amount);
        uint256 newTotalBankValueUSD = s_totalBankValueUSD + depositValueUSD;

        if (newTotalBankValueUSD > i_bankCapUSD) {
            revert KipuBank__BankCapExceeded(
                s_totalBankValueUSD,
                depositValueUSD,
                i_bankCapUSD
            );
        }

        // --- Effects ---
        s_balances[_token][msg.sender] += _amount;
        s_totalBankValueUSD = newTotalBankValueUSD;
        s_depositCount++; // <- AÑADIDO (Requisito Examen)

        // --- Interactions ---
        if (_token != ETH_ADDRESS) {
            IERC20(_token).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        emit Deposited(msg.sender, _token, _amount, depositValueUSD);
    }

    /**
     * @notice Permite a un usuario retirar sus fondos (Ether o ERC-20).
     * @param _token La direccion del token a retirar (usar `address(0)` para ETH).
     * @param _amount La cantidad a retirar (en la unidad mas pequeña del token).
     */
    function withdraw(address _token, uint256 _amount) external nonZeroAmount(_amount) {
        // --- Checks ---
        // El check de ZeroAmount es manejado por el modificador
        _checkTokenAllowed(_token);

        uint256 userBalance = s_balances[_token][msg.sender];
        if (_amount > userBalance) {
            revert KipuBank__InsufficientBalance(_amount, userBalance);
        }

        uint256 withdrawValueUSD = getTokenValueUSD(_token, _amount);
        if (withdrawValueUSD > i_withdrawalLimitUSD) {
            revert KipuBank__WithdrawLimitExceeded(
                withdrawValueUSD,
                i_withdrawalLimitUSD
            );
        }

        // --- Effects (Checks-Effects-Interactions) ---
        s_balances[_token][msg.sender] = userBalance - _amount;
        s_totalBankValueUSD -= withdrawValueUSD;
        s_withdrawalCount++; 

        // --- Interactions ---
        if (_token == ETH_ADDRESS) {
            (bool success, ) = msg.sender.call{value: _amount}("");
            if (!success) revert KipuBank__TransferFailed();
        } else {
            IERC20(_token).safeTransfer(msg.sender, _amount);
        }

        emit Withdrawn(msg.sender, _token, _amount, withdrawValueUSD);
    }

    /*//////////////////////////////////////////////////////////////
                        FUNCIONES DE CONVERSIÓN Y VISTA
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Funcion de conversion de valor. Obtiene el valor en USD de una cantidad de token.
     * @param _token La direccion del token.
     * @param _amount La cantidad del token.
     * @return valueUSD El valor equivalente en USD (con 8 decimales).
     */
    function getTokenValueUSD(
        address _token,
        uint256 _amount
    ) public view returns (uint256) {
        if (_amount == 0) return 0;

        TokenConfig memory config = s_tokenConfig[_token];
        if (config.priceFeed == address(0)) {
            revert KipuBank__TokenNotAllowed(_token);
        }

        // 1. Obtener el precio del oraculo
        AggregatorV3Interface priceFeed = AggregatorV3Interface(config.priceFeed);
        (, int256 price, , , ) = priceFeed.latestRoundData(); // Precio tiene 8 decimales

        // 2. Convertir
        // (amount * price) / 10**tokenDecimals
        // El resultado ya queda expresado en USD con 8 decimales.
        return
            (_amount * uint256(price)) / (10**uint256(config.decimals));
    }

    /**
     * @notice Obtiene el saldo de un usuario para un token especifico.
     */
    function getBalance(
        address _token,
        address _user
    ) external view returns (uint256) {
        return s_balances[_token][_user];
    }

    /**
     * @notice Obtiene la configuracion de un token permitido.
     */
    function getTokenConfig(
        address _token
    ) external view returns (TokenConfig memory) {
        return s_tokenConfig[_token];
    }

    /*//////////////////////////////////////////////////////////////
                        FUNCIONES DE CONTROL DE ACCESO
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice (Owner) Permite un nuevo token ERC-20 en el banco.
     * @param _token La direccion del contrato ERC-20.
     * @param _priceFeed La direccion del oraculo de precio.
     * @param _decimals Los decimales del token.
     */
    function allowToken(
        address _token,
        address _priceFeed,
        uint8 _decimals
    ) external onlyOwner {
        if (_token == ETH_ADDRESS) revert KipuBank__TokenNotAllowed(_token);
        if (_priceFeed == address(0)) {
            revert KipuBank__InvalidPriceFeed(_priceFeed);
        }

        s_tokenConfig[_token] = TokenConfig({
            priceFeed: _priceFeed,
            decimals: _decimals
        });
        emit TokenAllowed(_token, _priceFeed, _decimals);
    }

    /**
     * @notice (Owner) Actualiza el oraculo de un token.
     */
    function updateTokenPriceFeed(
        address _token,
        address _newPriceFeed
    ) external onlyOwner {
        _checkTokenAllowed(_token);
        if (_newPriceFeed == address(0)) {
            revert KipuBank__InvalidPriceFeed(_newPriceFeed);
        }

        s_tokenConfig[_token].priceFeed = _newPriceFeed;
        emit TokenPriceFeedUpdated(_token, _newPriceFeed);
    }

    /**
     * @notice (Owner) Permite retirar fondos de emergencia.
     * @dev No actualiza `s_totalBankValueUSD` intencionalmente, ya que es una funcion de emergencia.
     */
    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner {
        if (_token == ETH_ADDRESS) {
            (bool success, ) = msg.sender.call{value: _amount}("");
            if (!success) revert KipuBank__TransferFailed();
        } else {
            IERC20(_token).safeTransfer(msg.sender, _amount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            HELPERS INTERNOS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Revisa si un token esta permitido (tiene un oraculo configurado).
     */
    function _checkTokenAllowed(address _token) private view {
        if (s_tokenConfig[_token].priceFeed == address(0)) {
            revert KipuBank__TokenNotAllowed(_token);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            RECEIVE / FALLBACK
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Permite depositos de ETH directos (sin llamar a `depositEth`).
     */
    receive() external payable nonZeroValue { 
        _handleDeposit(ETH_ADDRESS, msg.value);
    }

    /**
     * @notice Rechaza cualquier llamada a funcion desconocida.
     */
    fallback() external payable {
        revert KipuBank__FallbackNotAllowed();
    }
}