pragma solidity ^0.8.0;

/*
We want to be able to generate random Hereos.
The user gets to put in their class of hereo on generation
classes: Mage, Healer, Barbarian
Class will not influence stats created, therefore getting an epic hero will be hard.
stats are randomly generated
A scale of 1 - 18
The stats are randomly picked and their amplitude is randomly determined according to the following:
Stat 1 can max at 18
Stat 2 can max at 17
Stat 3 can max at 16
...
You could imagine these being an NFT
They are non divisable
*/

contract Hero {
    enum Class {Mage, Healer, Barbarian}

    mapping(address => uint[]) addressToHeroes;

    function getHeroes() public view returns (uint[] memory) {
        return addressToHeroes[msg.sender];
    }

    function getStrength(uint hero) public pure returns (uint32) {
        /* Lop off rightmost two bits (character class), then
           bitwise AND it to select out the 5 bit "Strength" attr
        */
        return uint32((hero >> 2) & 0x1F);  // Ox1F == 11111 (31 in binary)
    }

    function getHealth(uint hero) public pure returns (uint32) {
        return uint32((hero >> 7) & 0x1F);
    }

    function getDexterity(uint hero) public pure returns (uint32) {
        return uint32((hero >> 12) & 0x1F);
    }

    function getIntellect(uint hero) public pure returns (uint32) {
        return uint32((hero >> 17) & 0x1F);
    }

    function getMagic(uint hero) public pure returns (uint32) {
        return uint32((hero >> 22) & 0x1F);
    }

    function generateRandom() public virtual view returns (uint) {
        return uint(keccak256(abi.encodePacked(
            block.difficulty, block.timestamp)));
    }

    function createHero(Class class) public payable {
        require(msg.value >= 0.05 ether, "Please send more money");

        /*
           This makes use of how bits are stored.

           `class` values are 0, 1, 2:  therefore, 2 bits needed to store class.

           Stats have a MAX value of 18: so 5 bits needed to store.
                -- so, separate each stat by 5 bits.

           "Strength", our first stat, starts at index 2 (which is 3rd bit).

          BITS:
          =====

          27      22          17          12       7          2              0
         /       /           /           /        /          /              /
         |       |           |           |        |          |              |
         | Magic | Intellect | Dexterity | Health | Strength | [Hero Class] |

         ^
         |
         |__ These 27 bits will represent a `hero` instance.

         Our `hero` is a `uint` (unsigned 256 bit int), that starts off with
         a value of 0, 1, or 2.

         Then we'll randomly generate each stat and bitwise OR them into `hero`,
         bit shifting them (`<<`) to correct location.
        */

        // TODO: examples for bitwise OR (|), AND (&), and shifting (<<) ??

        uint[] memory stats = new uint[](5);
        stats[0] = 2;   // strength
        stats[1] = 7;   // health
        stats[2] = 12;  // dexterity
        stats[3] = 17;  // intellect
        stats[4] = 22;  // magic

        uint len = 5;
        uint hero = uint(class);

        /* 1. pick a random index into `stats` array
           2. generate a stat value (max of 18, decreasing by 1 each loop)
           3. store stat on hero
           4. remove chosen stat from available pool

               ex. (two loops)
               - loop 1
                    // all stats available; array length is 5
                    1. [S, H, D, I, M]
                    2. [S, H, D, I, M] // "Health" stat randomly chosen
                           ^
                           |
                    3. [S, M, D, I, M] // remove "H" from availalbe stats
                                       // (overwrite with "end" of array --
                                       //  the index represented by `len`)
               - loop 2
                    // "Health" stat no longer available
                    // array length now 4
                    1. [S, M, D, I, M]
                    2. [S, M, D, I, M] // "Strength" stat randomly chosen
                        ^
                        |
                    3. [I, M, D, I, M] // remove "S" from available stats
        */
        do {
            uint index = generateRandom() % len;
            uint value = generateRandom() % (13 + len) + 1;

            // use bitwise OR write stat onto `hero`, shifting by the correct #
            // of bits (see method docstring)
            hero |= value << stats[index];

            /* overwrite selected `stats` index with last stat in array,
               based on `len` variable, thereby shortening available stats by 1;
            */
            len--;
            stats[index] = stats[len];

        } while (len > 0);

        // store hero
        addressToHeroes[msg.sender].push(hero);
    }

}
