//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Tiger is ERC721URIStorage,Ownable{
    //tokenId counter
    uint256 private counter;
    
    //init price
    uint256 private price = 10 wei;

    //check if address is in whitelist or not
    mapping(address => bool) whitelist;

    //check if address has minted or not
    mapping(address => bool) minted;

    //check if address has interacted or not
    mapping (uint256 => bool) interacted;

    //mapping tokenId to blessings
    mapping (uint256 => string) blessings;

    //mapping tokenId to status index
    mapping(uint256 => uint) index;

    //image url
    string[] private image = [
        'https://arweave.net/UDtoZ6MIfkHS_ann_4Vd0eGjsTIMDtG62KPyY2WWyVU',
        'https://arweave.net/L-sJQCHkxN7Lp1jnnCI6FE8QzhrJ0fGKIZHvHk0-1lY',
        'https://arweave.net/TsBjAI85WGYxGxn2DW4qe8q_S5sfZoVx1e10LOAx6JA',
        'https://arweave.net/sChUEpEHXRHjYWxNhSQaHsVDB5Y3aDYfm2byzuDoRJI',
        'https://arweave.net/E54w6pNdsnP3sURt7xJ53-sA5n1OYHo9Cov-Tb22320',
        'https://arweave.net/JgM0LpkTkhDuUkWKzcI9U1HTA2KeOOyxPrNOgOp0W1g',
        'https://arweave.net/5-IyU7xPGQtI9smyB7_2qkOdXmpAQXu_0bOCRoUGA5Q',
        'https://arweave.net/CN722GXJbVTKeEzunsD0-lrTso2Zp-z_m4O6DPuj5s0',
        'https://arweave.net/_PH2KEAOJyLQ2qHHaPKA_gItxC9yLF2uLzT4MpxFtoA',
        'https://arweave.net/ew-vjO2gXu134J2USd5eGfeV9FbNcn5TcejpaKw4Y2A',
        'https://arweave.net/6q1xDOWCrTqterOM9W5VzS02UQWaZDIN6gZpMtfQVLQ'
    ];

    //blessing status
    string[] private status = ["Init","One","Two","Three","Four","Five","Six","Seven","Eight","Nine","NotTiger"];

    //tiger year begin
    int[] yearBegin = [int(-2142633600),-1765065600,-1384819200,-1007251200,-627091200,-249436800,128131200,508291200,885945600,1266105600,1643673600,2023920000,2401488000,2779056000,3159302400,3536870400,3917030400,4294684800];

    //tiger year end
    int[] yearEnd = [int(-2111990400),-1731916800,-1354262400,-974102400,-596534400,-218880000,161280000,538848000,919094400,1296662400,1674316800,2054476800,2432044800,2812204800,3189859200,3570019200,3947673600];

    //mint begin time
    uint256 mintBegin = 0;

    //whitelist end time
    uint256 whitelistEnd = 1647950400;

    //whitelist begin time
    uint256 whitelistBegin = 1641957600;
    

    constructor(string memory _name, string memory _symbol) 
    ERC721(_name,_symbol)
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
        require(interacted[tokenId] == false);
        _;
    }
    
    /**
    *@dev add address to whitelist map
     */
    function addWhitelist(address[] memory list) external onlyOwner {
        for (uint i = 0; i < list.length; i++) {
            whitelist[list[i]] = true;
        }
    }

    function initAndMint() private{
        _safeMint(_msgSender(),counter);
        blessings[counter] = status[0];
        index[counter] = 0;
        minted[_msgSender()] = true;
        counter += 1;
    }
    /**
    * @dev mint tiger NFT and initialize status
     */
    function mint() public payable notMinted {
        require(msg.value == price);
        if(block.timestamp >= whitelistBegin && block.timestamp <= whitelistEnd){
            require(whitelist[_msgSender()] == true,"caller is not in whitelist");
            initAndMint();
        } else if (block.timestamp >= mintBegin) {
            initAndMint();
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
    function interact(uint256 year, uint256 tokenId) public notInteracted(tokenId) returns(string memory) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "not owner nor approved");
        interacted[tokenId] = true;
        (uint cycle,uint remainder) = ((2022-year) / 12,(2022 - year) % 12);
        if (remainder != 0){
            blessings[tokenId] = status[10];
            index[tokenId] = 10;
        }else if(cycle == 0){
            blessings[tokenId] = status[1];
            index[tokenId] = 1;
        }else if(cycle == 1){
            blessings[tokenId] = status[2];
            index[tokenId] = 2;
        }else if(cycle == 2){
            blessings[tokenId] = status[3];
            index[tokenId] = 3;
        }else if(cycle == 3){
            blessings[tokenId] = status[4];
            index[tokenId] = 4;
        }else if(cycle == 4){
            blessings[tokenId] = status[5];
            index[tokenId] = 5;
        }else if(cycle == 5){
            blessings[tokenId] = status[6];
            index[tokenId] = 6;
        }else if(cycle == 6){
            blessings[tokenId] = status[7];
            index[tokenId] = 7;
        }else if(cycle == 7){
            blessings[tokenId] = status[8];
            index[tokenId] = 8;
        }else if(cycle == 8){
            blessings[tokenId] = status[9];
            index[tokenId] = 9;
        }else{
            blessings[tokenId] = status[1];
            index[tokenId] = 1;
        }
        return blessings[tokenId];
    }

    function calJson(uint256 tokenId,uint i) private view returns (string memory){
        string memory strTokenId = _toString(tokenId);
        string memory json = Base64.encode(
            bytes(
            string(
            abi.encodePacked(
            '{"id":"',
            strTokenId,
            '","name":"tiger#',
            strTokenId,
            '","image":"',
            image[i],
            '","description":"tiger year nft","attributes":[{"trait_type":"status","value":"',
            blessings[tokenId],
            '"}]}'
        )
        )
        )
        );
        string memory output = string(abi.encodePacked("data:application/json;base64,",json));
        return output;
    } 

    function tokenURI(uint256 tokenId) public override view returns(string memory) {
        require(ownerOf(tokenId) != address(0), "token not exist");
        uint initStatus = 0;
        uint notTigerBless = 9;
        for(uint i = 0; i < yearEnd.length; i++){
            if(int(block.timestamp) >= yearBegin[i] && int(block.timestamp) <= yearEnd[i]){
                return calJson(tokenId,index[tokenId]);
            } else if (int(block.timestamp) > yearEnd[i] && int(block.timestamp) < yearBegin[i+1]){
                if(interacted[tokenId]){
                    return calJson(tokenId,notTigerBless);
                }else {
                    return calJson(tokenId,initStatus);
                }
            } else {
                continue;
            }
        }
        return calJson(tokenId,0);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        interacted[tokenId] = false;
        blessings[tokenId] = status[0];
        index[tokenId] = 0;
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function getTime() public view returns(uint){
        return block.timestamp;
    }

    function withdraw(uint amout) public onlyOwner {
        require(address(this).balance >= amout);
        payable(msg.sender).transfer(amout);
    }

    function getBalance() public view onlyOwner returns(uint){
        return address(this).balance;
    }
}