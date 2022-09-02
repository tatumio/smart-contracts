const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect, assert} = require('chai')
const {BigNumber} = require('bignumber.js');

describe('CustodialWalletFactoryV2 contract', ()=> {
    async function deployFactoryFixture() {
        const CustodialWalletFactoryV2 = await ethers.getContractFactory("CustodialWalletFactoryV2");
        const [owner, addr1, addr2] = await ethers.getSigners();
    
        const custodialWalletFactory = await CustodialWalletFactoryV2.deploy();
    
        await custodialWalletFactory.deployed();
        return { CustodialWalletFactoryV2, custodialWalletFactory, owner, addr1, addr2 };
      }

      it("Should generate single predicted address", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const [addr, exists, salt] = await custodialWalletFactory.getWallet(owner.address, from);
        expect(exists).to.equal(false);
        assert(addr !== 0)
      });


      it("Should generate and create single predicted address", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const [addr, exists, salt] = await custodialWalletFactory.getWallet(owner.address, from);

        await expect(custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000
        })).to.emit(custodialWalletFactory, "Created").withArgs(anyValue, 1)
      });


      it("Generated predicted address should always be equal", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const [addr1, ...rest] = await custodialWalletFactory.getWallet(owner.address, from);
        const [addr2, ...rest2] = await custodialWalletFactory.getWallet(owner.address, from);
        expect(addr1).to.equal(addr2);
      });

      it("Should generate predicted addresses", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const to = 10;

        const indexes = Array.from(Array(to - from + 1).keys()).map(val => `0x${new BigNumber(val + from).toString(16)}`);
    
        const [addr, exists, salt] = await custodialWalletFactory.getWallets(owner.address, indexes);
        expect(to-from + 1).to.equal(addr.length);
      });
});