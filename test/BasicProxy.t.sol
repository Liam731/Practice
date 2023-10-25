// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { testERC20 } from "../src/test/testERC20.sol";
import { testERC721 } from "../src/test/testERC721.sol";
import { MultiSigWallet } from "../src/MultiSigWallet/MultiSigWallet.sol";
import { BasicProxy } from "../src/BasicProxy.sol";
import "forge-std/console.sol";

contract BasicProxyTest is Test {

  event SubmitTransaction(uint indexed txIndex, address indexed to, uint value);
  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  MultiSigWallet public wallet;
  BasicProxy public proxy;
  MultiSigWallet public proxyWallet;

  testERC20 public erc20;
  testERC721 public erc721;

  function setUp() public {
    // vm.startPrank(admin);
    vm.startPrank(alice);
    // wallet = new MultiSigWallet([alice, bob, carol]);
    wallet = new MultiSigWallet([alice, bob, carol]);
    // 1. deploy proxy contract, which implementation should points at wallet's address
    proxy = new BasicProxy(address(wallet));
    // 2. proxyWallet is a pointer that treats proxy contract as MultiSigWallet
    proxyWallet = MultiSigWallet(address(proxy));
    // vm.deal(proxy, 100 ether);
    vm.deal(address(proxy), 100 ether);
    // vm.stopPrank();
    vm.stopPrank();
  }

  function test_updateOwner() public {
    // 1. try to update Owner
      proxyWallet.updateOwner(alice, bob, carol);
    // 2. check the owner1 is alice, owner2 is bob and owner3 is carol
      assertEq(proxyWallet.owner1(), alice);
      assertEq(proxyWallet.owner2(), bob);
      assertEq(proxyWallet.owner3(), carol);
  }

  function test_submit_tx() public {
    // 1. prank as one of the owner
      vm.startPrank(alice);
    // 2. submit a transaction that transfer 10 ether to bob
      // proxyWallet.submitTransaction(bob, 10 ether, "");
    // Does it success? Why?
  }

  function test_call_initialize_and_check() public {
    // 1. call initialize function
      proxyWallet.initialize([alice, bob, carol]);
    // 2. check the owner1, owner2, owner3 is initialized
      assertEq(proxyWallet.owner1(), alice);
      assertEq(proxyWallet.owner2(), bob);
      assertEq(proxyWallet.owner3(), carol);

  }

  function test_call_initialize_and_submit_tx() public {

    // 1. call initialize function
    proxyWallet.initialize([alice, bob, carol]);
    // 2. submit a transaction that transfer 10 ether to bob
    vm.prank(alice);

    vm.expectEmit(true,true,false,true);
    emit SubmitTransaction(0, bob, 10 ether);
    proxyWallet.submitTransaction(bob, 10 ether, "");
    vm.prank(bob);
    proxyWallet.confirmTransaction();
    vm.prank(carol);
    proxyWallet.confirmTransaction();

    vm.prank(alice);
    proxyWallet.executeTransaction();
    // 3. check the transaction is submitted
    assertEq(bob.balance, 10 ether);
    console.log(bob.balance);
    
  }

}
