// SPDX-License-Identifier: agpl-3.0

pragma solidity 0.8.27;

import "./IAToken.sol";

interface ATokenInterface is IAToken {
  /**
   * @dev Returns the address of the underlying asset of this aToken (E.g. WETH for aWETH)
   **/
  /* solhint-disable-next-line func-name-mixedcase */
  function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}
