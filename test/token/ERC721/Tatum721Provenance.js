const { BN, constants, expectEvent, balance } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { BigNumber } = require("ethers");
const ERC721Mock = artifacts.require('Tatum721');
const ERC721 = artifacts.require('Tatum721Provenance');
const ERC20Mock = artifacts.require('ERC20Mock');
contract('Tatum721Provenance', async function (accounts) {
    const name = 'My Token';
    const symbol = 'MTKN';
    const [a1, a2, a3] = accounts
    describe('Should pass OK for ERC721', () => {

        it('check ERC721 metadata', async function () {
            const token = await ERC721.new(name, symbol);
            expect((await token.name()).toString()).to.be.equal(name)
            expect((await token.symbol()).toString()).to.be.equal(symbol)
        });

        it('check ERC721 transfer data with cashback', async function () {
            const token = await ERC721.new(name, symbol);
            await token.mintWithTokenURI(a1, "1", "test.com", [],[],[])

            const c = await token.safeTransfer(a2, "1", "0x74657374696e6727272723232327272731303030",{ from: a1, value: 102000 })
            expectEvent(c, 'TransferWithProvenance', {
                id: "1",
                owner: a2,
                data: "testing",
                value: new BN(1000)
            })
        });
        it('check ERC721 transfers without cashback', async function () {
            const name = 'My Token';
            const symbol = 'MTKN';

            const initialSupply = new BN(100000000000);

            const erc = await ERC20Mock.new(name, symbol, a1, initialSupply);

            let bufStr = Buffer.from(("CUSTOMTOKEN" + erc.address + `'''###'''1`), 'utf8');
            const token = await ERC721Mock.new(name, symbol);
            await erc.transfer(a3, 20000, { from: a1 });
            await erc.approve(token.address, 20000, { from: a1 });

            await token.mintMultiple([a1, a1], ["1", "2"], ["test.com", "test.com"]);
            await token.safeTransfer(a2, "1", '0x' + bufStr.toString('hex'), { from: a1 })
            await token.approve(a2, '2', { from: a1 })
            await erc.approve(token.address, 2000, { from: a3 });
            await token.safeTransferFrom(a1, a3, "2", '0x' + bufStr.toString('hex', { from: a2 }))
        });
        it('check ERC721 provenance transfers with CUSTOM cashback', async function () {
            const name = 'My Token';
            const symbol = 'MTKN';

            const initialSupply = new BN(1000000000000);

            const erc = await ERC20Mock.new(name, symbol, a1, initialSupply);

            let bufStr = Buffer.from(("CUSTOMTOKEN" + erc.address + `'''###'''1000`), 'utf8');
            const token = await ERC721.new(name, symbol);
            await erc.transfer(a3, 20000, { from: a1 });
            await erc.approve(token.address, 20000, { from: a1 });
            await erc.transfer(token.address, 20000, { from: a1 });
                        
            await token.mintMultiple([a1, a1], ["1", "2"], ["test.com", "test.com"], [[a1, a2], [a1, a2]], [[new BN(10), new BN(10)], [new BN(10), new BN(10)]], [[new BN(10), new BN(10)], [new BN(10), new BN(10)]],erc.address);
            await token.safeTransfer(a2, "1", '0x' + bufStr.toString('hex'), { from: a1})

            await token.approve(a2, '2', { from: a1 })
            await erc.approve(token.address, 2000, { from: a3 });
            await token.safeTransferFrom(a1, a3, "2", '0x' + bufStr.toString('hex', { from: a2 }))
        });
    });

});
