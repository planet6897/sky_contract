// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SKPContext is Context {
    address private _owner;
    address private _secondOwner;
    bool private _paused;

    mapping(address => bool) blacklisted;
    mapping(address => bool) public operators;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SecondOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event SetOperator(address indexed operator);
    event DeletedOperator(address indexed operator);

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    event BlacklistAddress(address indexed blacklist);
    event WhitelistAddress(address indexed whitelist);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        _paused = false;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwnerShip() {
        require(owner() == _msgSender() || secondOwner() == _msgSender(), "Ownable: caller has no ownership");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwnerShip {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Returns the address of the current second owner.
     */
    function secondOwner() public view virtual returns (address) {
        return _secondOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferSecondOwnership(address newSecondOwner) public virtual onlyOwnerShip {
        require(newSecondOwner != address(0), "Ownable: new second owner is the zero address");
        _transferSecondOwnership(newSecondOwner);
    }

    /**
     * @dev Transfers second ownership of the contract to a new account (`newSecondOwner`).
     * Internal function without access restriction.
     */
    function _transferSecondOwnership(address newSecondOwner) internal virtual {
        address oldOwner = _secondOwner;
        _secondOwner = newSecondOwner;
        emit SecondOwnershipTransferred(oldOwner, newSecondOwner);
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual onlyOwnerShipOrOperator whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual onlyOwnerShipOrOperator whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    // Blacklist
    modifier whenNotPermitted(address node) {
        require(blacklisted[node]);
        _;
    }

    modifier whenPermitted(address node) {
        require(!blacklisted[node]);
        _;
    }

    /**
    * @dev Check a certain node is in a blacklist
    * @param node  Check whether the user at a certain node is in a blacklist
    */
    function isPermitted(address node) public view returns (bool) {
        return !blacklisted[node];
    }

    /**
    * @dev Process blacklisting
    * @param node Process blacklisting. Put the user in the blacklist.
    */
    function blacklist(address node) public onlyOwnerShipOrOperator whenPermitted(node) {
        blacklisted[node] = true;
        emit BlacklistAddress(node);
    }

    /**
    * @dev Process unBlacklisting.
    * @param node Remove the user from the blacklist.
    */
    function unblacklist(address node) public onlyOwnerShipOrOperator whenNotPermitted(node) {
        blacklisted[node] = false;
        emit WhitelistAddress(node);
    }

    modifier onlyOwnerShipOrOperator() {
        require(owner() == _msgSender() || secondOwner() == _msgSender() || operators[_msgSender()]);
        _;
    }

    /**
    * @dev Set the address to operator
    * @param _operator has the ability to pause transaction, has the ability to blacklisting & unblacklisting.
    */
    function setOperator(address _operator) public onlyOwnerShip {
        operators[_operator] = true;
        emit SetOperator(_operator);
    }

    /**
    * @dev Remove the address from operator
    * @param _operator has the ability to pause transaction, has the ability to blacklisting & unblacklisting.
    */
    function delOperator(address _operator) public onlyOwnerShip {
        operators[_operator] = false;
        emit DeletedOperator(_operator);
    }
}
