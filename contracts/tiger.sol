//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";

contract Tiger is ERC721Enumerable,Ownable{

    //check if address is in whitelist or not
    mapping(address => bool) whitelist;

    //check if address has minted or not
    mapping(address => bool) minted;

    //check if address has interacted or not
    mapping (uint256 => bool) interacted;

    // mappping tokenId to birth year
    mapping (uint256 => int) birth;

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

    //tiger year begin
    int[] yearBegin = [int(-2142633600),-1765065600,-1384819200,-1007251200,-627091200,-249436800,128131200,508291200,885945600,1266105600,1643673600,2023920000,2401488000,2779056000,3159302400,3536870400,3917030400,4294684800];

    //tiger year end
    int[] yearEnd = [int(-2111961600),-1731888000,-1354233600,-974073600,-596505600,-218851200,161308800,538876800,919123200,1296691200,1674345600,2054505600,2432073600,2812233600,3189888000,3570048000,3947702400];

    //mint begin time
    uint256 mintBegin = 1645459200;

    //whitelist end time
    uint256 whitelistEnd = 1647957600;

    //whitelist begin time
    uint256 whitelistBegin = 1647950400;
    

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
    @dev Guarantees user got 721 or qpassport NFT
     */
    modifier Has721OrQpassport(){
        //todo 721 or qpassport interface
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

    /**
    * @dev whitelist mint
     */
    function whitelistMint() public payable notMinted onlyWhitelist{
        require(msg.value == 10 wei);
        if(block.timestamp >= whitelistBegin && block.timestamp <= whitelistEnd){
            _safeMint(_msgSender(),totalSupply());
            minted[_msgSender()] = true;
        } else {
            revert();
        }
    }

    /**
    @dev public sale
     */
    function mint() public payable {
        require(msg.value == 10 wei);
        if (block.timestamp >= mintBegin) {
            _safeMint(_msgSender(),totalSupply());
        } else {
            revert();
        }
    }

    /**
    *@dev calculate the blessings of user
    *@param birthTime biethday timestamp
    *@param tokenId specific tokenId user owned
     */
    function interact(int256 birthTime, uint256 tokenId) public notInteracted(tokenId) {
        require(ownerOf(tokenId) == _msgSender(), "not owner");
        interacted[tokenId] = true;
        birth[tokenId] = birthTime;
    }

    /**
    *@dev to conver timestamp to year
     */
    function timestampToYear(int timestamp) private pure returns (uint) {
        int OFFSET19700101 = 2440588;
        int SECONDS_PER_DAY = 24 * 60 * 60;
        timestamp = timestamp / SECONDS_PER_DAY;
        int __days = int(timestamp);
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        L = _month / 11;
        _year = 100 * (N - 49) + _year + L;
        return uint(_year);
    }

    /**
    *@dev check if user is tiger or not
     */
    function isTiger(int birthTime) private view returns(bool){
        for(uint i = 0; i < yearEnd.length; i++){
            if(birthTime >= yearBegin[i] && birthTime <= yearEnd[i]){
                return true;
            }
        }
        return false;
    }

    /**
     * @dev calculate retuen json.
     */
    function calJson(uint256 tokenId,bool isTigerYear) private view returns (string memory){
        uint index;
        if(isTigerYear && interacted[tokenId]){
            if (isTiger(birth[tokenId])){
                uint cycle = (timestampToYear(int(block.timestamp))-timestampToYear(birth[tokenId])) / 12;
                if (cycle > 8){
                    index = 1;
                } else {
                    index = cycle + 1;
                }
            } else {
                index = 10;
            }
        }
        if(isTigerYear && !interacted[tokenId]){
            index = 0;
        }
        if(!isTigerYear && !interacted[tokenId]){
            index = 0;
        }
        if(!isTigerYear && interacted[tokenId]){
            index = 9;
        }
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
            image[index],
            '","description":"tiger year nft"}'
        )
        )
        )
        );
        string memory output = string(abi.encodePacked("data:application/json;base64,",json));
        return output;
    } 

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public override view returns(string memory) {
        require(ownerOf(tokenId) != address(0), "token not exist");
        bool isTigerYear = true;
        for(uint i = 0; i < yearEnd.length; i++){
            if(int(block.timestamp) >= yearBegin[i] && int(block.timestamp) <= yearEnd[i]){
                return calJson(tokenId,isTigerYear);
            } else if (int(block.timestamp) > yearEnd[i] && int(block.timestamp) < yearBegin[i+1]){
                return calJson(tokenId,!isTigerYear);
            } else {
                continue;
            }
        }
        return calJson(tokenId,!isTigerYear);
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);
        interacted[tokenId] = false;
        birth[tokenId] = 0;
    }

    /**
    @dev transfer uint235 to string type
     */
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

    /**
    * @dev get block time, only for testing 
     */
    function getTime() public view returns(uint){
        return block.timestamp;
    }

    /**
    *@dev withdraw contract balance
     */
    function withdrawAll() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
    *@dev get contract balance
     */
    function getBalance() public view onlyOwner returns(uint){
        return address(this).balance;
    }
}
