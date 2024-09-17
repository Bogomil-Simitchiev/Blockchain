// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract HomeRepairService {
    error AdministratorCannotAddRequest(string message);
    error UserAlreadyPaid();
    event RequestIsApproved(uint256 indexed _ID);
    uint256 private _requestCounter = 0;

    // administrator of the contract
    address payable administrator;

    constructor() {
        administrator = payable(msg.sender);
    }

    // save requests
    mapping(address => Request[]) private requestsForRepairing;
    mapping(address => mapping(uint256 => bool)) private isAuditorValid;

    // save requests, their payments (if user has paid for requests it is saved as true)
    mapping(uint256 => address) public requests;
    mapping(uint256 => uint256) public amountToPayForRepair;
    mapping(uint256 => bool) public payments;
    mapping(uint256 => bool) public approvals;

    // save confirmations of the requests and which are accepted (if request is accepted it is saved as true)
    mapping(uint256 => bool) public confirmations;
    mapping(uint256 => bool) public accepted;

    // save number of auditors for the current ID
    mapping(uint256 => uint256) public audits;

    struct Request {
        uint256 ID;
        string description;
    }

    // contract's amount in ETH
    uint256 public ethAmountToSent = 0;

    function addRepairRequest(string memory _description) public {
        // reverts if sender is not the admin
        if (msg.sender == administrator) {
            revert AdministratorCannotAddRequest("Only clients can add requests");
        }
        _requestCounter++;

        // push info in the mapping and set ID -> sender (request)
        requestsForRepairing[msg.sender].push(Request(_requestCounter, _description));
        requests[_requestCounter] = msg.sender;
    }

    function acceptRepairRequest(uint256 _ID, uint256 amountForRequest) public {
        // only admin can accept repairing requests
        require(msg.sender == administrator, "Only administrator can accept a request");
        require(requests[_ID] != address(0), "There is no request with this ID");
        require(accepted[_ID] == false, "Repair already accepted");

        amountToPayForRepair[_ID] = amountForRequest * 1e18;
        accepted[_ID] = true;
    }

    function payToRepair(uint256 _ID) public payable {
        // admin is not supposed to be sender and value (wei) must be greater than 0
        require(msg.sender != administrator, "Administrator cannot pay for request");
        require(requests[_ID] == msg.sender, "User did not have request with that ID");
        require(msg.value > 0, "Cannot send 0 as value");
        require(amountToPayForRepair[_ID] != 0, "Amount for repairing request is not set yet");
        require(msg.value == amountToPayForRepair[_ID], "Amount is not equal to the repairing request cost");

        if (payments[_ID] == true) {
            // reverts if user has paid for the request
            revert UserAlreadyPaid();
        } else {
            payments[_ID] = true;
            ethAmountToSent += msg.value;
        }
    }

    function confirmRepairIsDone(uint256 _ID) public {
        // only admin can cofirm request
        require(msg.sender == administrator, "User cannot confirm his own request");
        require(confirmations[_ID] == false, "Confirmation is already done");
        require(accepted[_ID] == true, "Repair is not accepted");
        require(payments[_ID] == true, "User did not pay");

        confirmations[_ID] = true;
    }

    function verifyJob(uint256 _ID) public {
        require(confirmations[_ID] == true, "Confirmation is not done yet");
        require(requests[_ID] != msg.sender, "User cannot verify his own request");
        require(isAuditorValid[msg.sender][_ID] == false, "Auditor already audited this");

        // set current auditor to true, which means he cannot audit again and increase audits of the current request
        isAuditorValid[msg.sender][_ID] = true;
        audits[_ID] += 1;
    }

    function approveRequestRepair(uint256 _ID) public {
        // admin approves request if auditors are equal or more than 2
        require(msg.sender == administrator, "User cannot approve his own request");
        require(audits[_ID] >= 2, "Not enough auditors");
        approvals[_ID] = true;
        // log that request is done
        emit RequestIsApproved(_ID);
    }

    function transferToAdministrator(uint256 _ID) public payable {
        require(msg.sender == administrator, "Only administrator can execute requests");
        require(approvals[_ID] == true, "Request is not approved");

        // Invalidate the approval to prevent reentrancy
        approvals[_ID] = false;

        bool sent = payable(administrator).send(ethAmountToSent);
        require(sent, "Failed to send Ether");
        ethAmountToSent = 0;
    }

    // Fallback function to receive Ether
    receive() external payable {}
}