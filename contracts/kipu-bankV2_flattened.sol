
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC20.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (utils/introspection/IERC165.sol)

pragma solidity >=0.4.16;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC165.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC165.sol)

pragma solidity >=0.4.16;


// File: @openzeppelin/contracts/interfaces/IERC1363.sol


// OpenZeppelin Contracts (last updated v5.4.0) (interfaces/IERC1363.sol)

pragma solidity >=0.6.2;



/**
 * @title IERC1363
 * @dev Interface of the ERC-1363 standard as defined in the https://eips.ethereum.org/EIPS/eip-1363[ERC-1363].
 *
 * Defines an extension interface for ERC-20 tokens that supports executing code on a recipient contract
 * after `transfer` or `transferFrom`, or code on a spender contract after `approve`, in a single transaction.
 */
interface IERC1363 is IERC20, IERC165 {
    /*
     * Note: the ERC-165 identifier for this interface is 0xb0202a11.
     * 0xb0202a11 ===
     *   bytes4(keccak256('transferAndCall(address,uint256)')) ^
     *   bytes4(keccak256('transferAndCall(address,uint256,bytes)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256)')) ^
     *   bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256)')) ^
     *   bytes4(keccak256('approveAndCall(address,uint256,bytes)'))
     */

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     * @param from The address which you want to send tokens from.
     * @param to The address which you want to transfer to.
     * @param value The amount of tokens to be transferred.
     * @param data Additional data with no specified format, sent in call to `to`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function transferFromAndCall(address from, address to, uint256 value, bytes calldata data) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value) external returns (bool);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     * @param data Additional data with no specified format, sent in call to `spender`.
     * @return A boolean value indicating whether the operation succeeded unless throwing.
     */
    function approveAndCall(address spender, uint256 value, bytes calldata data) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v5.3.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC-20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    /**
     * @dev An operation with an ERC-20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Variant of {safeTransfer} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransfer(IERC20 token, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Variant of {safeTransferFrom} that returns a bool instead of reverting if the operation is not successful.
     */
    function trySafeTransferFrom(IERC20 token, address from, address to, uint256 value) internal returns (bool) {
        return _callOptionalReturnBool(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     *
     * IMPORTANT: If the token implements ERC-7674 (ERC-20 with temporary allowance), and if the "client"
     * smart contract uses ERC-7674 to set temporary allowances, then the "client" smart contract should avoid using
     * this function. Performing a {safeIncreaseAllowance} or {safeDecreaseAllowance} operation on a token contract
     * that has a non-zero temporary allowance (for that particular owner-spender) will result in unexpected behavior.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     *
     * NOTE: If the token implements ERC-7674, this function will not modify any temporary allowance. This function
     * only sets the "standard" allowance. Any temporary allowance will remain active, in addition to the value being
     * set here.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Performs an {ERC1363} transferAndCall, with a fallback to the simple {ERC20} transfer if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            safeTransfer(token, to, value);
        } else if (!token.transferAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} transferFromAndCall, with a fallback to the simple {ERC20} transferFrom if the target
     * has no code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * Reverts if the returned value is other than `true`.
     */
    function transferFromAndCallRelaxed(
        IERC1363 token,
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) internal {
        if (to.code.length == 0) {
            safeTransferFrom(token, from, to, value);
        } else if (!token.transferFromAndCall(from, to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Performs an {ERC1363} approveAndCall, with a fallback to the simple {ERC20} approve if the target has no
     * code. This can be used to implement an {ERC721}-like safe transfer that rely on {ERC1363} checks when
     * targeting contracts.
     *
     * NOTE: When the recipient address (`to`) has no code (i.e. is an EOA), this function behaves as {forceApprove}.
     * Opposedly, when the recipient address (`to`) has code, this function only attempts to call {ERC1363-approveAndCall}
     * once without retrying, and relies on the returned value to be true.
     *
     * Reverts if the returned value is other than `true`.
     */
    function approveAndCallRelaxed(IERC1363 token, address to, uint256 value, bytes memory data) internal {
        if (to.code.length == 0) {
            forceApprove(token, to, value);
        } else if (!token.approveAndCall(to, value, data)) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturnBool} that reverts if call fails to meet the requirements.
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            let success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            // bubble errors
            if iszero(success) {
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
            returnSize := returndatasize()
            returnValue := mload(0)
        }

        if (returnSize == 0 ? address(token).code.length == 0 : returnValue != 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silently catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly ("memory-safe") {
            success := call(gas(), token, 0, add(data, 0x20), mload(data), 0, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0)
        }
        return success && (returnSize == 0 ? address(token).code.length > 0 : returnValue == 1);
    }
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

// File: contracts/kipu-bankV2.sol


pragma solidity 0.8.30;





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