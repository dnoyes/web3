pragma solidity ^0.8.0;

/*
    gas-cost * gas-used * 10^9 * eth-cost / 10^18
    // Or simplified as
    gas-cost * gas-used * eth-cost / 10^9

    https://github.com/cgewecke/hardhat-gas-reporter
*/

contract TestGas {
    uint a;
    uint b;
    uint c;

    function test1() public {
        a++;
    }

    function test2() public {
        a++;
        b++;
    }

    function test3() public {
        a++;
        b++;
        c++;
    }

    function test4() public {
        c = a + b;
    }

    function test5() public {
        test4();
        c = a + b;
    }
}
