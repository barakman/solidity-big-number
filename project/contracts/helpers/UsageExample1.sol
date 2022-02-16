// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.12;

import "../NaturalNum.sol";
import "../RationalNum.sol";

contract UsageExample1 {
    using RationalNum for Rnum;
    using NaturalNum for uint256[];

    struct Fraction {
        uint256 n;
        uint256 d;
    }

    function sumExact(Fraction[] memory fractions) external pure returns (Fraction memory) {
        Rnum memory res = sum(fractions);
        return Fraction(res.n.decode(), res.d.decode());
    }

    function sumFloor(Fraction[] memory fractions) external pure returns (uint256) {
        Rnum memory res = sum(fractions);
        return res.n.div(res.d).decode();
    }

    function sumCeil(Fraction[] memory fractions) external pure returns (uint256) {
        Rnum memory res = sum(fractions);
        uint256[] memory one = NaturalNum.encode(1);
        return res.n.add(res.d).sub(one).div(res.d).decode();
    }

    function sum(Fraction[] memory fractions) private pure returns (Rnum memory) {
        Rnum memory res = RationalNum.encode(false, 0, 1);
        for (uint256 i = 0; i < fractions.length; i++)
            res = res.add(RationalNum.encode(false, fractions[i].n, fractions[i].d));
        return res;
    }
}
