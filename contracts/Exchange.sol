//SPDX-License-Identifier: Unlicense
pragma solidity =0.6.6;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Operator.sol";
import "./interfaces/IExchange.sol";

contract Exchange is Operator, ReentrancyGuard, IExchange{
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    address public router;

    mapping(string => address) public token_shares;
    mapping(string => uint256) public token_share_prices;

    // Constants for various precisions
    uint256 private constant PRICE_PRECISION = 1e6;

    // AccessControl state variables
    bool public swap_paused = false;


    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _router,    // 
        address _collateral,     // 
    ) {
        router = _router;
        collateral = _collateral;
    }

    function addTokenShare(string memory symbol, address _share ) external onlyOperator {
        token_shares[symbol] = _share;
    }

    function setTokenSharePrice(string memory symbol, uint256 price ) external onlyOperator {
        token_share_prices[symbol] = price;
    }

    /* ========== VIEWS ========== */

    function info()
        external
        view
        returns (
            bool
        )
    {
        return (
            swap_paused
        );
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function getTokenSharePrice(string memory symbol) public view override returns (uint256) {
        return token_share_prices[symbol];
    }

    function getTokenShare(string memory symbol) external view override returns (address) {
        return token_shares[symbol];
    }

    function getCollateralPrice() public pure returns (uint256) {
        return 1e6;
    }

    function swapTokenToToken(
        uint256 _amount_tokenA_in,
        uint256 _amount_tokenB_out_min,
        string memory from_symbol, 
        string memory to_symbol) external {
        
    }


    /* ========== RESTRICTED FUNCTIONS ========== */

    function toggleSwapping() external onlyOperator {
        swap_paused = !swap_paused;
    }

    function setTreasury(address _treasury) external onlyOperator {
        treasury = _treasury;
    }

}
