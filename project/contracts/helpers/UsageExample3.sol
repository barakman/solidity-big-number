// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import "../NaturalNum.sol";
import "../RationalNum.sol";

contract UsageExample3 {
    using RationalNum for Rnum;
    using NaturalNum for uint256[];

    struct Fraction {
        uint256 n;
        uint256 d;
    }

    function exp(Rnum memory x, uint256 iterations) external pure returns (Fraction memory) {
        Fraction memory f = exp(x.n, x.d, iterations);
        return x.s ? Fraction(f.d, f.n) : Fraction(f.n, f.d);
    }

    function exp(uint256[] memory xn, uint256[] memory xd, uint256 iterations) private pure returns (Fraction memory) {
        uint256[] memory n = xn;
        uint256[] memory d = xn.add(xd.mul(NaturalNum.encode(iterations)));
        for (uint256 i = iterations - 1; i > 0; --i) {
            uint256[] memory next_n = xn.mul(d);
            uint256[] memory next_d = xn.mul(d).add(xd.mul(d.sub(n)).mul(NaturalNum.encode(i)));
            n = next_n;
            d = next_d;
        }
        return Fraction(d.decode(), d.sub(n).decode());
    }
}
