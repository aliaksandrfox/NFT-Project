/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SingleNFT is ERC721URIStorage, ReentrancyGuard {
    uint256 public tokenId;
    uint256 public price;
    address public owner;
    bool public isListed;
    bool public isMinted;
    bool public isBurned;

    event Minted(address indexed minter, uint256 tokenId, string uri);
    event TokenListed(uint256 tokenId, uint256 price);
    event TokenSold(address indexed buyer, uint256 tokenId, uint256 price);
    event TokenBurned(uint256 tokenId);

    constructor() ERC721("UniqueNFT", "UNFT") {
        owner = msg.sender;
        tokenId = 1;
    }


    function mint(string memory tokenURI) public {
        require(!isMinted, "Token already minted");
        require(msg.sender == owner, "Only owner can mint");


        isMinted = true;
        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, tokenURI);

        emit Minted(owner, tokenId,  tokenURI);
    }



    function listToken(uint256 _price) public {
        require(isMinted, "Token not minted");
        require(!isBurned, "Token is burned");
        require(msg.sender == owner, "Only owner can list");
        require(!isListed, "Token already listed");
        require(_price > 0, "Price must be greater than zero");

        price = _price;
        isListed = true;

        emit TokenListed(tokenId, _price);
    }

    function updatePrice(uint256 newPrice) public {
        require(msg.sender == owner, "Only owner can update price");
        require(isMinted, "Token not minted");
        require(isListed, "Token is not listed");
        require(newPrice > 0, "Price must be greater than zero");
        price = newPrice;
        emit TokenListed(tokenId, newPrice);
    }


    function buyToken() public payable nonReentrant {
        require(msg.sender != owner, "Owner can't buy token");
        require(isListed, "Token is not listed for sale");
        require(msg.value >= price, "Insufficient payment");
        address previousOwner = owner;
        owner = msg.sender;
        isListed = false;

        _transfer(previousOwner, msg.sender, tokenId);

        payable(previousOwner).transfer(msg.value);

        emit TokenSold(msg.sender, tokenId, price);
    }



    function burnToken() public {
        require(msg.sender == owner, "Only owner can burn token");
        require(isMinted, "Token not minted");

        _burn(tokenId);
        isListed = false;
        isBurned = true;
        emit TokenBurned(tokenId);
    }

    function getTokenDetails() public view returns (address, uint256, bool) {
        return (owner, price, isListed);
    }
}
