// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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

  struct Staker {
    uint256 amount;
    uint256 promotionId;
  }

  event CreatePromotion(uint256 promotionId);
  event CreatePrivateGood(uint256 privateGoodId);
  event StakedTokens(address staker, uint256 amount, uint256 promotionId);
  event WithdrawnTokens(address staker, uint256 amount);

  mapping(uint256 => Promotion) private _promotions;
  uint256 internal _latestPromotionId;

  mapping(uint256 => PrivateGood) private _privateGoods;
  uint256 internal _latestPrivateGoodId;

  //mapping between promotion and user staked
  mapping(address => Staker) private _stakes;

  function createPromotion(
    address token,
    uint256 startTime,
    uint256 length
  ) public onlyOwner {
    require(address(token) != address(0), "Can't be zero address");
    require(startTime > 0, "Start time must be positive");
    require(length > 0, "Lenght must be positive");

    uint256 nextPromotionId = _latestPromotionId.add(1);
    _latestPromotionId = nextPromotionId;

    _promotions[nextPromotionId] = Promotion({
      creator: msg.sender,
      token: IERC20(token),
      createdAt: block.timestamp,
      startTime: startTime,
      promoLength: length
    });

    emit CreatePromotion(nextPromotionId);
  }

  function getPromotion(uint256 id) public view returns (Promotion memory) {
    Promotion memory promotion = _promotions[id];
    return promotion;
  }

  function getPromotionToken(uint256 id) public view returns (IERC20 token) {
    token = getPromotion(id).token;
  }

  function getLatestPromotion() public view returns (PrivateGood memory) {
    return getPrivateGood(_latestPromotionId);
  }

  function getPromotionsCount() public view returns (uint256 count) {
    count = _latestPromotionId;
  }

  function isPromotionExpired(uint256 id) public view returns (bool isExpired) {
    uint256 endTime = _promotions[id].startTime.add(
      _promotions[id].promoLength
    );
    isExpired = endTime > block.timestamp;
  }

  function isPromotionToken(address token, uint256 promotionId)
    public
    view
    returns (bool)
  {
    return _promotions[promotionId].token == IERC20(token);
  }

  function createPrivateGood(address recipient) public onlyOwner {
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

  function getPrivateGood(uint256 id) public view returns (PrivateGood memory) {
    PrivateGood memory privateGood = _privateGoods[id];
    return privateGood;
  }

  function getPrivateGoodsCount() public view returns (uint256 count) {
    count = _latestPrivateGoodId;
  }

  function stake(
    address token,
    uint256 amount,
    uint256 promotionId
  ) public {
    require(isPromotionExpired(promotionId), "Promotion expired!");
    require(isPromotionToken(token, promotionId), "Not promotion token");
    require(amount > 0, "Invalid amount");

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.add(amount);

    IERC20(token).transferFrom(msg.sender, address(this), amount);
    emit StakedTokens(msg.sender, amount, promotionId);
  }

  function withdraw(uint256 amount, uint256 promotionId) public {
    require(!isPromotionExpired(promotionId), "Promotion still running!");
    require(amount > 0, "Invalid amount!");
    require(_stakes[msg.sender].amount >= amount, "Not enough staked!");
    require(_stakes[msg.sender].amount > 0, "Nothing staked!");

    IERC20 token = getPromotionToken(promotionId);
    require(token.balanceOf(address(this)) >= amount, "Not enough balance!");

    _stakes[msg.sender].amount = _stakes[msg.sender].amount.sub(amount);

    IERC20(token).approve(address(this), amount);
    IERC20(token).transferFrom(address(this), msg.sender, amount);
    emit WithdrawnTokens(msg.sender, amount);
  }

  function getAmountStaked(address staker)
    public
    view
    returns (uint256 amount)
  {
    amount = _stakes[staker].amount;
  }
}
