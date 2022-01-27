const { BN, constants, expectEvent, balance, time } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { BigNumber } = require("ethers");
const { ZERO_ADDRESS } = constants;

const NftAuction = artifacts.require('NftAuction');
const ERC721Mock = artifacts.require('Tatum721');
const ERC1155Mock = artifacts.require('ERC1155Mock');
const ERC20Mock = artifacts.require('ERC20Mock');
const ERC721Provenance = artifacts.require('Tatum721Provenance')

contract('NftAuction', function (accounts) {
    const [a1, a2, a3, a4, a5, a6, marketOwner, seller, buyer, marketOwner1155, seller1155, buyer1155] = accounts;

    const name = 'My Token';
    const symbol = 'MTKN';

    describe('Should pass OK auction journeys', () => {
        it('create OK ERC721 auction for native asset', async function () {
            const token = await ERC721Mock.new(name, symbol, false);
            const fee = new BN(100); // 1%

            const auction = await NftAuction.new(200, marketOwner);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mintWithTokenURI(seller, tokenId, 'test.com');

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.approve(auction.address, tokenId, { from: seller });
            expect(await token.ownerOf(tokenId)).to.be.equal(seller);

            const c = await auction.createAuction('1', true, nftAddress, tokenId, seller, 1, endedAt, ZERO_ADDRESS)

            try {
                await auction.setAuctionFee(fee);
                fail('Should not update fee when auction is present')
            } catch (_) {
            }
            expectEvent(c, 'AuctionCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: ZERO_ADDRESS,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(true);
            expect(auctions[6]).to.be.equal(ZERO_ADDRESS);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);
            // expect((await balance.current(buyer, 'ether')).toString()).to.be.equal('10000')
            const sellerBalance = (await balance.current(seller)).toString();
            const marketBalance = (await balance.current(marketOwner)).toString();

            const b = await auction.bid('1', 10200, { from: buyer, value: 10200 });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer);
            expectEvent(b, 'AuctionBid', {
                buyer,
            })
            expect((await balance.current(auction.address)).toString()).to.be.equal('10200')
            expect((await balance.current(marketOwner)).toString()).to.be.equal(marketBalance.toString())
            expect((await balance.current(seller)).toString()).to.be.equal(sellerBalance.toString())

            await time.advanceBlockTo(endedAt.add(new BN(1)))

            const s = await auction.settleAuction('1');
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
            expect((await balance.current(marketOwner)).toString()).to.be.equal(BigNumber.from(marketBalance).add(102).toString())
            expect((await balance.current(seller)).toString()).to.be.equal(BigNumber.from(sellerBalance).add(10098).toString())
        });
        it('create OK ERC721 Provenance auction for ERC20 asset with eth cashbacks', async function () {
            const token = await ERC721Provenance.new(name, symbol, false);
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer, 1000000)
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')

            const auction = await NftAuction.new(200, marketOwner);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            expect((await balance.current(auction.address, 'ether')).toString()).to.be.equal('0')

            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mintMultiple([seller, seller], [tokenId, tokenId + 1], ["test.com", "test.com"], [[a1, a2], [a1, a2]], [[new BN(10), new BN(10)], [new BN(10), new BN(10)]], [[new BN(10), new BN(10)], [new BN(10), new BN(10)]]);

            const nftAddress = token.address;
            await erc20.transfer(auction.address, new BN(101000), { from: buyer })
            // await erc20.approve(token.address, new BN(101000), { from: buyer })

            await token.approve(auction.address, tokenId, { from: seller });
            expect(await token.allowance(auction.address, tokenId)).to.be.equal(true);
            const endedAt = (await time.latestBlock()).add(new BN(10));
            // await token.approve(auction.address, tokenId, {from: seller});
            // expect(await token.ownerOf(tokenId)).to.be.equal(seller);

            const c = await auction.createAuction('1', true, nftAddress, tokenId, seller, 1, endedAt, erc20.address)
            expectEvent(c, 'AuctionCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: erc20.address,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(true);
            expect(auctions[6]).to.be.equal(erc20.address);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);

            await erc20.approve(auction.address, new BN(10100), { from: buyer })
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('101000')
            expect((await balance.current(auction.address)).toString()).to.be.equal('0')
            const b = await auction.bid('1', 10100, { from: buyer, value: 10000 });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer);
            expectEvent(b, 'AuctionBid', {
                buyer,
            })
            const auctionBalance = (await balance.current(auction.address, 'ether'));
            expect(await token.allowance(auction.address, tokenId)).to.be.equal(true);
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('111100')

            await time.advanceBlockTo(endedAt.add(new BN(1)))
            // expect((await balance.current(auction.address, 'ether')).toString()).to.be.equal('40')
            const s = await auction.settleAuction('1');
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('9999')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('101')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('101000')
        });
        it('create OK ERC721 Provenance auction for ERC20 asset with cashbacks', async function () {
            const token = await ERC721Provenance.new(name, symbol, false);
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer, 1000000)
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')

            const auction = await NftAuction.new(200, marketOwner);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mintMultiple([seller, seller], [tokenId, tokenId + 1], ["test.com", "test.com"], [[a1, a2], [a1, a2]], [[new BN(10), new BN(10)], [new BN(10), new BN(10)]], [[new BN(10), new BN(10)], [new BN(10), new BN(10)]], erc20.address);

            const nftAddress = token.address;
            await erc20.transfer(auction.address, new BN(101000), { from: buyer })
            await erc20.approve(token.address, new BN(101000), { from: buyer })

            await token.approve(auction.address, tokenId, { from: seller });
            expect(await token.allowance(auction.address, tokenId)).to.be.equal(true);
            const endedAt = (await time.latestBlock()).add(new BN(10));
            // await token.approve(auction.address, tokenId, {from: seller});
            // expect(await token.ownerOf(tokenId)).to.be.equal(seller);

            const c = await auction.createAuction('1', true, nftAddress, tokenId, seller, 1, endedAt, erc20.address)

            expectEvent(c, 'AuctionCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: erc20.address,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(true);
            expect(auctions[6]).to.be.equal(erc20.address);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);

            await erc20.approve(auction.address, new BN(10100), { from: buyer })
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('101000')
            const b = await auction.bid('1', 10100, { from: buyer });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer);
            expectEvent(b, 'AuctionBid', {
                buyer,
            })

            expect(await token.allowance(auction.address, tokenId)).to.be.equal(true);
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('111100')

            await time.advanceBlockTo(endedAt.add(new BN(1)))

            const s = await auction.settleAuction('1');
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('9999')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('101')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('101000')
            expect((await erc20.balanceOf(a1)).toString()).to.be.equal('10')
            expect((await erc20.balanceOf(a2)).toString()).to.be.equal('10')
        });
        it('create OK ERC721 auction for ERC20 asset', async function () {
            const token = await ERC721Mock.new(name, symbol, false);
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer, 1000000)
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')

            const auction = await NftAuction.new(200, marketOwner);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mintWithTokenURI(seller, tokenId, "test.com");

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.approve(auction.address, tokenId, { from: seller });

            const c = await auction.createAuction('1', true, nftAddress, tokenId, seller, 1, endedAt, erc20.address)

            expectEvent(c, 'AuctionCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: erc20.address,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(true);
            expect(auctions[6]).to.be.equal(erc20.address);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);

            await erc20.approve(auction.address, new BN(10100), { from: buyer })
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('0')
            const b = await auction.bid('1', 10100, { from: buyer });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer);
            expectEvent(b, 'AuctionBid', {
                buyer,
            })

            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('10100')

            await time.advanceBlockTo(endedAt.add(new BN(1)))

            const s = await auction.settleAuction('1');
            expect(await token.ownerOf(tokenId)).to.be.equal(buyer);
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('9999')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('101')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('0')
        });
        it('create OK ERC1155 auction for native asset', async function () {
            const token = await ERC1155Mock.new('https://token-cdn-domain/{id}.json');
            const fee = new BN(100); // 1%

            expect((await balance.current(buyer1155, 'ether')).toString()).to.be.equal('10000')
            expect((await balance.current(seller1155, 'ether')).toString()).to.be.equal('10000')
            expect((await balance.current(marketOwner1155, 'ether')).toString()).to.be.equal('10000')

            const auction = await NftAuction.new(200, marketOwner1155);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller1155, tokenId, new BN(10), 0x0);

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.setApprovalForAll(auction.address, true, { from: seller1155 });
            expect((await token.balanceOf(seller1155, tokenId)).toString()).to.be.equal('10');

            const c = await auction.createAuction('1', false, nftAddress, tokenId, seller1155, 1, endedAt, ZERO_ADDRESS)

            expectEvent(c, 'AuctionCreated', {
                isErc721: false,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: ZERO_ADDRESS,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller1155);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(false);
            expect(auctions[6]).to.be.equal(ZERO_ADDRESS);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);
            expect((await balance.current(buyer1155, 'ether')).toString()).to.be.equal('10000')
            const seller1155Balance = (await balance.current(seller1155)).toString();
            const marketBalance = (await balance.current(marketOwner1155)).toString();

            const b = await auction.bid('1', 10200, { from: buyer1155, value: 10200 });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer1155);
            expectEvent(b, 'AuctionBid', {
                buyer: buyer1155,
            })
            expect((await balance.current(auction.address)).toString()).to.be.equal('10200')
            expect((await balance.current(marketOwner1155)).toString()).to.be.equal(marketBalance.toString())
            expect((await balance.current(seller1155)).toString()).to.be.equal(seller1155Balance.toString())

            await time.advanceBlockTo(endedAt.add(new BN(1)))

            const s = await auction.settleAuction('1');
            expect((await token.balanceOf(auction.address, tokenId)).toString()).to.be.equal('0');
            expect((await token.balanceOf(buyer1155, tokenId)).toString()).to.be.equal('1');
            expect((await token.balanceOf(seller1155, tokenId)).toString()).to.be.equal('9');
            expect((await balance.current(marketOwner1155)).toString()).to.be.equal(BigNumber.from(marketBalance).add(102).toString())
            expect((await balance.current(seller1155)).toString()).to.be.equal(BigNumber.from(seller1155Balance).add(10098).toString())
        });
        it('create OK ERC1155 auction for ERC20 asset', async function () {
            const token = await ERC1155Mock.new('https://token-cdn-domain/{id}.json');
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer1155, 1000000)
            expect((await erc20.balanceOf(buyer1155)).toString()).to.be.equal('1000000')

            const auction = await NftAuction.new(200, marketOwner1155);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller1155, tokenId, new BN(10), 0x0);

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.setApprovalForAll(auction.address, true, { from: seller1155 });
            expect((await token.balanceOf(seller1155, tokenId)).toString()).to.be.equal('10');

            const c = await auction.createAuction('1', false, nftAddress, tokenId, seller1155, 1, endedAt, erc20.address)

            expectEvent(c, 'AuctionCreated', {
                isErc721: false,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: erc20.address,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller1155);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(false);
            expect(auctions[6]).to.be.equal(erc20.address);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);

            await erc20.approve(auction.address, new BN(10100), { from: buyer1155 })
            expect((await erc20.balanceOf(seller1155)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner1155)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('0')
            const b = await auction.bid('1', 10100, { from: buyer1155 });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer1155);
            expectEvent(b, 'AuctionBid', {
                buyer: buyer1155,
            })

            expect((await erc20.balanceOf(seller1155)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner1155)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('10100')

            await time.advanceBlockTo(endedAt.add(new BN(1)))

            const s = await auction.settleAuction('1');
            expect((await token.balanceOf(auction.address, tokenId)).toString()).to.be.equal('0');
            expect((await token.balanceOf(buyer1155, tokenId)).toString()).to.be.equal('1');
            expect((await token.balanceOf(seller1155, tokenId)).toString()).to.be.equal('9');
            expect((await erc20.balanceOf(seller1155)).toString()).to.be.equal('9999')
            expect((await erc20.balanceOf(marketOwner1155)).toString()).to.be.equal('101')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('0')
        });
    });

    describe('Should pass NOK auction journeys - cancel auction, auction close, etc', () => {
        it('cancel ERC1155 auction for native asset', async function () {
            const token = await ERC1155Mock.new('https://token-cdn-domain/{id}.json');
            const fee = new BN(100); // 1%

            const auction = await NftAuction.new(200, marketOwner1155);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mint(seller1155, tokenId, new BN(10), 0x0);

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.setApprovalForAll(auction.address, true, { from: seller1155 });
            expect((await token.balanceOf(seller1155, tokenId)).toString()).to.be.equal('10');

            const c = await auction.createAuction('1', false, nftAddress, tokenId, seller1155, 1, endedAt, ZERO_ADDRESS)

            expectEvent(c, 'AuctionCreated', {
                isErc721: false,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: ZERO_ADDRESS,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller1155);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(false);
            expect(auctions[6]).to.be.equal(ZERO_ADDRESS);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);
            
            const seller1155Balance = (await balance.current(seller1155)).toString();
            const marketBalance = (await balance.current(marketOwner1155)).toString();
            const buyer1155Balance = (await balance.current(buyer1155)).toString();
            const b = await auction.bid('1', 10200, { from: buyer1155, value: 10200 });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer1155);
            
            expectEvent(b, 'AuctionBid', {
                buyer: buyer1155,
            })
            expect((await balance.current(auction.address)).toString()).to.be.equal('10200')
            expect((await balance.current(marketOwner1155)).toString()).to.be.equal(marketBalance.toString())
            expect((await balance.current(seller1155)).toString()).to.be.equal(seller1155Balance.toString())

            await time.advanceBlockTo(endedAt.add(new BN(1)))
            await auction.cancelAuction('1')
            expect((await token.balanceOf(buyer1155, tokenId)).toString()).to.be.equal('0');
        });
        it('cancel ERC721 auction for native asset', async function () {
            const token = await ERC721Mock.new(name, symbol, false);
            const auction = await NftAuction.new(200, marketOwner);

            const tokenId = new BN(1);
            await token.mintWithTokenURI(seller, tokenId, "test.com");

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.approve(auction.address, tokenId, { from: seller });
            expect(await token.ownerOf(tokenId)).to.be.equal(seller);

            const c = await auction.createAuction('1', true, nftAddress, tokenId, seller, 1, endedAt, ZERO_ADDRESS)

            expectEvent(c, 'AuctionCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: ZERO_ADDRESS,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(true);
            expect(auctions[6]).to.be.equal(ZERO_ADDRESS);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);
            const sellerBalance = (await balance.current(seller)).toString();
            const marketBalance = (await balance.current(marketOwner)).toString();

            const b = await auction.bid('1', 10200, { from: buyer, value: 10200 });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer);
            expectEvent(b, 'AuctionBid', {
                buyer,
            })
            expect((await balance.current(auction.address)).toString()).to.be.equal('10200')
            expect((await balance.current(marketOwner)).toString()).to.be.equal(marketBalance.toString())
            expect((await balance.current(seller)).toString()).to.be.equal(sellerBalance.toString())

            try {
                await auction.cancelAuction('1', { from: buyer })
                fail('Should not cancel from buyer');
            } catch (_) {
            }

            const buyerBalance = (await balance.current(buyer)).toString();
            await auction.cancelAuction('1')
            expect(await token.ownerOf(tokenId)).to.be.equal(seller);
            expect((await balance.current(marketOwner)).toString()).to.be.equal(BigNumber.from(marketBalance).toString())
            expect((await balance.current(seller)).toString()).to.be.equal(BigNumber.from(sellerBalance).toString())
            expect((await balance.current(buyer)).toString()).to.be.equal(BigNumber.from(buyerBalance).add(10200).toString())
        });
        it('cancel OK ERC721 auction for ERC20 asset', async function () {
            const token = await ERC721Mock.new(name, symbol, false);
            const fee = new BN(100); // 1%

            const erc20 = await ERC20Mock.new(name, symbol, buyer, 1000000)
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')

            const auction = await NftAuction.new(200, marketOwner);
            expect((await auction.getAuctionFee()).toString()).to.equal(new BN(200).toString());
            await auction.setAuctionFee(fee);
            expect((await auction.getAuctionFee()).toString()).to.equal(fee.toString());

            const tokenId = new BN(1);
            await token.mintWithTokenURI(seller, tokenId, "test.com");

            const nftAddress = token.address;
            const endedAt = (await time.latestBlock()).add(new BN(10));
            await token.approve(auction.address, tokenId, { from: seller });

            const c = await auction.createAuction('1', true, nftAddress, tokenId, seller, 1, endedAt, erc20.address)

            expectEvent(c, 'AuctionCreated', {
                isErc721: true,
                nftAddress,
                tokenId,
                amount: new BN(1),
                erc20Address: erc20.address,
                endedAt,
            })

            await time.advanceBlock();
            let auctions = await auction.getAuction('1');
            expect(auctions[0]).to.be.equal(seller);
            expect(auctions[1]).to.be.equal(nftAddress);
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[3]).to.be.equal(true);
            expect(auctions[6]).to.be.equal(erc20.address);
            expect(auctions[7]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('0');
            expect(auctions[9]).to.be.equal(ZERO_ADDRESS);

            await erc20.approve(auction.address, new BN(10100), { from: buyer })
            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('0')
            const b = await auction.bid('1', 10100, { from: buyer });
            auctions = await auction.getAuction('1');
            expect(auctions[2]).to.be.equal('1');
            expect(auctions[8]).to.be.equal('10000');
            expect(auctions[9]).to.be.equal(buyer);
            expectEvent(b, 'AuctionBid', {
                buyer,
            })

            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('10100')

            await time.advanceBlockTo(endedAt.add(new BN(1)))

            try {
                await auction.cancelAuction('1', { from: buyer })
                fail('Should not cancel from buyer');
            } catch (_) {
            }

            await auction.cancelAuction('1')
            expect(await token.ownerOf(tokenId)).to.be.equal(seller);

            expect((await erc20.balanceOf(seller)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(buyer)).toString()).to.be.equal('1000000')
            expect((await erc20.balanceOf(marketOwner)).toString()).to.be.equal('0')
            expect((await erc20.balanceOf(auction.address)).toString()).to.be.equal('0')
        });
    });
});
