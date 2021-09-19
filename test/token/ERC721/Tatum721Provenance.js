const { BN, constants, expectEvent, balance } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { BigNumber } = require("ethers");

const ERC271 = artifacts.require('Tatum721Provenance');

contract('Tatum721Provenance', async function (accounts) {
    const name = 'My Token';
    const symbol = 'MTKN';
    const [a1, a2] = accounts
    describe('Should pass OK for ERC721', () => {

        it('check ERC721 metadata', async function () {
            const token = await ERC271.new(name, symbol);
            expect((await token.name()).toString()).to.be.equal(name)
            expect((await token.symbol()).toString()).to.be.equal(symbol)
            console.log("NAME", name, "SYMBOL", symbol)
        });

        it('check ERC721 mint and transfer without cashback', async function () {
            const token = await ERC271.new(name, symbol);
            const owner = await token.caller();
            await token.mintWithTokenURI(owner, "1", "test.com")
            const c = await token.safeTransfer(a2, "1", "testing123", 2)

            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing123",
                value: new BN(2)
            })

        });
        it('check ERC721 transfer data with cashback', async function () {
            const token = await ERC271.new(name, symbol);
            const owner = await token.caller();
            await token.mintWithCashback(owner, "1", "test.com", [a1, a2], [new BN(10), new BN(20)])
            const c = await token.safeTransfer(a2, "1", "testing123", 2)

            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing123",
                value: new BN(2)
            })
        });
    });

});
