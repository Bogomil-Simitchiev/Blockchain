// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract HomeRepairService {
    error AdministratorCannotAddRequest();
    error UserAlreadyPaid();
    event RequestIsDone(uint256 indexed _ID);

    // administrator of the contract
    address public administrator = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    // save requests
    mapping(address => Request[]) private requestsForRepairing; 
    mapping(address => bool) private isAuditorValid;

    // save requests, their payments (if user has paid for requests it is saved as true)
    mapping(uint256 => address) public requests;
    mapping(uint256 => bool) public payments;

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
    uint256 public ethAmount = 0;

    function addRepairRequest(uint256 _ID, string memory _description) public {
        // reverts if sender is not the admin
        if (msg.sender == administrator) {
            revert AdministratorCannotAddRequest();
        }

        // push info in the mapping and set ID -> sender (request)
        requestsForRepairing[msg.sender].push(Request(_ID, _description));

        requests[_ID] = msg.sender;
    }

    function acceptRepairRequest(uint256 _ID) public {
        // only admin can accept repairing requests
        require(
            msg.sender == administrator,
            "Only administrator can accept a request"
        );
        require(requests[_ID] != address(0), "There is no request with this ID");
        require(accepted[_ID] == false, "Repair already accepted");
        require(payments[_ID] == true, "User did not pay");

        accepted[_ID] = true;
    }

    function payToRepair(uint256 _ID) public payable {
        // admin is not supposed to be sender and value (wei) must be greater than 0
        require(msg.sender != administrator, "Administrator cannot be sender");
        require(msg.value > 0, "Cannot send 0 as value");

        if (payments[_ID] == true) {
            // reverts if user has paid for the request
            revert UserAlreadyPaid();
        } else {
            // chechks if user have request
            require(requests[_ID] == msg.sender, "User did not have request");
            payments[_ID] = true;
            ethAmount += msg.value;
        }
    }

    function confirmRepairIsDone(uint256 _ID) public {
        // only admin can cofirm request
        require(
            msg.sender == administrator,
            "User cannot confirm his own request"
        );
        require(confirmations[_ID] == false, "Confirmation is already done");
        require(accepted[_ID] == true, "Repair is not accepted");
        require(payments[_ID] == true, "User did not pay");

        confirmations[_ID] = true;
    }

    function verifyJob(uint256 _ID) public {
        require(confirmations[_ID] == true, "Confirmation is not done yet");
        require(
            requests[_ID] != msg.sender,
            "User cannot verify his own request"
        );
        require(
            isAuditorValid[msg.sender] == false,
            "Auditor already audited this"
        );

        // set current auditor to true, which means he cannot audit again and increase audits of the current request
        isAuditorValid[msg.sender] = true;
        audits[_ID] += 1;
    }

    function approveRequestRepair(uint256 _ID)
        public
    {
        // admin approves request if auditors are equal or more than 2
        require(msg.sender == administrator, "User cannot aprove his own request");
        require(audits[_ID] >= 2, "Not enough auditors");

        // log that request is done
        emit RequestIsDone(_ID);
        
    }
}