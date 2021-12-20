import "@nomiclabs/hardhat-ethers";
import {ethers} from "hardhat";
import {expect} from "chai";

describe("hello world", () => {
    it("should say hello, world", async () => {
        const HelloWorld = await ethers.getContractFactory("HelloWorld");

        /* Hardhat will:
         *  1. spin up local, private network
         *  2. deploy to network
         *  3. allow for consensus
         *  4. tear down network when done
         */
        const hello = await HelloWorld.deploy();
        await hello.deployed(); // confirm it's on network

        expect(await hello.hello()).to.equal("Hello, World");
    });
});
