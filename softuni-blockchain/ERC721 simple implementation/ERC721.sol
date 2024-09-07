// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    // NFT name
    string private _name;

    // NFT symbol
    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function getName() external view returns (string memory) {
        return _name;
    }

    function getSymbol() external view returns (string memory) {
        return _symbol;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address ownerOfToken = _owners[_tokenId];
        require(
            ownerOfToken != address(0),
            "Owner of token cannot be zero address!"
        );
        return _owners[_tokenId];
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "Owner cannot be zero address!");
        return _balances[_owner];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        address owner = ownerOf(_tokenId);

        require(owner == _from, "TransferFrom: caller is not the owner");
        require(_to != address(0), "TransferFrom: invalid recipient address");
        require(
            msg.sender == owner,
            "TransferFrom: only owner can change user"
        );
        require(msg.value > 0, "Cannot set zero or less!");
        
        delete _tokenApprovals[_tokenId];

        unchecked {
            _balances[_from] -= msg.value;
            _balances[_to] += msg.value;
        }

        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }
}
