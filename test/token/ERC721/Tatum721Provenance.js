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
            await token.mintWithTokenURI(a1, "1", "test.com",[],[],[])
            const c = await token.safeTransfer(a2, "1", "0x74657374696e672727272323232727273230303030", {from: a1})

            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing",
                value:new BN(20000)
            })

        });
        it('check ERC721 transfer data with cashback', async function () {
            const token = await ERC721.new(name, symbol);
            await token.mintWithTokenURI(a1, "1", "test.com", [a1,a2], [new BN(1),new BN(1)],[new BN(1),new BN(1)])
            const c = await token.safeTransfer(a2, "1", "0x74657374696e672727272323232727273230303030",{from: a1, value: 10200})
            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing",
                value:new BN(20000)
            })
        });
        it('check ERC721 mint multiple with cashback', async function () {
            const token = await ERC721.new(name, symbol);
            await token.mintMultiple([a1,a1], ["1","2"], ["test.com","test.com"], [[a1,a2],[a1,a2]], [[new BN(10),new BN(10)],[new BN(10),new BN(10)]],[[new BN(20),new BN(20)],[new BN(20),new BN(20)]]);

            const c1 = await token.safeTransfer(a2, "1", "0x74657374696e672727272323232727273230303030",{from: a1, value: 10200})
            expectEvent(c1, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing",
                value:new BN(20000)
            })
            const c2 = await token.safeTransfer(a2, "2", "0x74657374696e672727272323232727273230303030",{from: a1, value: 10200})
            expectEvent(c2, 'TransferWithProvenance', {
                id: "2",
                owner: a2,
                data: "testing",
                value:new BN(20000)
            })
        });
    });

});
