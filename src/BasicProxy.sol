// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy.sol";

contract BasicProxy is Proxy {
  // TODO:
  // 1. add a variable that stores the address of the implementation contract
  address imple;
  // 2. add a constructor that takes the address of the implementation contract and stores it in the variable
  constructor(address _imple){
    imple = _imple;
  }
  // 3. add a fallback function that delegates the call to the implementation contract\
  fallback () external {
    _delegate(imple);          
  }
}