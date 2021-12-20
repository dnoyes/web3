import "@nomiclabs/hardhat-ethers";
import {ethers} from "hardhat";

async function deploy() {
    // get info sufficient to deploy to a network
    const HelloWorld = await ethers.getContractFactory("HelloWorld");
    // json rpc request to some network
    const hello = await HelloWorld.deploy();
    // when consensus reached, network lets us know
    await hello.deployed();

    return hello;
}

// @ts-ignore
async function sayHello(hello) {
    // hit network, execute contract function, get back result
    console.log("say hello: ", await hello.hello());
}

deploy().then(sayHello);
