// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

interface IPool {
    function getTokenSharePrice(string memory symbol)
        external
        view
        returns (uint256);

    function getTokenShare(string memory symbol)
        external
        view
        returns (address);
}
