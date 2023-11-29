// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCount;
    mapping(uint256 => string) private s_tokenIdToUri;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCount = 0;
    }

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCount] = tokenUri;
        _safeMint(msg.sender, s_tokenCount);
        s_tokenCount++;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }
}
