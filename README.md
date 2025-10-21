# KipuBankV2

Este repositorio contiene la Versión 2 del contrato inteligente `KipuBank`, una refactorización y extensión significativa del contrato original. El objetivo es mover el contrato hacia un estándar más cercano a producción, introduciendo soporte multi-token (ERC-20 y ETH), control de acceso, y límites de capitalización basados en el valor de mercado en USD, utilizando Oráculos de Chainlink.

## Mejoras Realizadas 

La V2 introduce cambios fundamentales para hacer el banco más robusto, seguro y funcional:

1.  **Soporte Multi-Token (ERC-20 y ETH):**
    * **V1:** Solo aceptaba Ether (ETH).
    * **V2:** Acepta ETH (representado por `address(0)`) y cualquier token ERC-20 que el *owner* del contrato decida "permitir" (`allowToken`).

2.  **Contabilidad Interna (Mappings Anidados):**
    * **V1:** Usaba un mapping simple: `mapping(address => uint256) s_balance`.
    * **V2:** Usa un mapping anidado: `mapping(address token => mapping(address user => uint256)) s_balances`. Esto permite al contrato rastrear el saldo de *cada* token para *cada* usuario de forma independiente.

3.  **Límites Basados en USD (Integración con Oráculos):**
    * **V1:** Los límites (`i_bankCapLimit`, `i_withdrawalLimit`) estaban definidos en `wei` (ETH). Esto es volátil; $1M en ETH hoy puede ser $2M mañana.
    * **V2:** Los límites (`i_bankCapUSD`, `i_withdrawalLimitUSD`) se establecen en **USD** (con 8 decimales) en el constructor. El contrato utiliza **Oráculos de Chainlink** para convertir el valor de *cada* depósito/retiro a USD en tiempo real y verificarlo contra los límites.

4.  **Control de Acceso (OpenZeppelin `Ownable`):**
    * **V1:** No tenía roles administrativos.
    * **V2:** Hereda de `Ownable` de OpenZeppelin. El *owner* (quien despliega el contrato) es el único que puede:
        * Permitir nuevos tokens (`allowToken`).
        * Actualizar las direcciones de los oráculos (`updateTokenPriceFeed`).
        * Realizar retiros de emergencia (`emergencyWithdraw`).

5.  **Gestión de Decimales y Conversión de Valor:**
    * **V1:** No era necesario, todo era en ETH (18 decimales).
    * **V2:** Se introduce la función `getTokenValueUSD` y `s_tokenConfig` para manejar la conversión. El contrato almacena los decimales de cada token (ej. 6 para USDC, 8 para WBTC, 18 para LINK) y los usa junto con el precio del oráculo para normalizar todos los valores a USD (con 8 decimales) para las comprobaciones de límites.

6.  **Seguridad y Mejoras de Código:**
    * **Errores Personalizados:** Se han renombrado todos los errores con el prefijo `KipuBankV2__` para evitar colisiones y mejorar la claridad del *debugging*.
    * **SafeERC20:** Se utiliza la librería `SafeERC20` de OpenZeppelin para todas las interacciones con tokens (`safeTransfer`, `safeTransferFrom`), previniendo problemas con tokens no estándar.
    * **Patrón Checks-Effects-Interactions:** Se mantiene y refuerza el patrón. El estado (saldos) se actualiza *antes* de la transferencia externa de fondos (`.call` o `safeTransfer`) para prevenir ataques de re-entrada.

## Decisiones de Diseño y Trade-offs

1.  **Oráculos y Costo de Gas:** El mayor cambio es la dependencia de Oráculos de Chainlink.
    * **Beneficio:** El banco puede mantener un límite de capitalización estable (ej. $1M USD) independientemente de la volatilidad del precio de los activos que almacena.
    * **Trade-off:** Cada `deposit` y `withdraw` ahora cuesta significativamente más gas porque debe realizar una llamada externa al contrato del oráculo (`latestRoundData`) para obtener el precio actual.

2.  **`s_totalBankValueUSD` y Volatilidad de Precios:**
    * **Implementación:** El valor total del banco en USD (`s_totalBankValueUSD`) se actualiza en cada depósito (aumenta) y retiro (disminuye) según el precio del oráculo *en ese momento*.
    * **Trade-off:** Si el precio de los activos en el banco cambia *sin* que ocurran depósitos o retiros, `s_totalBankValueUSD` no se actualiza. Podría mostrar $1M USD aunque los activos dentro valgan $1.2M USD.
    * **Razón:** La alternativa (recalcular el valor total de *todos* los activos en *cada* depósito) sería prohibitivamente cara en gas (requeriría iterar sobre todos los activos). Este enfoque es un estándar aceptado.

3.  **Gestión de ETH (`address(0)`):**
    * Se decidió usar `address(0)` para representar ETH nativo dentro del sistema de contabilidad, lo cual es un patrón común y eficiente.
    * Se crearon funciones separadas (`depositEth` y `depositToken`) para manejar la lógica de `msg.value` (para ETH) vs. `transferFrom` (para ERC-20), mejorando la claridad y seguridad.

