// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//14281678025072077510098302955713827138388214222487638049951095717887
//41260920106969412157321674113669319076297763250256958714528979889499376975871

contract LazyMint is ERC721, Ownable {
    /**
     * LazyMint tokenId structure
     * HexToDec(`address` + `extraData`)
     * extraData size must be 12 bytes
     */
    uint96 private constant _DATA_MAX = 0xFFFFFFFFFFFFFFFFFFFFFFFF;
    uint8 private constant _DATA_BITS = 0x60;
    uint8 private constant _ADDRESS_BITS = 0xA0;
    string private baseURI;

    constructor(string memory name, string memory symbol, string memory uri) ERC721(name, symbol) {
        baseURI = uri;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return bytes(_baseURI()).length > 0 
        ? string.concat(_baseURI(), Strings.toString(tokenId)) 
        : "";
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _exists(tokenId) 
        ? super.ownerOf(tokenId) 
        : address(uint160(tokenId >> _DATA_BITS));
    }

    function mint(address to, uint256 tokenId) public {
        require(address(uint160(tokenId >> _DATA_BITS)) == msg.sender, "LazyMint: Authentication failed");
        _mint(to, tokenId);
    }

    function extraData(uint256 tokenId) public pure returns (string memory) {
        tokenId <<= _ADDRESS_BITS;
        return Strings.toHexString(tokenId >> _ADDRESS_BITS, 12);
    }
}