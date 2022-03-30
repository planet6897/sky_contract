// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./Ownable.sol";
import "./SKPERC721.sol";

contract NFTContractManger is Ownable {
    using Counters for Counters.Counter;

    mapping(uint256 => address) private _nftContracts;
    Counters.Counter private _contractCount;

    event NFTCreated(address indexed nftContractAddress, address indexed owner);

    constructor() {
    }

    /**
     * @dev Prevention of deposit errors
     */
    function deposit() payable public {
        require(msg.value == 0, "Cannot deposit ether.");
    }

    /**
     * Create a new contract (and also address) for NFT
     */
    function createNFTContract(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) public payable onlyOwner returns (address) {

        SKPNFT f = new SKPNFT(_name, _symbol, _initBaseURI, owner());
        _contractCount.increment();

        address nftAddress = address(f);
        _nftContracts[_contractCount.current()] = nftAddress;

        emit NFTCreated(nftAddress, owner());
        return nftAddress;
    }

    /**
     * Get a contract address by id
     */
    function getContractAddress(uint256 nftId) public view returns (address) {
        require(nftId <= _contractCount.current(), "nftId not avaiable");

        return _nftContracts[nftId];
    }

    /**
     * Get a total number of contracts
     */
    function getTotalCount() public view returns (uint256) {
        return _contractCount.current();
    }
}