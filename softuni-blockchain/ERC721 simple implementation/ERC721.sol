// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ERC721 {
    // events
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    // NFT name
    string private _name;

    // NFT symbol
    string private _symbol;

    // private mappings for different purposes
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // constructor setup
    constructor(string memory _NFTname, string memory _NFTsymbol) {
        _name = _NFTname;
        _symbol = _NFTsymbol;
    }

    // getters
    function getName() external view returns (string memory) {
        return _name;
    }
    function getSymbol() external view returns (string memory) {
        return _symbol;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _owners[_tokenId];
        require(owner != address(0), "ownerOf: Owner of token cannot be zero address");
        return _owners[_tokenId];
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "balanceOf: Owner cannot be zero address");
        return _balances[_owner];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(ownerOf(_tokenId) == msg.sender,"safeTransferFrom: Caller is not the owner");
        require(ownerOf(_tokenId) == _from, "safeTransferFrom: _From address is not the owner");
        require(_to != address(0), "safeTransferFrom: Invalid recipient address");

        _beforeTokenTransfer(_from, _to, _tokenId, 1);

        delete _tokenApprovals[_tokenId];

        unchecked {
            _balances[_from] -= 1;
            _balances[_to] += 1;
        }

        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId, 1);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(_approved != address(0), "approve: Zero address is invalid");
        require(msg.sender == ownerOf(_tokenId), "approve: Caller is not the owner");

        _tokenApprovals[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }
    
   
    function setApprovalForAll(address _owner, address _operator, bool _approved) external {
        require(_owner != _operator, "setApprovalForAll: Owner must not be the _operator");
        _operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        require(ownerOf(_tokenId) != address(0), "getApproved: Token is invalid");
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}