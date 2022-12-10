// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "../NaturalNum.sol";

contract NaturalNumUser {
    function encode(uint256 val) external pure returns (uint256[] memory) {
        return NaturalNum.encode(val);
    }

    function decode(uint256[] memory num) external pure returns (uint256) {
        return NaturalNum.decode(num);
    }

    function eq(uint256[] memory x, uint256[] memory y) external pure returns (bool) {
        return NaturalNum.eq(x, y);
    }

    function gt(uint256[] memory x, uint256[] memory y) external pure returns (bool) {
        return NaturalNum.gt(x, y);
    }

    function lt(uint256[] memory x, uint256[] memory y) external pure returns (bool) {
        return NaturalNum.lt(x, y);
    }

    function gte(uint256[] memory x, uint256[] memory y) external pure returns (bool) {
        return NaturalNum.gte(x, y);
    }

    function lte(uint256[] memory x, uint256[] memory y) external pure returns (bool) {
        return NaturalNum.lte(x, y);
    }

    function and(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.and(x, y);
    }

    function or(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.or(x, y);
    }

    function xor(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.xor(x, y);
    }

    function add(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.add(x, y);
    }

    function sub(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.sub(x, y);
    }

    function mul(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.mul(x, y);
    }

    function div(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.div(x, y);
    }

    function mod(uint256[] memory x, uint256[] memory y) external pure returns (uint256[] memory) {
        return NaturalNum.mod(x, y);
    }

    function pow(uint256[] memory x, uint256 n) external pure returns (uint256[] memory) {
        return NaturalNum.pow(x, n);
    }

    function shl(uint256[] memory x, uint256 n) external pure returns (uint256[] memory) {
        return NaturalNum.shl(x, n);
    }

    function shr(uint256[] memory x, uint256 n) external pure returns (uint256[] memory) {
        return NaturalNum.shr(x, n);
    }

    function bitLength(uint256[] memory x) external pure returns (uint256) {
        return NaturalNum.bitLength(x);
    }
}
