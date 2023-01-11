// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Token} from "../src/other/Token.sol";
import {WETH9} from "../src/other/WETH9.sol";
import {UniswapV2Factory} from "lib/v2-core/contracts/UniswapV2Factory.sol";
import {UniswapV2Pair} from "lib/v2-core/contracts/UniswapV2Pair.sol";
import {UniswapV2Router02} from "lib/v2-periphery/contracts/UniswapV2Router02.sol";
import {SafuMakerV2} from "../src/free-lunch/SafuMakerV2.sol";

// @source of inspiration
// https://rekt.news/badgers-digg-sushi/
// https://rekt.news/sushiswap-saved-0xmaki-speaks-out/

contract freeLunch is Test {
    SafuMakerV2 public safuMakerV2;
    UniswapV2Factory public Factory;
    UniswapV2Router02 public Router;
    UniswapV2Pair public Pair;
    WETH9 public WETH;
    Token public USDC;
    Token public SAFU;
    uint256 EXPLOITER_BALANCE = 100 * 1e18;
    uint256 USER_BALANCE = 1_000_000 * 1e18;
    address exploiter;
    address user;

    function setUp() public {
        // deploy WETH, USDC, SAFU
        WETH = new WETH9();
        USDC = new Token("USDC", "USDC");
        SAFU = new Token("SAFU", "SAFU");

        user = makeAddr("user");
        exploiter = makeAddr("exploiter");

        address[] memory users = new address[](2);
        users[0] = exploiter;
        users[1] = user;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = EXPLOITER_BALANCE;
        amounts[1] = USER_BALANCE;
        SAFU.mintPerUser(users, amounts);
        USDC.mintPerUser(users, amounts);
        // deploy Factory, Router, Maker
        Factory = new UniswapV2Factory(address(this));
        Router = new UniswapV2Router02(address(Factory), address(WETH));
        safuMakerV2 = new SafuMakerV2(address(Factory), address(1), address(SAFU), address(USDC));

        SAFU.approve(address(Router), USER_BALANCE);
        USDC.approve(address(Router), USER_BALANCE);
        Router.addLiquidity(address(SAFU), address(USDC), USER_BALANCE, USER_BALANCE, 0, 0, address(this), block.timestamp + 60);
        address(Pair) = Factory.getPair(address(SAFU), address(USDC));
        Pair.transfer(address(safuMakerV2), 10_000 * 1e18);

    }

    function testExploit() public {
        vm.startPrank(exploiter, exploiter);

        vm.stopPrank();
    }

    function verify() internal {

    }

}
