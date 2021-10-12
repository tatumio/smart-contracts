const { BN, constants, expectEvent, balance } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { BigNumber } = require("ethers");

const ERC721 = artifacts.require('Tatum721Provenance');

contract('Tatum721Provenance', async function (accounts) {
    const name = 'My Token';
    const symbol = 'MTKN';
    const [a1, a2] = accounts
    describe('Should pass OK for ERC721', () => {

        it('check ERC721 metadata', async function () {
            const token = await ERC721.new(name, symbol);
            expect((await token.name()).toString()).to.be.equal(name)
            expect((await token.symbol()).toString()).to.be.equal(symbol)
        });

        it('check ERC721 mint and transfer without cashback', async function () {
            const token = await ERC721.new(name, symbol);
            //const owner = await token.caller();
            await token.mintWithTokenURI(a1, "1", "test.com")
            const c = await token.safeTransfer(a2, "1", "testing'''###'''2", {from: a1})

            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing'''###'''2"
            })

        });
        it('check ERC721 transfer data with cashback', async function () {
            const token = await ERC721.new(name, symbol);
            await token.mintWithCashback(a1, "1", "test.com", [a1,a2], [new BN(10),new BN(10)],[new BN(20),new BN(20)])
            const c = await token.safeTransfer(a2, "1", "testing'''###'''200",{from: a1, value: 10200})
            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing'''###'''200"
            })
        });
    });

});
