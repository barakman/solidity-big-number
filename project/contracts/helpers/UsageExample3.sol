// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.34;

import "../NaturalNum.sol";

contract UsageExample3 {
    using NaturalNum for uint256[];

    struct Fraction {
        uint256[] n;
        uint256[] d;
    }

    function exp(Fraction memory x, uint256 iterations) external pure returns (Fraction memory) {
        Fraction memory y = Fraction(NaturalNum.encode(0), NaturalNum.encode(1));
        for (uint256 i = iterations; i > 0; --i)
            y = Fraction(x.n.mul(y.d), x.n.mul(y.d).add(x.d.mul(y.d.sub(y.n)).mul(NaturalNum.encode(i))));
        return Fraction(y.d, y.d.sub(y.n));
    }
}
