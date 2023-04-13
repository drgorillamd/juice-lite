// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


// todo: add didpay/didredeem hook?
contract JBLite is ReentrancyGuard, Ownable {
    error JBLite_UnsupportedTokenReceived();
    error JBLite_ProjectPaymentsPaused();

    struct Splits {
        address beneficiary;
        uint96 share;
    }

// todo: pack
    struct FundingCycle {
        uint256 duration;
        uint256 start;
        uint256 numberOfLockedCycles;
        uint256 maxAmountPayable;
        uint256 tokenWeight;
    }

// Todo: pack supported and balance:
    mapping(uint256 projectId=>mapping(IERC20 tokenReceived=>bool supported)) public tokenSupportedBy;

    mapping(uint256 projectId=>mapping(IERC20 tokenReceived=>uint256 balance)) public projectBalanceOf;

    mapping(uint256 projectId=>Splits[] splitsOf) public splitsOf;

    mapping(uint256 projectId=>FundingCycle fundingCycle) public fundingCycleOf;

    mapping(uint256 projectId=>IERC20 projectToken) public projectTokenOf;

// todo: eth -> weth only, add a wrapper 
    function pay(uint256 _projectId, IERC20 _paymentToken, uint256 _amount)
        external
        nonReentrant
        returns (uint256 _projectTokenReceived)
    {
        if (!tokenSupportedBy[_projectId][_paymentToken]) revert JBLite_UnsupportedTokenReceived();
        _paymentToken.transferFrom(msg.sender, address(this), _amount);

        // add a check for fee on transfer?

        // oraclize the amount -> if oracle == address(0), token is unsupported at protocol level
        uint256 _amountInDollars; // todo 

        // add to project balance
        projectBalanceOf[_projectId][_paymentToken] += _amountInDollars;

        FundingCycle memory _currentFundingCycle = fundingCycleOf[_projectId];

        // if erc20 -> mint
        uint256 _amountToMint = _amountInDollars * _currentFundingCycle.tokenWeight;
        // mint if non-0, from projectTokenOf

        // if erc721 -> mint
        // todo: tiering
        uint256 _nftToMint = _amountInDollars * _currentFundingCycle.nftWeight;
        // mint

        if(_amountToMint * _nftToMint == 0) revert JBLite_ProjectPaymentsPaused();
    }

    function redeem(uint256 _projectId, uint256 _projectTokenAmount, IERC20 _tokenToRedeem)
        external
        nonReentrant
        returns (uint256 _amountReceived)
    {
        // transfer

        // burn

        // compute amount redeemed, if 0, revert

        // send token out
    }

    function distributePayoutsOf() external nonReentrant {}

    function launchProject() external {}

    function reconfigureFundingCycleOf() external {
        // Include a number of fc where immutable
    }

    function setProjectTokenSupport() external {}

    function modifyOracle() external onlyOwner {}
}
