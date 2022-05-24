//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Operator.sol";
import "./interfaces/IExchange.sol";
import "./interfaces/IPancakeRouter01.sol";
import "./interfaces/ITreasury.sol";

contract Exchange is Operator, ReentrancyGuard, IExchange {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    modifier ensure(uint256 _deadline) {
        require(_deadline >= block.timestamp, "PancakeRouter: EXPIRED");
        _;
    }

    address public factory;
    address public router;
    address public treasury;

    mapping(string => address) public token_shares;
    mapping(string => uint256) public token_share_prices;

    // Constants for various precisions
    uint256 private constant PRICE_PRECISION = 1e6;

    // AccessControl state variables
    bool public swap_paused = false;

    // Pool_ceiling is the total units of collateral that a pool contract can hold
    uint256 public pool_ceiling = 0;
    uint256 public deadline;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _factory,
        address _router,
        address _treasury,
        uint256 _pool_ceiling
    ) {
        factory = _factory;
        router = _router;
        treasury = _treasury;
        pool_ceiling = _pool_ceiling;
    }

    function addTokenShare(string memory symbol, address _share)
        external
        onlyOperator
    {
        token_shares[symbol] = _share;
    }

    function setTokenSharePrice(string memory symbol, uint256 price)
        external
        onlyOperator
    {
        token_share_prices[symbol] = price;
    }

    /* ========== VIEWS ========== */

    function info() external view returns (uint256, bool) {
        return (
            pool_ceiling, // Ceiling of pool - collateral-amount
            swap_paused
        );
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function setDeadline(uint256 _deadline) external override {
        deadline = _deadline;
    }

    function getDeadline() public view override returns (uint256) {
        return deadline;
    }

    function getTokenSharePrice(string memory symbol)
        public
        view
        override
        returns (uint256)
    {
        return token_share_prices[symbol];
    }

    function getTokenShare(string memory symbol)
        external
        view
        override
        returns (address)
    {
        return token_shares[symbol];
    }

    function getCollateralPrice() public pure returns (uint256) {
        return 1e6;
    }

    function swapTokenToToken(
        uint256 _collateral_amount,
        uint256 _collateral_out_min,
        string memory from_symbol,
        string memory to_symbol,
        uint256 _deadline
    ) external ensure(_deadline) returns (uint256[] memory amounts) {
        require(swap_paused == false, "Minting is paused");
        (
            uint256 slippage_tolerance_fee,
            uint256 lp_token_holders_fee,
            uint256 treaury_fee,
            uint256 upfi_buyback_burn_fee
        ) = ITreasury(treasury).info();

        require(
            ERC20(token_shares[from_symbol]).balanceOf(address(this)).add(
                _collateral_amount
            ) <= pool_ceiling,
            ">poolCeiling"
        );

        uint256 _total_collateral_value = 0;
        uint256 tfrom_tto_ratio = (token_share_prices[from_symbol] *
            PRICE_PRECISION) /
            (token_share_prices[to_symbol] * PRICE_PRECISION);

        if (tfrom_tto_ratio > 0) {
            uint256 _collateral_value = _collateral_amount
                .mul(getCollateralPrice())
                .div(PRICE_PRECISION);

            //lay ra tổng số đồng token to
            _total_collateral_value = _collateral_value * tfrom_tto_ratio;
        }

        uint256 _actual_collateral_amount = _total_collateral_value.sub(
            (_total_collateral_value.mul(slippage_tolerance_fee)).div(
                PRICE_PRECISION
            )
        );

        uint256 _final_collateral_amount = _actual_collateral_amount.sub(
            (
                _actual_collateral_amount.mul(
                    lp_token_holders_fee + treaury_fee + upfi_buyback_burn_fee
                )
            ).div(PRICE_PRECISION)
        );

        require(_collateral_out_min <= _actual_collateral_amount, ">slippage");

        // if (_collateral_amount > 0) {
        //     // Todo: transfer _collateral_amount from sender to contract
        //     ERC20(token_shares[from_symbol]).transferFrom(
        //         msg.sender,
        //         address(this),
        //         _collateral_amount
        //     );
        // }

        // if (_final_collateral_amount > 0) {
        //     // Todo: transfer _final_collateral_amount from contract to sender
        //     ERC20(token_shares[from_symbol]).transfer(
        //         msg.sender,
        //         _final_collateral_amount
        //     );
        // }

        address[] memory path;
        path[0] = token_shares[from_symbol];
        path[1] = token_shares[to_symbol];
        // Todo: swap token to token
        IPancakeRouter01(router).swapTokensForExactTokens(
            _collateral_amount,
            _final_collateral_amount,
            path,
            msg.sender,
            deadline
        );
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setPoolCeiling(uint256 _pool_ceiling) external onlyOperator {
        pool_ceiling = _pool_ceiling;
    }

    function toggleSwapping() external onlyOperator {
        swap_paused = !swap_paused;
    }

    function setTreasury(address _treasury) external onlyOperator {
        treasury = _treasury;
    }
}
