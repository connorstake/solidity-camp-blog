// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    function transferFrom(address, address, uint256) external;
}

contract EnglishAuction {
    event Start();

    IERC721 private _nft;
    uint256 private _nftId;

    address payable private _seller;
    uint256 private _endAt;
    bool private _started;
    bool private _closed;

    address private _highestBidder;
    uint256 private _highestBid;
    mapping(address => uint256) private _bids;

    constructor(address nft, uint256 nftId, uint256 startingBid) {
        _nft = IERC721(nft);
        _nftId = nftId;

        _seller = payable(msg.sender);
		_nft.transferFrom(msg.sender, address(this), _nftId);
        _highestBid = startingBid;
    }

    function start() external _onlySeller _auctionNotStarted {
        _started = true;
        _endAt = block.timestamp + 7 days;
    }

    function bid() external payable _auctionStarted _auctionEndTimeNotReached _bidLargerThanHighestBid {
        _highestBidder = msg.sender;
        _highestBid = msg.value;
    }

    function withdraw() external {
        uint256 currentBid = _bids[msg.sender];
        _bids[msg.sender] = 0;
        payable(msg.sender).transfer(currentBid);
    }

    function closeAndDistributeTokens() external  _auctionStarted _auctionNotClosed _auctionEndTimeReached {
        _closed = true;
        if (_highestBidder != address(0)) {
            _nft.safeTransferFrom(address(this), _highestBidder, _nftId);
            _seller.transfer(_highestBid);
        } else {
            _nft.safeTransferFrom(address(this), _seller, _nftId);
        }
    }

    function nft() external view returns (address) {
        return address(_nft);
    }

    function nftId() external view returns (uint256) {
        return _nftId;
    }

    function highestBid() external view returns (uint256) {
        return _highestBid;
    }

    function highestBidder() external view returns (address) {
        return _highestBidder;
    }

    function endAt() external view returns (uint256) {
        return _endAt;
    }

    function started() external view returns (bool) {
        return _started;
    }

    function closed() external view returns (bool) {
        return _closed;
    }

    function seller() external view returns (address) {
        return _seller;
    }

    function bidsByBidder(address bidder) external view returns (uint256) {
        return _bids[bidder];
    }


    modifier _onlySeller() {
        require(msg.sender == _seller, "not seller");
        _;
    }
    
    modifier _auctionNotStarted() {
        require(!_started, "started");
        _;
    }

    modifier _auctionStarted() {
        require(_started, "not started");
        _;
    }

    modifier _auctionEndTimeNotReached() {
        require(block.timestamp < _endAt, "ended");
        _;
    }

    modifier _bidLargerThanHighestBid() {
        require(msg.value > _highestBid, "bid not larger than highest bid");
        _;
    }

    modifier _auctionNotClosed() {
        require(!_closed, "closed");
        _;
    }

    modifier _auctionEndTimeReached() {
        require(block.timestamp >= _endAt, "end time not reached");
        _;
    }
}
