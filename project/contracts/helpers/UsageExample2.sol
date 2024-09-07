// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

import "../NaturalNum.sol";
import "../RationalNum.sol";

contract UsageExample2 {
    using RationalNum for Rnum;
    using NaturalNum for uint256[];

    struct Fraction {
        uint256 n;
        uint256 d;
    }

    function continuedFraction(uint256[] memory values) external pure returns (Fraction memory) {
        Rnum memory res = continuedFraction(values, 0);
        return Fraction(res.n.decode(), res.d.decode());
    }

    function continuedFraction(uint256[] memory values, uint256 index) private pure returns (Rnum memory) {
        Rnum memory res = RationalNum.encode(false, values[index], 1);
        if (index + 1 < values.length) {
            Rnum memory val = continuedFraction(values, index + 1);
            Rnum memory one = RationalNum.encode(false, 1, 1);
            return res.add(one.div(val));
        }
        return res;
    }
}
