//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Auction {
    // The address of cold wallet that will hold amount token
    address public coldWalletAddress;

    address auctionAcceptedToken;

    // time Auction
    uint256 timeAuction;

    // Amount is auction successfully
    mapping(address => Bidder) pendingReturn;

    // list bidders
    Bidder[] bidders;

    // check auction ended
    bool public isEnded = true;

    struct Bidder {
        string name;
        address account;
        uint256 amount;
    }

    // The best amount of the Bid
    uint256 public highestBid;

    event Bid(string name, address account, uint256 amount);
    event EndAution(string name, address account, uint256 amount);

    constructor(address appceptedToken) {
        auctionAcceptedToken = address(appceptedToken);
        coldWalletAddress = 0xAA7740DB30dcE972a5F1eFD8970e2D37ADD75034;
    }

    function startAuction(uint256 _timeAuction, uint256 startCost) external {
        require(isEnded, "The previous auction is not over yet!");
        isEnded = false;
        timeAuction = block.timestamp + _timeAuction;
        highestBid = startCost;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return IERC20(auctionAcceptedToken).balanceOf(address(_account));
    }

    function bid(
        string memory _name,
        address _account,
        uint256 _amount
    ) public {
        require(_amount > highestBid, "Amount must greater than hightestBid!");
        require(
            _account != coldWalletAddress,
            "Admin can't take part in the auction"
        );
        require(block.timestamp < timeAuction, "The Auction is already end!");
        highestBid = _amount;
        pendingReturn[_account] = Bidder(_name, _account, _amount);
        bidders.push(Bidder(_name, _account, _amount));
        emit Bid(_name, _account, _amount);
    }

    function victoryPerson() external view returns (Bidder memory) {
        return bidders[bidders.length - 1];
    }

    function endAuction() public returns (bool) {
        // require(
        //     block.timestamp >= timeAuction,
        //     "The Auction time is not over!"
        // );
        Bidder memory persionVictory = bidders[bidders.length - 1];
        // console.log("bidders[bidders.length - 1]: ", bidders);
        isEnded = true;
        IERC20(auctionAcceptedToken).transferFrom(
            address(persionVictory.account),
            address(coldWalletAddress),
            persionVictory.amount
        );
        emit EndAution(
            persionVictory.name,
            persionVictory.account,
            persionVictory.amount
        );
        return true;
    }
}
