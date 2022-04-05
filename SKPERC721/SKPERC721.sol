// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Ownable.sol";

contract SKPNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    bool public paused = false;

    mapping(uint256 => string) private _tokenURIs;

    constructor(
        string memory _name,
        string memory _symbol,
        address owner
    ) ERC721(_name, _symbol) {
        _setBaseURI("ipfs://");
        _transferOwnership(owner);
    }

    function deposit() payable public {
        require(msg.value == 0, "Cannot deposit ether.");
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, string memory tokenURI) public payable onlyOwner {
        uint256 newTokenId = totalSupply() + 1;
        require(!paused);

        _safeMint(_to, newTokenId);

        _tokenURIs[newTokenId] = tokenURI;
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, _tokenURIs[tokenId]))
            : "";
    }

    function burn(uint256 tokenId) public onlyOwner {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        _burn(tokenId);
    }

    function _setBaseURI(string memory _newBaseURI) internal onlyOwner {
        baseURI = _newBaseURI;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}
