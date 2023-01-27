// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Authorizable.sol";

contract SKPNFT is ERC721Enumerable, Authorizable {
    using Strings for uint256;

    bool public paused = false;

    string private baseURI;
    mapping(uint256 => string) private _fileHash;

    constructor(
        string memory _name,
        string memory _symbol,
        address owner
    ) ERC721(_name, _symbol) {
        setBaseURI("https://nft.skyplay.io/files/");
        // setBaseURI("https://nftdev.skyplay.io/files/");
        _transferOwnership(owner);
    }

    function setBaseURI(string memory newBaseURI) public onlyAuthorized {
        baseURI = newBaseURI;
    }

    function setFileHash(uint256 tokenId, string memory fileHash) public onlyAuthorized {
        require(
            _exists(tokenId),
            "ERC721Metadata: setFileHash for nonexistent token"
        );

        _fileHash[tokenId] = fileHash;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, string memory fileHash) public onlyAuthorized {
        uint256 newTokenId = totalSupply() + 1;
        require(!paused);

        _safeMint(_to, newTokenId);

        _fileHash[newTokenId] = fileHash;
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
            ? string(abi.encodePacked(currentBaseURI, _fileHash[tokenId]))
            : "";
    }

    function burn(uint256 tokenId) public onlyAuthorized {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        _burn(tokenId);
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}
