// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address, address, uint256) external;
    function mint(address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract DutchAuction {
    uint256 private constant DURATION = 7 days;
    IERC721 private immutable _nft;
    uint256 private immutable _nftId;
    address payable private immutable _seller;
    uint256 private immutable _startingPrice;
    uint256 private immutable _startAt;
    uint256 private immutable _expiresAt;
    uint256 private immutable _discountRate;

    constructor(
        uint256 c_startingPrice,
        uint256 c_discountRate,
        address c_nft,
        uint256 c_nftId
    ) {
        _seller = payable(msg.sender);
        _startingPrice = c_startingPrice;
        _startAt = block.timestamp;
        _expiresAt = block.timestamp + DURATION;
        _discountRate = c_discountRate;

        require(
            _startingPrice >= _discountRate * DURATION, "starting price < min"
        );

        _nft = IERC721(c_nft);
        _nftId = c_nftId;
    }

    function price() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - _startAt;
        uint256 discount = _discountRate * timeElapsed;
        return _startingPrice - discount;
    }

    function buy() external payable _auctionNotExpired {
        uint256 currentPrice = price();
        require(msg.value >= currentPrice, "ETH < price");
        _nft.transferFrom(_seller, msg.sender, _nftId);
        uint256 refund = msg.value - currentPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    }

    modifier _auctionNotExpired() {
        require(block.timestamp < _expiresAt, "auction expired");
        _;
    }
}
