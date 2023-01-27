// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";

contract Authorizable is Ownable {

    mapping(address => bool) public authorized;

    event AddAuthorized(address indexed _toAdd);
    event RemoveAuthorized(address indexed _toRemove);

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner() == msg.sender, "Authorizable: caller is not authorized");
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != address(0), "Authorizable: new is the zero address");
        authorized[_toAdd] = true;

        emit AddAuthorized(_toAdd);
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != address(0), "Authorizable: new is the zero address");
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;

        emit RemoveAuthorized(_toRemove);
    }
}