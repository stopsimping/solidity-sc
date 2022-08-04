// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract Charity {
    // owner TopG
    address topG;

    event LogAssosFundingReceived(address addr, uint amount, uint contractBalance);

    constructor() {
        topG = msg.sender; // global var, addr of sender
    }

    struct Association {
        address payable walletAddress; // make sure address is payable
        string name;
        uint releasedTime;
        uint amount;
        bool canWithdraw;
    }

    // define associations
    Association[] public associations;

    modifier onlyTopG() {
        require(msg.sender == topG, "only the top G can add associations");
        _; // put the rest of the function under
    }

    // add associations
    function addAssos(address payable walletAddress, string memory name, uint releasedTime, uint amount, bool canWithdraw) public onlyTopG {
        associations.push(Association(
            walletAddress,
            name,
            releasedTime,
            amount,
            canWithdraw
        ));
    }

   

    // deposit funds to contract & specifically to associations acccounts
    function deposit(address walletAddress) payable public {
        for(uint i = 0; i < associations.length; ++i) {
            if(associations[i].walletAddress == walletAddress) {
                associations[i].amount += msg.value;
            }
        }
    }

    function addToAssosBalance(address walletAddress) private {
        for (uint i = 0; i < associations.length; ++i) {
            if (associations[i].walletAddress == walletAddress) {
                associations[i].amount += msg.value;
                emit LogAssosFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    // check money (view = can't change state of storage vars, exec locally, not on the blockchain)
    function balanceOf() public view returns(uint) {
        return address(this).balance; // this = in this contract
    }

    function getIndex(address walletAddress) view private returns(uint) {
        for(uint i = 0; i < associations.length; ++i) {
            if (associations[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 9999;
    }

    // association can withdraw money ? 
    function availableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getIndex(walletAddress);
        require (block.timestamp > associations[i].releasedTime, "You are not able to withdraw!");
        if (block.timestamp > associations[i].releasedTime) {
            associations[i].canWithdraw = true;
            return true;
        }
        return false;
    }

    // association can see if can withdraw
    function withdraw(address walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == associations[i].walletAddress, "You must be the association to withdraw!");
        require(associations[i].canWithdraw == true, "You don't have the permission to withdraw at this time!");
        associations[i].walletAddress.transfer(associations[i].amount);
    }
}