// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Park2Earn is Ownable {
 using SafeMath for uint256;

    struct Promotion {
        address creator;
        IERC20 token;
        uint256 createdAt;
        uint256 startTime;
        uint256 promoLength;
    }

    struct PrivateGood {
        address creator;
        uint256 createdAt;
        address recipient;
    }

    event CreatePromotion(uint256 promotionId);
    event CreatePrivateGood(uint256 promotionId);

    mapping (uint256 => Promotion) _promotions;
    uint256 internal _latestPromotionId;

    mapping (uint256 => PrivateGood) _privateGoods;
    uint256 internal _latestPrivateGoodId;


    function createPromotion(IERC20 token, uint256 startTime, uint256 length) public onlyOwner{

        require(address(token) != address(0), "Can't be zero address");
        require(startTime > 0, "Start time must be positive");
        require(length > 0, "Lenght must be positive");

        uint256 nextPromotionId = _latestPromotionId.add(1);
        _latestPromotionId = nextPromotionId;
        
        _promotions[nextPromotionId] = Promotion({
            creator: msg.sender,
            token: token,
            createdAt: block.timestamp,
            startTime: startTime,
            promoLength: length
        });

        emit CreatePromotion(nextPromotionId);
    }

    function getPromotion(uint256 id) public view returns(Promotion memory){
        Promotion memory promotion = _promotions[id];
        return promotion;
    }

     function createPrivateGood(address recipient) public onlyOwner{

        require(recipient != address(0), "Can't be zero address");

        uint256 nextPrivateGoodId = _latestPrivateGoodId.add(1);
        _latestPrivateGoodId = nextPrivateGoodId;
        
        _privateGoods[nextPrivateGoodId] = PrivateGood({
            creator: msg.sender,
            createdAt: block.timestamp,
            recipient: recipient
        });

        emit CreatePrivateGood(_latestPrivateGoodId);
    }

    function getPrivateGood(uint256 id) public view returns(PrivateGood memory){
        PrivateGood memory privateGood = _privateGoods[id];
        return privateGood;
    }
}