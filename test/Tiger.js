const { expect } = require("chai");
const {ethers, network} = require("hardhat");
const { json } = require("hardhat/internal/core/params/argumentTypes");

image = [
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

describe("Tiger Test", function () {

  it("Test tiger interact", async function () {
    const [owner] = await ethers.getSigners();
    const Tiger = await ethers.getContractFactory("Tiger");
    const tigerNFT = await Tiger.deploy("Tiger","TG");
    for(let i = 0; i < 9; i++){
      const options = {value: ethers.utils.parseEther("0.000000000000000010")};
      await tigerNFT.mint(options);
      year = 2022-12*i;
      await tigerNFT.interact(year,i);
      const bs64 = await tigerNFT.tokenURI(i);
      const json = Buffer.from(bs64.slice(29),'base64').toString('ascii')
      const jsonOBJ = JSON.parse(json);
      const url = jsonOBJ.image;
      expect(url).to.equal(image[i+1]);
    }
  });


  it("test init image", async function(){
    const [owner] = await ethers.getSigners();
    const Tiger = await ethers.getContractFactory("Tiger");
    const tigerNFT = await Tiger.deploy("Tiger","TG");
    const options = {value: ethers.utils.parseEther("0.000000000000000010")};
    await tigerNFT.mint(options);
    const bs64 = await tigerNFT.tokenURI(0);
    const json = Buffer.from(bs64.slice(29),'base64').toString('ascii')
    const jsonOBJ = JSON.parse(json);
    const url = jsonOBJ.image;
    expect(url).to.equal(image[0]);
  })


  it("test not tiger", async function(){
    const [owner] = await ethers.getSigners();
    const Tiger = await ethers.getContractFactory("Tiger");
    const tigerNFT = await Tiger.deploy("Tiger","TG");
    for(let i = 0; i < 9; i++){
      const options = {value: ethers.utils.parseEther("0.000000000000000010")};
      await tigerNFT.mint(options);
      year = 2022-12*i-1;
      await tigerNFT.interact(year,i);
      const bs64 = await tigerNFT.tokenURI(i);
      const json = Buffer.from(bs64.slice(29),'base64').toString('ascii')
      const jsonOBJ = JSON.parse(json);
      const url = jsonOBJ.image;
      expect(url).to.equal(image[10]);
    }
  })


  it("Test age greater than 96", async function () {
    const [owner] = await ethers.getSigners();
    const Tiger = await ethers.getContractFactory("Tiger");
    const tigerNFT = await Tiger.deploy("Tiger","TG");
    for(let i = 0; i < 9; i++){
      const options = {value: ethers.utils.parseEther("0.000000000000000010")};
      await tigerNFT.mint(options);
      year = 2022-12*(i+9);
      await tigerNFT.interact(year,i);
      const bs64 = await tigerNFT.tokenURI(i);
      const json = Buffer.from(bs64.slice(29),'base64').toString('ascii')
      const jsonOBJ = JSON.parse(json);
      const url = jsonOBJ.image;
      expect(url).to.equal(image[1]);
    }
  });


  it("test whitelist timestamp", async function(){
    const [owner] = await ethers.getSigners();
    const Tiger = await ethers.getContractFactory("Tiger");
    const tigerNFT = await Tiger.deploy("Tiger","TG");
    const options = {value: ethers.utils.parseEther("0.000000000000000010")};
    const timeNow = await tigerNFT.getTime();
    await network.provider.send("evm_increaseTime",[1647950400-timeNow]);
    await network.provider.send("evm_mine")
    await tigerNFT.addWhitelist([owner.address])
    await tigerNFT.whitelistMint(options)
    const bs64 = await tigerNFT.tokenURI(0);
    const json = Buffer.from(bs64.slice(29),'base64').toString('ascii')
    const jsonOBJ = JSON.parse(json);
    const url = jsonOBJ.image;
    expect(url).to.equal(image[0]);
  })
});