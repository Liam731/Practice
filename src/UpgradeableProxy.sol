// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy.sol";
import { BasicProxy } from "./BasicProxy.sol";

contract UpgradeableProxy is Proxy, BasicProxy{
  // TODO:
  // address imple;
  // 1. inherit or copy the code from BasicProxy
  constructor(address _imple) BasicProxy(_imple){
    imple = _imple;
  }

  // fallback () external {
  //   _delegate(imple);          
  // }
  // 2. add upgradeTo function to upgrade the implementation contract
  function upgradeTo(address newImple) external{
    imple = newImple;
  }
  // 3. add upgradeToAndCall, which upgrade the implemnetation contract and call the init function again
  function upgradeToAndCall(address newImple, bytes calldata data) external payable{
    imple = newImple;
    (bool result,) = imple.delegatecall(data);
    require(result);
  }
}