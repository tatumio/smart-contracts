const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const {expect, assert} = require('chai')
const {BigNumber} = require('bignumber.js');

const range = (from, to ) => to - from + 1

describe('CustodialWalletFactoryV2 contract', ()=> {
    async function deployFactoryFixture() {
        const CustodialWalletFactoryV2 = await ethers.getContractFactory("CustodialWalletFactoryV2");
        const [owner] = await ethers.getSigners();
    
        const custodialWalletFactory = await CustodialWalletFactoryV2.deploy();
    
        await custodialWalletFactory.deployed();
        return { CustodialWalletFactoryV2, custodialWalletFactory, owner};
      }

      it("Should generate single predicted address", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const [addr, exists, salt] = await custodialWalletFactory.getWallet(owner.address, from);
        expect(exists).to.equal(false);
      });


      it("Should generate and activate single predicted address", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const [addr, exists, salt] = await custodialWalletFactory.getWallet(owner.address, from);

        await expect(custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000}))
      });

      it("Should revert if an address is activated a second time", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;

        await custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000
        });

        await expect(custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000
        })).to.revertedWith("Wallet already exists")
      });


      it("Should exist after being activated", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        await custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000

        }).to.emit(custodialWalletFactory, "Created").withArgs(addr)
      });

      it("Should revert if an address is activated a second time", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;

        await custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000
        });

        await expect(custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000
        })).to.revertedWith("Wallet already exists")
      });


      it("Should exist after being activated", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        await custodialWalletFactory.create(owner.address, from, {
            gasLimit: 1000000
        });

        const [addr, exists, salt] = await custodialWalletFactory.getWallet(owner.address, from);

        assert(exists)
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
        expect(range(from, to)).to.equal(addr.length);
      });


      it("Should activate predicted addresses", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const to = 10;

        const indexes = Array.from(Array(range(from, to)).keys()).map(val => `0x${new BigNumber(val + from).toString(16)}`);
    
        expect(await custodialWalletFactory.createBatch(owner.address, indexes)).to.emit(custodialWalletFactory, "Created")
      });

      it("Should emit CreateFailed event for address overlaps", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const to = 10;

        const from2 = 5;
        const to2 = 15

        const indexes = Array.from(Array(range(from, to)).keys()).map(val => `0x${new BigNumber(val + from).toString(16)}`);
        await custodialWalletFactory.createBatch(owner.address, indexes)

        const indexes2 = Array.from(Array(range(from2, to2)).keys()).map(val => `0x${new BigNumber(val + from2).toString(16)}`);
    
        expect(await custodialWalletFactory.createBatch(owner.address, indexes2)).to.emit(custodialWalletFactory, "CreateFailed")

      });


      it("Should activate predicted addresses", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const to = 10;

        const indexes = Array.from(Array(range(from, to)).keys()).map(val => `0x${new BigNumber(val + from).toString(16)}`);
    
        expect(await custodialWalletFactory.createBatch(owner.address, indexes)).to.emit(custodialWalletFactory, "Created")
      });

      it("Should emit CreateFailed event for address overlaps", async function () {
        const { custodialWalletFactory, owner } = await loadFixture(deployFactoryFixture);
        const from  = 1;
        const to = 10;

        const from2 = 5;
        const to2 = 15

        const indexes = Array.from(Array(range(from, to)).keys()).map(val => `0x${new BigNumber(val + from).toString(16)}`);
        await custodialWalletFactory.createBatch(owner.address, indexes)

        const indexes2 = Array.from(Array(range(from2, to2)).keys()).map(val => `0x${new BigNumber(val + from2).toString(16)}`);
    
        expect(await custodialWalletFactory.createBatch(owner.address, indexes2)).to.emit(custodialWalletFactory, "CreateFailed")
      });

      
});