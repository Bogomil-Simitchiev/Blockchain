// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Event is ERC721, ERC721URIStorage, Ownable {
    string constant _METADATA =
        "http://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4.ipfs.localhost:8080/?filename=0-PUG.json";

    uint256 private _nextTokenId;
    uint256 public maxTickets;

    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public ticketsPrice;
    string public metadata;
    address public randomWinner;

    constructor(
        address initialOwner,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _ticketsPrice,
        uint256 _maxTickets,
        string memory _metadata
    ) ERC721("MyToken", "MTK") Ownable(initialOwner) {
        require(_ticketsPrice > 0, "Invalid data");
        require(_saleEnd > _saleStart, "Invalid data");
        saleStart = _saleStart;
        saleEnd = _saleEnd;
        ticketsPrice = _ticketsPrice;
        maxTickets = _maxTickets;
        metadata = _metadata;
    }

    function buyTicket(uint256 amount) external payable {
        require(amount < 50, "Too much tickets");
        require(amount * ticketsPrice == msg.value, "Insufficient value");

        if (maxTickets > 0) {
            require(_nextTokenId + amount <= maxTickets, "Too many NFTs");
        }
        for (uint256 i = 0; i < amount; i++) {
            safeMint(msg.sender, _METADATA);
        }
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > saleEnd, "Too early");
        chooseRandomWinner();
        payable(owner()).transfer(address(this).balance);
    }

    function chooseRandomWinner() internal {
        require(randomWinner == address(0), "already choosen");
        randomWinner = _ownerOf(block.prevrandao % _nextTokenId - 1);
        
        safeMint(randomWinner, _METADATA);
    }

    function safeMint(address to, string memory uri) private {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function customBurn(uint256 tokenId) internal {
        super._burn(tokenId);
    }
}