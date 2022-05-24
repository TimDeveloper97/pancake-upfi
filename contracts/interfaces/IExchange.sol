// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

interface IExchange {
    function getTokenSharePrice(string memory symbol)
        external
        view
        returns (uint256);

    function getDeadline() external view returns (uint256);

    function setDeadline(uint256) external;

    function getTokenShare(string memory symbol)
        external
        view
        returns (address);
}
