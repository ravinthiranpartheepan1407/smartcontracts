// SPDX-License-Identifier: MIT

pragma solidity^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
  address public azogDevTokenAddress;
  constructor(address _AzogDevToken) ERC20("Azog Dev Token", "AZD"){
    require(_AzogDevToken != address(0), "Token passed a Null address");
    azogDevTokenAddress = _AzogDevToken;
  }

  function getReserve() public view returns (uint) {
    return ERC20(azogDevTokenAddress).balanceOf(address(this));
  }

  function addLiquidity(uint _amount) public payable returns (uint) {
    uint liquidity;
    uint ethBalance = address(this).balance;
    uint azogDevTokenReserve = getReserve();
    ERC20 azogDevToken = ERC20(azogDevTokenAddress);

    if(azogDevTokenReserve == 0){
      azogDevToken.transferFrom(msg.sender, address(this), _amount);
      liquidity = ethBalance;
      _mint(msg.sender, liquidity);
    } else{
        uint ethReserve = ethBalance - msg.value;
        uint azogDevTokenAmount = (msg.value * azogDevTokenReserve) / (ethReserve);
        require(_amount >= azogDevTokenAmount, "Amountof tokens set is less than the min requirements");
        azogDevToken.transferFrom(msg.sender, address(this), azogDevTokenAmount);
        liquidity = (totalSupply() * msg.value) / ethReserve;
        _mint(msg.sender, liquidity);
    }
    return liquidity;
  }

  function removeLiquidity(uint _amount) public returns (uint, uint) {
    require(_amount > 0, "Amount must be greater than zero");
    uint ethReserve = address(this).balance;
    uint _totalSupply = totalSupply();
    uint ethAmount = (ethReserve * _amount) / _totalSupply;
    uint azogDevTokenAmount = (getReserve() * _amount) / _totalSupply;
    _burn(msg.sender, _amount);
    payable(msg.sender).transfer(ethAmount);
    ERC20(azogDevTokenAddress).transfer(msg.sender, azogDevTokenAmount);
    return(ethAmount, azogDevTokenAmount);
  }

  function getAmountOfToken(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
    require(inputReserve > 0 && outputReserve > 0, "Invalid Reserve");
    uint256 inputAmountWithFee = inputAmount * 99;
    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
    return numerator / denominator;
  }

  function ethToAzogDevToken(uint _minTokens) public payable{
    uint256 tokenReserve = getReserve();
    uint256 tokensBought = getAmountOfToken(msg.value, address(this).balance - msg.value, tokenReserve);
    require(tokensBought >= _minTokens, "Insufficient output amount");
    ERC20(azogDevTokenAddress).transfer(msg.sender, tokensBought);
  }

  function azogDevTokenToEth(uint _tokenSold, uint _minEth) public {
    uint256 tokenReserve = getReserve();
    uint256 ethBought = getAmountOfToken(_tokenSold, tokenReserve, address(this).balance);

    require(ethBought >= _minEth, "Insufficient Output Amount");
    ERC20(azogDevTokenAddress).transferFrom(msg.sender, address(this), _tokenSold);
    payable(msg.sender).transfer(ethBought);
  }
}
