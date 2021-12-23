import {ethers} from "ethers";
import Counter from "../artifacts/contracts/Counter.sol/Counter.json";

function getEth() {
    // @ts-ignore
    const eth = window.ethereum;

    if(!eth) {
        throw new Error("eth not found!");
    }

    return eth;
}

async function hasAccounts() {
    const eth = getEth();
    const accounts = await eth.request({method: "eth_accounts"}) as string[];

    return accounts.length > 0;
}

async function requestAccounts() {
    const eth = getEth();
    const accounts = await eth.request({method: "eth_requestAccounts"}) as string[];

    return accounts.length > 0;
}

async function run() {
    if (!await hasAccounts() && !await requestAccounts()) {
        throw new Error("can't access accounts!");
    }

    const testAccountAddress = process.env.CONTRACT_ADDRESS;

    const counter = new ethers.Contract(
        testAccountAddress, // address
        Counter.abi, // interface
        new ethers.providers.Web3Provider(getEth()).getSigner() // signer/provider
    );

    wireCounter(counter);
}

async function wireCounter(contract) {
    // create result container
    const result = document.createElement("div");
    result.id = "result";

    // wire up 'incrementer' button
    const button = document.createElement("button");
    button.innerText = "increment!";
    button.onclick = async () => {await contract.count()};

    // listen for "incremented" event
    contract.on(contract.filters.CounterInc(), displayCount);

    document.body.append(result);
    document.body.append(button);

    // show initial count
    displayCount(await contract.getCounter());
}

async function displayCount(count) {
    document.getElementById("result").textContent = count;
    console.log("wow! did it!");
}

run();
