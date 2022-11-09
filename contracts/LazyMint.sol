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

    string private baseURI;

    mapping(uint256 => bool) private _isMinted;

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return bytes(baseURI).length > 0 ? string.concat(baseURI, Strings.toString(tokenId)) : "";
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return isMinted(tokenId) ? ERC721.ownerOf(tokenId) : address(uint160(tokenId >> _DATA_BITS));
    }

    function isMinted(uint256 tokenId) public view returns (bool) {
        return _isMinted[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        require(isMinted(tokenId), "LazyMint: token must be minted");

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function mint(address to, uint256 tokenId) public {
        require(!isMinted(tokenId), "LazyMint: token already minted");
        require(address(uint160(tokenId >> _DATA_BITS)) == msg.sender, "LazyMint: Authentication failed");

        _isMinted[tokenId] = true;
        _mint(to, tokenId);
    }

    function extraData(uint256 tokenId) public pure returns (string memory) {
        //14281678025072077510098302955713827138388214222487638049951095717887
        //41260920106969412157321674113669319076297763250256958714528979889499376975871

        tokenId <<= _ADDRESS_BITS;
        string memory _extraData = Strings.toHexString(tokenId >> _ADDRESS_BITS, 12);

        return _extraData;
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