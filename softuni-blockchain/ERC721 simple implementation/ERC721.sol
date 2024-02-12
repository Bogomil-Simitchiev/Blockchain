// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
  
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function getName() public view returns (string memory) {
        return _name;
    }

    function getSymbol() public view returns (string memory) {
        return _symbol;
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return _owners[_tokenId];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }

    function mint(address _user, uint256 _tokenId) public payable {
        require(msg.value > 0, "Cannot set zero or less!");
        require(_user != address(0), "User cannot be zero address!");

        _balances[_user] = msg.value;
        _owners[_tokenId] = _user;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public payable {
        address owner = ownerOf(_tokenId);

        require(owner == _from, "TransferFrom: caller is not the owner");
        require(_to != address(0), "TransferFrom: invalid recipient address");
        require(msg.sender == owner, "TransferFrom: only owner can change user");

         require(msg.value > 0, "Cannot set zero or less!");
    
        require(msg.value <= _balances[_from] , "Invalid amount of money!");

        _balances[_from] -= msg.value;
        _balances[_to] += msg.value;
        _owners[_tokenId] = _to;
        
        emit Transfer(_from, _to, _tokenId);
    }
    function burn(address _owner, uint256 _tokenId) public {
         address owner = ownerOf(_tokenId);
         require(owner == _owner, "TransferFrom: caller is not the owner");

         delete _owners[_tokenId];
         _balances[_owner] = 0;

    }
}