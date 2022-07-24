// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IAaveLendingPool.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Park2Earn is Ownable, VRFConsumerBaseV2 {
  using SafeMath for uint256;

  VRFCoordinatorV2Interface COORDINATOR;

  // Chainlink subscription ID.
  uint64 s_subscriptionId;

  // Polygon mumbai coordinator chainlink.
  address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;

  // Gas lane Polygon mumbai chainlink
  bytes32 keyHash =
    0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

  // Gas limit Polygon mumbai chainlink
  uint32 callbackGasLimit = 100000;

  // Confirmations Polygon mumbai chainlink
  uint16 requestConfirmations = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords = 2;

  //number of winners per promotion
  uint8 numOfWinners = 2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;

  address _aaveLendingPool;

  constructor(uint64 subscriptionId, address aaveLendingPool)
    VRFConsumerBaseV2(vrfCoordinator)
  {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_subscriptionId = subscriptionId;
    _aaveLendingPool = aaveLendingPool;
  }

  struct Promotion {
    address creator;
    IERC20 token;
    uint256 createdAt;
    uint256 startTime;
    uint256 promoLength;
    string title;
    string description;
  }

  struct PublicGood {
    address creator;
    uint256 createdAt;
    address recipient;
    uint256 promotionId;
    string title;
    string description;
  }

  struct Staker {
    uint256 amount;
    uint256 promotionId;
  }

  event CreatePromotion(uint256 promotionId);
  event CreatePublicGood(uint256 privateGoodId);
  event StakedTokens(address staker, uint256 amount, uint256 promotionId);
  event WithdrawnTokens(address staker, uint256 amount);

  mapping(uint256 => Promotion) private _promotions;
  uint256 internal _latestPromotionId;

  mapping(uint256 => PublicGood) private _publicGoods;
  uint256 internal _latestPublicGoodId;

  mapping(uint256 => uint256[]) private _promotionWinners;

  //mapping between promotion and user staked
  mapping(address => Staker) private _stakes;

  function createPromotion(
    address token,
    uint256 startTime,
    uint256 length,
    string memory title,
    string memory description
  ) public onlyOwner {
    require(address(token) != address(0), "Can't be zero address");
    require(startTime > 0, "Start time must be positive");
    require(length > 0, "Lenght must be positive");
    require(bytes(title).length > 0, "Title can't be empty");
    require(bytes(description).length > 0, "Description can't be empty");

    uint256 nextPromotionId = _latestPromotionId.add(1);
    _latestPromotionId = nextPromotionId;

    _promotions[nextPromotionId] = Promotion({
      creator: msg.sender,
      token: IERC20(token),
      createdAt: block.timestamp,
      startTime: startTime,
      promoLength: length,
      title: title,
      description: description
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

  function getLatestPromotion() public view returns (Promotion memory) {
    return getPromotion(_latestPromotionId);
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

  function distributeWinners(
    uint256 promotionId,
    address token,
    uint256 amount
  ) external onlyOwner {
    uint256[] memory winners = _promotionWinners[promotionId];
    uint256 winnersLength = winners.length;
    uint256 amountSplit = amount.div(winners.length);

    if (winnersLength > 0) {
      IERC20(token).approve(address(this), amount);
      for (uint256 i = 1; i <= winnersLength; i++) {
        address target = _publicGoods[i].recipient;

        if (amountSplit > 0) {
          bool success = IERC20(token).transferFrom(
            address(this),
            target,
            amountSplit
          );
          require(success, "Failed to send amount for transfer.");
        }
      }
    }
  }

  function createPublicGood(
    address recipient,
    uint256 promotionId,
    string memory title,
    string memory description
  ) public {
    require(recipient != address(0), "Can't be zero address");
    require(isPromotionExpired(promotionId), "Promotion expired!");
    require(bytes(title).length > 0, "Title can't be empty");
    require(bytes(description).length > 0, "Description can't be empty");

    uint256 nextPublicGoodId = _latestPublicGoodId.add(1);
    _latestPublicGoodId = nextPublicGoodId;

    _publicGoods[nextPublicGoodId] = PublicGood({
      creator: msg.sender,
      createdAt: block.timestamp,
      recipient: recipient,
      promotionId: promotionId,
      title: title,
      description: description
    });

    emit CreatePublicGood(_latestPublicGoodId);
  }

  function getPublicGood(uint256 id) public view returns (PublicGood memory) {
    PublicGood memory publicGood = _publicGoods[id];
    return publicGood;
  }

  function getPublicGoodsCount() public view returns (uint256 count) {
    count = _latestPublicGoodId;
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

  function withdrawStaked(uint256 amount, uint256 promotionId) public {
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

  function depositAave(
    address asset,
    uint256 amount,
    uint16 referralCode
  ) external onlyOwner {
    require(asset != address(0), "Asset has to be non zero address");
    require(amount > 0, "Invalid amount");
    require(
      IERC20(asset).balanceOf(address(this)) >= amount,
      "Not enough balance!"
    );

    IERC20(asset).approve(_aaveLendingPool, amount);
    IAaveLendingPool(_aaveLendingPool).deposit(
      asset,
      amount,
      address(this),
      referralCode
    );
  }

  function withdrawAave(address asset, uint256 amount) external onlyOwner {
    require(asset != address(0), "Asset has to be non zero address");
    require(amount > 0, "Invalid amount");

    IAaveLendingPool(_aaveLendingPool).withdraw(asset, amount, address(this));
  }

  // Assumes the subscription is funded sufficiently.
  function requestRandomWords() external onlyOwner {
    // Will revert if subscription is not set and funded.
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }

  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
  }

  function drawWinners(uint256 promotionId, uint256 moduloRange)
    public
    onlyOwner
  {
    uint256[] memory winners = new uint256[](numOfWinners);
    if (_promotionWinners[promotionId].length == 0) {
      for (uint256 i = 0; i < numOfWinners; i++) {
        winners[i] =
          (uint256(keccak256(abi.encode(s_randomWords, i))) % moduloRange) +
          1;
      }
      _promotionWinners[promotionId] = winners;
    }
  }

  function getPromotionWinners(uint256 promotionId)
    public
    view
    returns (uint256[] memory winners)
  {
    winners = _promotionWinners[promotionId];
  }
}
