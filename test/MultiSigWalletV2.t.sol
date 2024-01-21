// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Test } from "forge-std/Test.sol";
import { testERC20 } from "../src/test/testERC20.sol";
import { testERC721 } from "../src/test/testERC721.sol";
import { MultiSigWalletV2, MultiSigWallet } from "../src/MultiSigWallet/MultiSigWalletV2.sol";
import { UpgradeableProxy } from "../src/UpgradeableProxy.sol";
import "forge-std/console.sol";

contract MultiSigWalletV2Test is Test {

  address public admin = makeAddr("admin");
  address public alice = makeAddr("alice");
  address public bob = makeAddr("bob");
  address public carol = makeAddr("carol");
  address public receiver = makeAddr("receiver");

  MultiSigWallet public wallet;
  MultiSigWalletV2 public walletV2;

  testERC20 public erc20;
  testERC721 public erc721;

  UpgradeableProxy public proxy;
  MultiSigWallet public proxyWallet;
  MultiSigWalletV2 public proxyWalletV2;

  function setUp() public {

    vm.startPrank(admin);
    wallet = new MultiSigWallet([alice,bob,carol]);
    walletV2 = new MultiSigWalletV2([alice,bob,carol]);

    proxy = new UpgradeableProxy(address(wallet));
    proxyWallet = MultiSigWallet(address(proxy));
    vm.deal(address(proxy), 100 ether);

    proxyWallet.initialize([alice, bob, carol]);
    vm.stopPrank();
  }

  function test_upgrade_can_upgrade() public {
    vm.startPrank(bob);
    // 1. assert wallet is initialized and point to correct implementation
    assertEq(proxyWallet.owner1(), alice);
    assertEq(proxyWallet.owner2(), bob);
    assertEq(proxyWallet.owner3(), carol);
    // 2. test proxyWallet's function works
    proxyWallet.submitTransaction(bob, 10 ether, "");
    // 3. upgrade to V2
    proxy.upgradeTo(address(walletV2));
    proxyWalletV2 = MultiSigWalletV2(address(proxy));
    // 4. assert wallet is upgraded
    proxyWalletV2.setAdmin(carol);
    (bool isUpgraded,) = address(proxyWalletV2).call(abi.encodeWithSignature("updateOwner(address,address,address)",alice, bob, carol));
    assert(isUpgraded);
    // 5. assert cancel function is added
    console.log(isUpgraded);
    // console.log(proxyWalletV2.transactions().length);
    console.log(carol);
    assertEq(proxyWallet.transactions().length, 0);
    
  }
}
