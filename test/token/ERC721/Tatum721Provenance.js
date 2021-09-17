const {BN, constants, expectEvent, balance} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');
const {BigNumber} = require("ethers");

const ERC271 = artifacts.require('Tatum721Provenance');

contract('Tatum721Provenance', async function (accounts) {
    const name = 'My Token';
    const symbol = 'MTKN';
    const [a1,a2,a3]=accounts
    describe('Should pass OK for ERC721', () => {

        it('check ERC721 metadata', async function () {
            const token = await ERC271.new(name, symbol);        
            expect((await token.name()).toString()).to.be.equal(name)
            expect((await token.symbol()).toString()).to.be.equal(symbol)
            console.log("NAME",name,"SYMBOL",symbol)
        });
        it('check ERC721 mint data', async function () {
            const token = await ERC271.new(name, symbol);
            await token.mintWithTokenURI(a1,"1","test.com")
            expect(await token.tokenURI("1")).to.be.equal("test.com")
            expect((await token.tokensOfOwner(a1)).toString()).to.be.equal("1")
        });
        it('check ERC721 transfer data', async function () {
            const token = await ERC271.new(name, symbol);
            const owner=await token.caller();
            await token.mintWithTokenURI(owner,"1","test.com")
            const c=await token.safeTransfer(a2,"1","testing123",2)
            
            expectEvent(c, 'TransferWithProvenance', {
                id:"1",
                owner:owner,
                data:"testing123",
                value:  new BN(2)
            })
            expect((await token.gettokenData("1")).toString()).to.be.equal("testing123,2")

        });
    });

});
