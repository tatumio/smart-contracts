# <img src="https://tatum.io/images/Light.svg" alt="Tatum" height="40px">

# Tatum fork of awesome OpenZeppelin contracts library

**Tatum made some small changes to ERC-20, ERC-721 and ERC-1155 contracts and modified by their needs.**

* ERC-721 deployed by Tatum is one of the following:
    * [Tatum721General.sol](contracts/tatum/Tatum721General.sol) - Ownable OpenSea compatible NFT standard with batch
      mint functionalities
    * [Tatum721Cashback.sol](contracts/tatum/Tatum721Cashback.sol) - fixed price royalty cashback forced by blockchain -
      OpenSea not compatible
    * [Tatum721Provenance](contracts/tatum/Tatum721Provenance.sol) - percentage based royalties forced by blockchain -
      OpenSea not compatible

## Verify contracts on the explorers

In order to verify the smart contracts deployed using Tatum API, use the following steps:

#### Compiler version

* **0.5.17+commit.d19bba13 for ERC20 token on EVM chains**
* **0.8.18+commit.87f61d96 for ERC20, ERC721 EVM chains**
* **0.8.7+commit.e28d00a7 for ERC1155, NFT Auction and NFT Marketplace EVM chains**
* **tron_v0.5.18+commit.6124c56 for TRON**

### Enable optimization

200 runs

### Source code

Single file, MIT licensed

### Contract sources

* For ERC20 contract, use [TatumErc20CappedToken.sol](./verification/TatumErc20CappedToken.sol)
* For ERC721 general contract, use [Tatum721General.sol](./verification/Tatum721General.sol)
* For ERC721 TRON general contract, use [TatumTron721.sol](./verification/TatumTron721.sol)
* For ERC1155 contract, use [Tatum1155.sol](./verification/Tatum1155.sol)
* For NFT Auction contract, use [NftAuction.sol](./verification/NftAuction.sol)
* For NFT Marketplace contract, use [MarketplaceListing.sol](./verification/MarketplaceListing.sol)
*

## License

[OpenZeppelin](https://docs.openzeppelin.com/contracts) is released under the [MIT License](LICENSE).

[Tatum contracts](https://tatum.io) are released under the [MIT License](LICENSE).
