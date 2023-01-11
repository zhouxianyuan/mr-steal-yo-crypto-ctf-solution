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

contract freeLunch is Test {
    SafuMakerV2 public safuMakerV2;
    UniswapV2Factory public Factory;
    UniswapV2Router02 public Router;
    UniswapV2Pair public Pair;
    WETH9 public WETH;
    Token public USDC;
    Token public SAFU;
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
        amounts[0] = 100;
        amounts[1] = 1_000_000;
        SAFU.mintPerUser(users, amounts);
        USDC.mintPerUser(users, amounts);
        // deploy Factory, Router, Maker
        Factory = new UniswapV2Factory(address(this));
        Router = new UniswapV2Router02(address(Factory), address(WETH));
        safuMakerV2 = new SafuMakerV2(address(Factory), address(1), address(SAFU), address(USDC));

    }


}