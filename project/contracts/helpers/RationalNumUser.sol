// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.34;

import "../RationalNum.sol";

contract RationalNumUser {
    function encode(bool s, uint256 n, uint256 d) external pure returns (Rnum memory) {
        return RationalNum.encode(s, n, d);
    }

    function decode(Rnum memory num) external pure returns (bool, uint256, uint256) {
        return RationalNum.decode(num);
    }

    function eq(Rnum memory x, Rnum memory y) external pure returns (bool) {
        return RationalNum.eq(x, y);
    }

    function gt(Rnum memory x, Rnum memory y) external pure returns (bool) {
        return RationalNum.gt(x, y);
    }

    function lt(Rnum memory x, Rnum memory y) external pure returns (bool) {
        return RationalNum.lt(x, y);
    }

    function gte(Rnum memory x, Rnum memory y) external pure returns (bool) {
        return RationalNum.gte(x, y);
    }

    function lte(Rnum memory x, Rnum memory y) external pure returns (bool) {
        return RationalNum.lte(x, y);
    }

    function add(Rnum memory x, Rnum memory y) external pure returns (Rnum memory) {
        return RationalNum.add(x, y);
    }

    function sub(Rnum memory x, Rnum memory y) external pure returns (Rnum memory) {
        return RationalNum.sub(x, y);
    }

    function mul(Rnum memory x, Rnum memory y) external pure returns (Rnum memory) {
        return RationalNum.mul(x, y);
    }

    function div(Rnum memory x, Rnum memory y) external pure returns (Rnum memory) {
        return RationalNum.div(x, y);
    }
}
