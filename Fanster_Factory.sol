// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract FanClub is ERC721Enumerable {
    uint256 public price;
    uint256 public maxSupply;
    uint256 public currentTokenId;
    address public owner;
    string public sport;
    string public team;
    string public ticker;
    uint256 public passesSold;
    string public imageUrl;

    constructor(
        string memory _name,
        string memory _ticker,
        string memory _sport,
        string memory _team,
        uint256 _price,
        uint256 _maxSupply,
        address _owner,
        string memory _imageUrl 
    ) ERC721(_name, _ticker) {
        require(_price > 0, "Price must be greater than zero");
        require(_maxSupply > 0, "Max supply must be greater than zero");
        require(bytes(_imageUrl).length > 0, "Image URL is required");

        price = _price;
        maxSupply = _maxSupply;
        owner = _owner;
        sport = _sport;
        team = _team;
        ticker = _ticker;
        passesSold = 0;
        imageUrl = _imageUrl; 
    }


    function mint() external payable {
        require(currentTokenId < maxSupply, "All passes have been minted");
        require(msg.value == price, "Incorrect ether value sent");

        currentTokenId++;
        passesSold++;
        _mint(msg.sender, currentTokenId);
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance > 0, "No funds to withdraw");
        payable(owner).transfer(address(this).balance);
    }

    function getPassesSold() external view returns (uint256) {
        return passesSold;
    }
  function getImageUrl() external view returns (string memory) {
        return imageUrl;
    }
}

contract FanClubFactory {
    struct FanClubInfo {
        address clubAddress;
        string name;
        string ticker;
        string sport;
        string team;
        uint256 price;
        uint256 maxSupply;
        uint256 passesSold;
        address owner;
        string imageUrl;
    }

    FanClubInfo[] public fanClubs;
    mapping(address => FanClubInfo[]) public ownerToFanClubs;

    event FanClubCreated(address indexed fanClubAddress, address indexed owner);

    function createFanClub(
        string memory _name,
        string memory _ticker,
        string memory _sport,
        string memory _team,
        uint256 _price,
        uint256 _maxSupply,
        string memory _imageUrl 
    ) external {
        require(bytes(_name).length > 0, "Name is required");
        require(bytes(_ticker).length > 0, "Ticker is required");
        require(bytes(_sport).length > 0, "Sport is required");
        require(bytes(_team).length > 0, "Team is required");
        require(_price > 0, "Price must be greater than zero");
        require(_maxSupply > 0, "Max supply must be greater than zero");
        require(bytes(_imageUrl).length > 0, "Image URL is required");

        FanClub newFanClub = new FanClub(_name, _ticker, _sport, _team, _price, _maxSupply, msg.sender, _imageUrl);
        
        FanClubInfo memory newClubInfo = FanClubInfo({
            clubAddress: address(newFanClub),
            name: _name,
            ticker: _ticker,
            sport: _sport,
            team: _team,
            price: _price,
            maxSupply: _maxSupply,
            passesSold: 0,
            owner: msg.sender,
            imageUrl: _imageUrl 
        });

        fanClubs.push(newClubInfo);
        ownerToFanClubs[msg.sender].push(newClubInfo);

        emit FanClubCreated(address(newFanClub), msg.sender);
    }


    function updateFanClubPassesSold(address _clubAddress) internal {
        for (uint256 i = 0; i < fanClubs.length; i++) {
            if (fanClubs[i].clubAddress == _clubAddress) {
                FanClub club = FanClub(_clubAddress);
                fanClubs[i].passesSold = club.getPassesSold();
                break;
            }
        }
    }

    function getAllFanClubs() external view returns (FanClubInfo[] memory) {
        return fanClubs;
    }

    function getFanClubCount() external view returns (uint256) {
        return fanClubs.length;
    }
}