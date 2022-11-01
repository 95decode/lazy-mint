// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LazyMint is ERC721, Ownable {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    uint96 private constant _DATA_MAX = 0xFFFFFFFFFFFFFFFFFFFFFFFF;
    uint8 private constant _DATA_BITS = 0x60;
    uint8 private constant _ADDRESS_BITS = 0xA0;

    string baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string.concat(baseURI, Strings.toString(tokenId));
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return (tokenId > _DATA_MAX) ? address(uint160(tokenId >> _DATA_BITS)) : _owners[tokenId];
    }

    function isLazy(uint256 tokenId) public pure returns (bool) {
        return (tokenId > _DATA_MAX) ? true : false;
    }

    function test(uint256 tokenId) public pure returns (string memory) {
        //14281678025072077510098302955713827138388214222487638049951095717887

        tokenId <<= _ADDRESS_BITS;
        string memory a = Strings.toHexString(tokenId >> _ADDRESS_BITS, 12);

        return a;
        /*
        string memory a = Strings.toHexString(tokenId, 32);
        bytes memory b = new bytes(12);
        
        for(uint i = 40; i < 64; i++){
            b[i] = bytes(a)[i];
        }

        return string(b);
        */
    }
}