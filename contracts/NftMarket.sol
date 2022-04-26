//SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract NftMarket is ERC721 {
  address public owner;
  address public coolWalletAddress;
  address public acceptedToken;
  uint256 public nftCounter;

  mapping(string => bool) public tokenNameExists;
  mapping(uint256 => bool) public tokenIdExists;
  mapping(string => bool) public tokenUriExists;
  mapping(uint256 => Item) public items;
  mapping(uint256 => StakingData) public stakingData;

  struct Item {
    uint256 tokenId;
    string name;
    uint256 price;
    string tokenURI;
    address minterBy;
    address payable currentOwner;
    address payable previousOwner;
    uint256 numberOfTransfers;
  }
  struct StakingData {
    uint256 tokenId;
    uint256 pendingReward;
    address accountStaking;
    uint256 lockDuration;
    uint256 APR;
  }

  event AddNftToMartket(
    uint256 tokenId,
    string name,
    uint256 price,
    string tokenURI,
    address payable currentOwner
  );

  event DepositNFT(uint256 tokenId, string name, string tokenURI);

  event ChangeTokenPrice(uint256 oldPrice, uint256 newPrice);

  constructor(address _owner, address _acceptedToken)
    public
    ERC721("NftMarket", "NFT")
  {
    owner = _owner;
    acceptedToken = _acceptedToken;
    nftCounter = 0;
  }

  function checkExistsNameNft(string memory _name) external returns (bool) {
    return tokenNameExists[_name];
  }

  function checkExistsTokenIdNft(uint256 _tokenId) external returns (bool) {
    // console.log("checkExistsTokenIdNft: ", tokenIdExists[_tokenId]);

    return tokenIdExists[_tokenId];
  }

  function checkExistsTokenUriNft(string memory _tokenUri)
    external
    returns (bool)
  {
    return tokenUriExists[_tokenUri];
  }

  function mintNft(
    address _to,
    uint256 _tokenId,
    string memory _name,
    uint256 _price,
    string memory _tokenURI
  ) external onlyOwner {
    require(msg.sender != address(0));
    require(
      !tokenNameExists[_name],
      "The name token of market is already exists!"
    );
    require(!tokenIdExists[_tokenId], "The token of market is already exists!");
    require(
      !tokenUriExists[_tokenURI],
      "The tokenURI of market is already exists!"
    );
    nftCounter++;
    _mint(_to, _tokenId);
    items[_tokenId] = Item(
      _tokenId,
      _name,
      _price,
      _tokenURI,
      address(0),
      payable(_to),
      payable(_to),
      0
    );
    tokenIdExists[_tokenId] = true;
    emit AddNftToMartket(_tokenId, _name, _price, _tokenURI, payable(_to));
  }

  // function mintERC20(address account, uint256 amount) public onlyOwner {
  //   IERC20(acceptedToken).mint(account, amount);
  // }

  // function burnERC20(address account, uint256 amount) public onlyOwner {
  //   IERC20(acceptedToken).burn(account, amount);
  // }

  function balanceOfERC20(address account) public returns (uint256) {
    return IERC20(acceptedToken).balanceOf(account);
  }

  function transferERC20(
    address from,
    address to,
    uint256 value
  ) public {
    IERC20(acceptedToken).transferFrom(from, to, value);
  }

  function approveERC20(address spender, uint256 value) public {
    IERC20(acceptedToken).approve(spender, value);
  }

  modifier OnlyOwner() {
    address _owner = msg.sender;
    require(_owner == owner, "Only owner can do it!");
    _;
  }

  function transferNft(uint256 _tokenId) external payable {
    require(msg.sender != address(0), "address is not zero");
    require(tokenIdExists[_tokenId], "The token id is not exists!");
    address payable tokenOwner = payable(ownerOf(_tokenId));
    require(tokenOwner != msg.sender, "owner of token and buyer is not match!");
    Item memory item = items[_tokenId];
    uint256 balanceERC20 = balanceOfERC20(msg.sender);
    require(
      balanceERC20 >= item.price,
      "Balance is not enough to buy the item!"
    );

    _transfer(tokenOwner, msg.sender, _tokenId);
    // tokenOwner.transfer(item.price);
    transferERC20(msg.sender, tokenOwner, item.price);
    item.currentOwner = payable(msg.sender);
    item.previousOwner = tokenOwner;
    item.numberOfTransfers += 1;
  }

  function changeTokenPrice(uint256 _tokenId, uint256 _newPrice)
    external
    returns (bool)
  {
    address tokenOwner = ownerOf(_tokenId);
    require(tokenOwner != address(0));
    Item memory item = items[_tokenId];
    require(
      tokenOwner == item.currentOwner,
      "The owner of token is incorrect!"
    );
    uint256 oldPrice = item.price;
    item.price = _newPrice;
    emit ChangeTokenPrice(oldPrice, _newPrice);
    return true;
  }

  function depositNFT(
    uint256 _tokenId,
    uint256 _lockDuration,
    uint256 _APR
  ) external returns (bool) {
    require(msg.sender != address(0), "address is not zero");
    require(tokenIdExists[_tokenId], "The token id is not exists!");
    address payable tokenOwner = payable(ownerOf(_tokenId));
    require(
      tokenOwner == msg.sender,
      "owner of token and depositer is not match!"
    );
    Item memory item = items[_tokenId];
    _transfer(tokenOwner, owner, _tokenId);
    item.currentOwner = payable(owner);
    item.previousOwner = tokenOwner;
    item.numberOfTransfers += 1;
    stakingData[_tokenId] = StakingData(
      _tokenId,
      0,
      msg.sender,
      _lockDuration,
      _APR
    );
    emit DepositNFT(_tokenId, item.name, item.tokenURI);
  }

  function withDrawNFT(uint256 _tokenId) external {
    StakingData memory stakingDataUser = stakingData[_tokenId];
    Item memory item = items[_tokenId];
    require(
      stakingDataUser.accountStaking == msg.sender,
      "User not stake this token!"
    );
    stakingDataUser.pendingReward = (item.price * stakingDataUser.APR);
  }

  function claimReward(uint256 _tokenId) external returns (bool) {
    StakingData memory stakingDataUser = stakingData[_tokenId];
    uint256 amountReward = stakingDataUser.pendingReward;
    IERC20(acceptedToken).transferFrom(
      coolWalletAddress,
      msg.sender,
      amountReward
    );
    return true;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner is allowed to mint");
    _;
  }
}
