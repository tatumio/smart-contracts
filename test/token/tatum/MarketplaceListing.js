const {BN, constants, expectEvent, expectRevert, balance} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');
const {BigNumber} = require("ethers");
const {ZERO_ADDRESS} = constants;

const MarketplaceListing = artifacts.require('MarketplaceListing');
const ERC721Mock = artifacts.require('ERC721Mock');
const ERC1155Mock = artifacts.require('ERC1155Mock');
const ERC20Mock = artifacts.require('ERC20Mock');

contract('MarketplaceListing', function (accounts) {
    const [marketOwner, seller, buyer, marketOwner1155, seller1155, buyer1155 ] = accounts;


    const name = 'My Token';
    const symbol = 'MTKN';

    describe('Should pass OK marketplace journeys', () => {
        it('create OK ERC721 listing for native asset', async function () {
            const token = await ERC721Mock.new(name, symbol);
            const fee = new BN(100); // 1%

            expect((await balance.current(buyer, 'ether')).toString()).to.be.equal('10000')
            expect((await balance.current(seller, 'ether')).toString()).to.be.equal('10000')
            expect((await balance.current(marketOwner, 'ether')).toString()).to.be.equal('10000')

            const marketplace = await MarketplaceListing.new(200, marketOwner);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(new BN(200).toString());
            await marketplace.setMarketplaceFee(fee);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller, tokenId);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', true, nftAddress, tokenId, 10000, seller, 1, ZERO_ADDRESS)

            expectEvent(c, 'ListingCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                price: new BN(10000),
                erc20Address: ZERO_ADDRESS
            })
            await token.safeTransferFrom(seller, marketplace.address, tokenId, {from: seller});

            expect(await token.ownerOf(tokenId)).to.be.equal(marketplace.address);

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');
            expect((await balance.current(buyer, 'ether')).toString()).to.be.equal('10000')
            const sellerBalance = (await balance.current(seller)).toString();
            const marketBalance = (await balance.current(marketOwner)).toString();
            const b = await marketplace.buyAssetFromListing('1', ZERO_ADDRESS, {from: buyer, value: 10100});
            listings = await marketplace.getListing('1');
            expect(listings[2]).to.be.equal('1');
            expect(listings[9]).to.be.equal(buyer);
            expectEvent(b, 'ListingSold', {
                buyer,
            })
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
            expect((await balance.current(marketOwner)).toString()).to.be.equal(BigNumber.from(marketBalance).add(100).toString())
            expect((await balance.current(seller)).toString()).to.be.equal(BigNumber.from(sellerBalance).add(10000).toString())
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
        });
        it('create OK ERC721 listing for ERC20 asset', async function () {
            const token = await ERC721Mock.new(name, symbol);
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer, 1000000)
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')

            const marketplace = await MarketplaceListing.new(200, marketOwner);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(new BN(200).toString());
            await marketplace.setMarketplaceFee(fee);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller, tokenId);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', true, nftAddress, tokenId, 10000, seller, 1, erc20.address)

            expectEvent(c, 'ListingCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                price: new BN(10000),
                erc20Address: erc20.address
            })
            await token.safeTransferFrom(seller, marketplace.address, tokenId, {from: seller});

            expect(await token.ownerOf(tokenId)).to.be.equal(marketplace.address);

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')

            await erc20.approve(marketplace.address, new BN(10100), {from: buyer})

            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            const b = await marketplace.buyAssetFromListing('1', erc20.address, {from: buyer});
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('989900')
            listings = await marketplace.getListing('1');
            expect(listings[2]).to.be.equal('1');
            expect(listings[9]).to.be.equal(buyer);
            expectEvent(b, 'ListingSold', {
                buyer,
            })
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('10000')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('100')
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
        });
        it('create OK ERC1155 listing for native asset', async function () {
            const token = await ERC1155Mock.new('https://token-cdn-domain/{id}.json');
            const fee = new BN(100); // 1%

            expect((await balance.current(buyer1155, 'ether')).toString()).to.be.equal('10000')
            expect((await balance.current(seller1155, 'ether')).toString()).to.be.equal('10000')
            expect((await balance.current(marketOwner1155, 'ether')).toString()).to.be.equal('10000')

            const marketplace = await MarketplaceListing.new(200, marketOwner1155);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(new BN(200).toString());
            await marketplace.setMarketplaceFee(fee);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller1155, tokenId, new BN(10), 0x0);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', false, nftAddress, tokenId, 10000, seller1155, 5, ZERO_ADDRESS)

            expectEvent(c, 'ListingCreated', {
                isErc721: false,
                nftAddress,
                tokenId,
                amount: new BN(5),
                price: new BN(10000),
                erc20Address: ZERO_ADDRESS
            })
            await token.safeTransferFrom(seller1155, marketplace.address, tokenId, new BN(5), 0x0, {from: seller1155});

            expect((await token.balanceOf(marketplace.address, tokenId)).toString()).to.be.equal('5');

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');
            expect((await balance.current(buyer1155, 'ether')).toString()).to.be.equal('10000')
            const seller1155Balance = (await balance.current(seller1155)).toString();
            const marketBalance = (await balance.current(marketOwner1155)).toString();

            const b = await marketplace.buyAssetFromListing('1', ZERO_ADDRESS, {from: buyer1155, value: 10100});
            listings = await marketplace.getListing('1');
            expect(listings[2]).to.be.equal('1');
            expect(listings[9]).to.be.equal(buyer1155);
            expectEvent(b, 'ListingSold', {
                buyer: buyer1155,
            })

            expect((await token.balanceOf(buyer1155, tokenId)).toString()).to.be.equal('5');
            expect((await balance.current(marketOwner1155)).toString()).to.be.equal(BigNumber.from(marketBalance).add(100).toString())
            expect((await balance.current(seller1155)).toString()).to.be.equal(BigNumber.from(seller1155Balance).add(10000).toString())
        });
        it('create OK ERC1155 listing for ERC20 asset', async function () {
            const token = await ERC1155Mock.new('https://token-cdn-domain/{id}.json');
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer1155, 1000000)
            expect((await erc20.balanceOf(buyer1155)).toString()).to.be.equal('1000000')

            const marketplace = await MarketplaceListing.new(200, marketOwner1155);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(new BN(200).toString());
            await marketplace.setMarketplaceFee(fee);
            expect((await marketplace.getMarketplaceFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller1155, tokenId, new BN(10), 0x0);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', false, nftAddress, tokenId, 10000, seller1155, 5, erc20.address)

            expectEvent(c, 'ListingCreated', {
                isErc721: false,
                nftAddress,
                tokenId,
                amount: new BN(5),
                price: new BN(10000),
                erc20Address: erc20.address
            })
            await token.safeTransferFrom(seller1155, marketplace.address, tokenId, new BN(5), 0x0, {from: seller1155});

            expect((await token.balanceOf(marketplace.address, tokenId)).toString()).to.be.equal('5');

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');
            expect((await erc20.balanceOf(buyer1155)).toString()).to.be.equal('1000000')

            await erc20.approve(marketplace.address, new BN(10100), {from: buyer1155})
            expect((await erc20.balanceOf(seller1155)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner1155)).toString()).to.be.equal('0')
            const b = await marketplace.buyAssetFromListing('1', erc20.address, {from: buyer1155});
            expect((await erc20.balanceOf(buyer1155)).toString()).to.be.equal('989900')
            listings = await marketplace.getListing('1');
            expect(listings[2]).to.be.equal('1');
            expect(listings[9]).to.be.equal(buyer1155);
            expectEvent(b, 'ListingSold', {
                buyer: buyer1155,
            })
            expect((await token.balanceOf(buyer1155, tokenId)).toString()).to.be.equal('5');
            expect((await erc20.balanceOf(seller1155)).toString()).to.be.equal('10000')
            expect((await erc20.balanceOf(marketOwner1155)).toString()).to.be.equal('100')
        });
    });
    describe('Should pass CANCELLED marketplace journeys', () => {
        it('cancel OK ERC721 listing for native asset from seller', async function () {
            const token = await ERC721Mock.new(name, symbol);
            const marketplace = await MarketplaceListing.new(200, marketOwner);

            const tokenId = new BN(1);
            await token.mint(seller, tokenId);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', true, nftAddress, tokenId, 10000, seller, 1, ZERO_ADDRESS)

            expectEvent(c, 'ListingCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                price: new BN(10000),
                erc20Address: ZERO_ADDRESS
            })
            await token.safeTransferFrom(seller, marketplace.address, tokenId, {from: seller});

            expect(await token.ownerOf(tokenId)).to.be.equal(marketplace.address);

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');

            const b = await marketplace.cancelListing('1', {from: seller});
            listings = await marketplace.getListing('1');

            expect(listings[2]).to.be.equal('2');
            expect(await token.ownerOf(tokenId)).to.be.equal(seller);
            expectEvent(b, 'ListingCancelled')
        });
        it('cancel OK ERC721 listing for native asset from owner', async function () {
            const token = await ERC721Mock.new(name, symbol);

            const marketplace = await MarketplaceListing.new(200, marketOwner);

            const tokenId = new BN(1);
            await token.mint(seller, tokenId);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', true, nftAddress, tokenId, 10000, seller, 1, ZERO_ADDRESS)

            expectEvent(c, 'ListingCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                price: new BN(10000),
                erc20Address: ZERO_ADDRESS
            })
            await token.safeTransferFrom(seller, marketplace.address, tokenId, {from: seller});

            expect(await token.ownerOf(tokenId)).to.be.equal(marketplace.address);

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');

            const b = await marketplace.cancelListing('1', {from: seller});
            listings = await marketplace.getListing('1');

            expect(listings[2]).to.be.equal('2');
            expect(await token.ownerOf(tokenId)).to.be.equal(seller);
            expectEvent(b, 'ListingCancelled')
        });
        it('cancel not OK ERC721 listing for native asset from buyer', async function () {
            const token = await ERC721Mock.new(name, symbol);

            const marketplace = await MarketplaceListing.new(200, marketOwner);

            const tokenId = new BN(1);
            await token.mint(seller, tokenId);

            const nftAddress = token.address;
            const c = await marketplace.createListing('1', true, nftAddress, tokenId, 10000, seller, 1, ZERO_ADDRESS)

            expectEvent(c, 'ListingCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                price: new BN(10000),
                erc20Address: ZERO_ADDRESS
            })
            await token.safeTransferFrom(seller, marketplace.address, tokenId, {from: seller});

            expect(await token.ownerOf(tokenId)).to.be.equal(marketplace.address);

            let listings = await marketplace.getListing('1');
            expect(listings[0]).to.be.equal('1');
            expect(listings[2]).to.be.equal('0');

            try {
                const b = await marketplace.cancelListing('1', {from: buyer});
                fail('Should not pass')
            } catch (e) {
            }
        });
    });
});
