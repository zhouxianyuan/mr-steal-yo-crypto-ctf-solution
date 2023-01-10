// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Token} from "../src/other/Token.sol";
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
        USDC.mintPerUser([exploiter, user], [TOKENS_IN_EXPLOITER, TOKENS_IN_POOL]);

        // deploy SafuStrategy and safuVault
        safuStrategy = new SafuStrategy(address(USDC));
        safuVault = new safuVault(safuStrategy, "LP Token", "LP");
        safuStrategy.setVault(address(safuVault));

        // user deposit USDC
        vm.startPrank(user);
        user.approve(address(safuVault), type(uint).max);
        safuVault.depositAll();
        vm.stopPrank;

        assertEq(USDC.balanceOf(address(safuStrategy)), TOKENS_IN_POOL);
    }

    function testExploit() public {
        vm.startPrank(exploiter);

        vm.stopPrank();
    }
    
}

/*##############################EXPLOIT##############################*/
contract EXP {
    SafuVault public safuVault;
    Token public USDC;
    constructor(address SafuVaultAddress, address USDCAddress) {
        safuVault = SafuVault(SafuVaultAddress);
    }
    function exploit() external {
        
    }
}

