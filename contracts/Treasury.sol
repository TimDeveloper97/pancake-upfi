// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./ERC20/ERC20Custom.sol";
import "./interfaces/ITreasury.sol";

import "./Operator.sol";

contract Treasury is ITreasury, Operator, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public dollar;
    address public share;

    // Constants for various precisions
    uint256 private constant PRICE_PRECISION = 1e6;
    uint256 private constant RATIO_PRECISION = 1e6;

    // fees
    uint256 public slippage_tolerance_fee;
    unit public lp_token_holders_fee;
    unit public treaury_fee;
    unit public upfi_buyback_burn_fee;

    bool public collateral_ratio_paused = true; // during bootstraping phase, collateral_ratio will be fixed at 100%

    /* ========== CONSTRUCTOR ========== */

    constructor() {
        slippage_tolerance_fee = 500000; // 0.5%
        lp_token_holders_fee = 170000; // 0.17% to LP token holders
        treaury_fee = 30000; // 0.03% to the Treasury
        upfi_buyback_burn_fee = 50000; // 0.05% towards upfi buyback and burn
    }

    /* ========== VIEWS ========== */

    function dollarPrice() public pure returns (uint256) {
        return 1000000;
    }

    function info()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
        )
    {
        return (
            slippage_tolerance_fee, 
            lp_token_holders_fee,
            treaury_fee, 
            upfi_buyback_burn_fee,
        );
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setSlippageToleranceFee(uint256 _slippage_tolerance_fee) public onlyOperator {
        slippage_tolerance_fee = _slippage_tolerance_fee;
    }

    function setLpTokenHoldersFee(uint256 _lp_token_holders_fee) public onlyOperator {
        lp_token_holders_fee = _lp_token_holders_fee;
    }

    function setTreauryFee(uint256 _treaury_fee) public onlyOperator {
        treaury_fee = _treaury_fee;
    }

    function setUpfiBuybackBurnFee(uint256 _upfi_buyback_burn_fee) public onlyOperator {
        upfi_buyback_burn_fee = _upfi_buyback_burn_fee;
    }

    function setDollarAddress(address _dollar) public onlyOperator {
        dollar = _dollar;
    }

    function setShareAddress(address _share) public onlyOperator {
        share = _share;
    }
}
