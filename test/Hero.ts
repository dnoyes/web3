import "@nomiclabs/hardhat-ethers";
import {ethers} from "hardhat";
import {expect} from "chai";

describe("Hero", () => {
    async function createTestHero() {
        const Hero = await ethers.getContractFactory("TestHero");
        const hero = await Hero.deploy();
        await hero.deployed();

        return hero;
    }

    let hero;

    before(async () => {
        hero = await createTestHero();
    });

    it("should fail at creating hero because of payment", async () => {
        let e;
        try {
            await hero.createHero(0, {
                value: ethers.utils.parseEther("0.049999999")
            });
        } catch (err) {
            e = err;
        }

        expect(e.message.includes("Please send more money")).to.equal(true);
    });

    it("should get an empty list of heroes", async () => {
        expect(await hero.getHeroes()).to.deep.equal([]);
    });

    it("should create hero", async () => {
        await hero.setRandom(69);

        // meets payment requirements
        await hero.createHero(0, {
            value: ethers.utils.parseEther("0.05")
        });

        const h = (await hero.getHeroes())[0];

        //1. [S, H, D, I, M] -- M: 16
        //2. [S, H, D, I] -- H: 2
        //3. [S, I, D] -- S: 6
        //4. [D, I] -- I: 10
        //5. [D] -- D: 14

        expect(await hero.getMagic(h)).to.equal(16);
        expect(await hero.getHealth(h)).to.equal(2);
        expect(await hero.getStrength(h)).to.equal(6);
        expect(await hero.getIntellect(h)).to.equal(10);
        expect(await hero.getDexterity(h)).to.equal(14);
    });
});
