//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Tiger is ERC721URIStorage,Ownable{
    //tokenId counter
    uint256 private counter;
    
    //check if address is in whitelist or not
    mapping(address => bool) whitelist;

    //check if address has minted or not
    mapping(address => bool) minted;

    //check if address has interacted or not
    mapping (uint256 => mapping(address => bool)) interacted;

    //mapping address to blessings
    mapping (address => Status) blessings;

    //blessing status
    enum Status{
        Null,
        Init,
        Zore,
        Twelve,
        TwentyFour,
        ThirtySix,
        FoutyEight,
        Sixty,
        SeventyTwo,
        EighttyFour,
        NinetySix,
        NotTiger
    }

    //tiger year begin
    int[] yearBegin = [int(-2142633600),-1765065600,-1384819200,-1007251200,-627091200,-249436800,128131200,508291200,885945600,1266105600,1643673600,2023920000,2401488000,2779056000,3159302400,3536870400,3917030400];

    //tiger year end
    int[] yearEnd = [int(-2111990400),-1731916800,-1354262400,-974102400,-596534400,-218880000,161280000,538848000,919094400,1296662400,1674316800,2054476800,2432044800,2812204800,3189859200,3570019200,3947673600];

    //mint begin time
    uint256 mintBegin = 1648252800;

    //whitelist end time
    uint256 whitelistEnd = 1647957600;

    //whitelist begin time
    uint256 whitelistBegin = 1647950400;

    constructor(string memory name, string memory symbol) 
    ERC721(name,symbol)
    {}

    /**
    * @dev Guarantees msg.sender is in whitelist
    */
    modifier onlyWhitelist(){
        require(whitelist[_msgSender()] == true,"caller is not in whitelist");
        _;
    }

    /**
    *@dev Guarantees msg.sender hasn't minted before
     */
    modifier notMinted(){
        require(minted[_msgSender()] == false, "already minted");
        _;
    }

    /**
    *@dev Guarantees msg.sender with specific tokenId hasn't interacted before
    *@param tokenId tokenId that msg.sender owned
     */
    modifier notInteracted(uint tokenId){
        require(interacted[tokenId][_msgSender()] == false);
        _;
    }
    
    /**
    *@dev add address to whitelist map
     */
    function addWhitelist(address to) external onlyOwner {
        require(to!=address(0),"invalid address");
        whitelist[to] = true;
    }

    /**
    * @dev mint tiger NFT and initialize status
     */
    function mint() public notMinted {
        if(block.timestamp >= whitelistBegin || block.timestamp <= whitelistEnd){
            require(whitelist[_msgSender()] == true,"caller is not in whitelist");
            _safeMint(_msgSender(),counter);
            blessings[_msgSender()] = Status.Init;
            minted[_msgSender()] = true;
            counter += 1;
        } else if (block.timestamp >= mintBegin) {
            _safeMint(_msgSender(),counter);
            blessings[_msgSender()] = Status.Init;
            minted[_msgSender()] = true;
            counter += 1;
        } else {
            revert();
        }
    }

    /**
    *@dev calculate the blessings of user
    *@param year year of birth
    *@param tokenId specific tokenId user owned
    *@return status generated for user
     */
    function interact(uint256 year, uint256 tokenId) public notInteracted(tokenId) returns(Status) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "not owner nor approved");
        interacted[tokenId][_msgSender()] == true;
        (uint cycle,uint remainder) = ((2022-year) / 12,(2022 - year) % 12);
        if (remainder != 0){
            blessings[_msgSender()] = Status.NotTiger;
        }else if(cycle == 0){
            blessings[_msgSender()] = Status.Zore;
        }else if(cycle == 1){
            blessings[_msgSender()] = Status.Twelve;
        }else if(cycle == 2){
            blessings[_msgSender()] = Status.TwentyFour;
        }else if(cycle == 3){
            blessings[_msgSender()] = Status.ThirtySix;
        }else if(cycle == 4){
            blessings[_msgSender()] = Status.FoutyEight;
        }else if(cycle == 5){
            blessings[_msgSender()] = Status.Sixty;
        }else if(cycle == 6){
            blessings[_msgSender()] = Status.SeventyTwo;
        }else if(cycle == 7){
            blessings[_msgSender()] = Status.EighttyFour;
        }else if(cycle == 8){
            blessings[_msgSender()] = Status.NinetySix;
        }else{
            blessings[_msgSender()] = Status.Zore;
        }
        return blessings[_msgSender()];
    }

    function getTokenURI(uint256 tokenId) public view returns(Status) {
        require(ownerOf(tokenId) != address(0), "token not exist");
        for(uint i = 0; i < 16; i++){
            if(int(block.timestamp) >= yearBegin[i] || int(block.timestamp) <= yearEnd[i]){
                return blessings[_msgSender()];
            } else {
                if(interacted[tokenId][_msgSender()]){
                    return Status.NinetySix;
                }else {
                    return Status.Init;
                }
            }
        }
    }
}