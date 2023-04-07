// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Luna.sol";
import "./Ust.sol";
import "./PriceConsumerV3.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//this smart contract can simulate Luna collapse or how algorithmic stablecoins work
contract LunaProtocol {
    //address of luna token contract
    address luna;
    //address of ust token contract
    address ust;
    //address of chainlinks priceConsumerV3 contract
    address priceConsumerV3;
    /*because its on the testnet and tokens have no price,
    lets assume that market cap of Luna is all the time the same: 1000 Usd
    just the price of Luna will change over time, because of the inflation (or deflation) of Luna */
    uint256 lunaMarketCap;
    uint256 toWei = 1000000000000000000;

    constructor() {
        lunaMarketCap = 1000*toWei;
        luna = address(new Luna());
        ust = address(new Ust());
        priceConsumerV3 = address(new PriceConsumerV3());
    }

    function getLunaAddress() public view returns(address) {
        return luna;
    }

    function getUstAddress() public view returns(address) {
        return ust;
    }

    /*simulation of how you can buy algorithmic stablecoin,
    buy Ust for Luna */
    function buyUst(uint256 amountOfUst) public {
        amountOfUst *= toWei;
        uint256 amountOfLuna = amountOfUst/getLunaPrice();
        ERC20(luna).transferFrom(msg.sender, address(this), amountOfLuna);
        Ust(ust).mint(msg.sender, amountOfUst);
        Luna(luna).burn(amountOfLuna);
    }

    /*simulation of how you can sell algorithmic stablecoin,
    sell Ust for Luna */
    function sellUst(uint256 amountOfUst) public {
        amountOfUst *= toWei;
        uint256 amountOfLuna = amountOfUst/getLunaPrice();
        ERC20(ust).transferFrom(msg.sender, address(this), amountOfUst);
        Luna(luna).mint(msg.sender, amountOfLuna);
        Ust(ust).burn(amountOfUst);
    }

    function getLunaMarketCap() public view returns(uint256) {
        return lunaMarketCap;
    }

    //get price of one Luna coin
    function getLunaPrice() public view returns(uint256) {
        return (lunaMarketCap/ERC20(luna).totalSupply());
    }

    //for testing purposes you can get this token in this way
    function getTestLuna(uint256 amountOfLuna) public {
        Luna(luna).mint(msg.sender, amountOfLuna*toWei);
    }

    //for testing purposes you can get this token in this way
    function getTestUst(uint256 amountOfUst) public {
        Ust(ust).mint(msg.sender, amountOfUst*toWei);
    }


    //in the end we didnt use real prices, so we didnt use this function
    function getEthPrice() public view returns(uint256) {
        return uint256(PriceConsumerV3(priceConsumerV3).getLatestPrice()*10000000000/1000000000000000000);
    }
}
