// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.33;

import "./NaturalNum.sol";

struct Rnum {
    bool s;
    uint256[] n;
    uint256[] d;
}

library RationalNum {
    using NaturalNum for uint256;
    using NaturalNum for uint256[];

    function encode(bool s, uint256 n, uint256 d) internal pure returns (Rnum memory) {
        return compress(Rnum(s, n.encode(), d.encode()));
    }

    function decode(Rnum memory num) internal pure returns (bool, uint256, uint256) {
        num = compress(num);
        return (num.s, num.n.decode(), num.d.decode());
    }

    function eq(Rnum memory x, Rnum memory y) internal pure returns (bool) {
        (x, y) = (compress(x), compress(y));
        if (x.s != y.s)
            return false;
        return x.n.mul(y.d).eq(y.n.mul(x.d));
    }

    function gt(Rnum memory x, Rnum memory y) internal pure returns (bool) {
        (x, y) = (compress(x), compress(y));
        if (x.s != y.s)
            return y.s;
        if (x.s)
            return x.n.mul(y.d).lt(y.n.mul(x.d));
        return x.n.mul(y.d).gt(y.n.mul(x.d));
    }

    function lt(Rnum memory x, Rnum memory y) internal pure returns (bool) {
        (x, y) = (compress(x), compress(y));
        if (x.s != y.s)
            return x.s;
        if (x.s)
            return x.n.mul(y.d).gt(y.n.mul(x.d));
        return x.n.mul(y.d).lt(y.n.mul(x.d));
    }

    function gte(Rnum memory x, Rnum memory y) internal pure returns (bool) {
        return !lt(x, y);
    }

    function lte(Rnum memory x, Rnum memory y) internal pure returns (bool) {
        return !gt(x, y);
    }

    function add(Rnum memory x, Rnum memory y) internal pure returns (Rnum memory) {
        (x, y) = (compress(x), compress(y));
        Rnum memory result;

        uint256[] memory numerator1 = x.n.mul(y.d);
        uint256[] memory numerator2 = y.n.mul(x.d);

        if (x.s == y.s) {
            result.s = x.s;
            result.n = numerator1.add(numerator2);
        }
        else if (numerator1.gt(numerator2)) {
            result.s = x.s;
            result.n = numerator1.sub(numerator2);
        }
        else {
            result.s = y.s;
            result.n = numerator2.sub(numerator1);
        }

        result.d = x.d.mul(y.d);
        return compress(result);
    }

    function sub(Rnum memory x, Rnum memory y) internal pure returns (Rnum memory) {
        (x, y) = (compress(x), compress(y));
        return add(x, Rnum(!y.s, y.n, y.d));
    }

    function mul(Rnum memory x, Rnum memory y) internal pure returns (Rnum memory) {
        (x, y) = (compress(x), compress(y));
        return compress(Rnum(x.s != y.s, x.n.mul(y.n), x.d.mul(y.d)));
    }

    function div(Rnum memory x, Rnum memory y) internal pure returns (Rnum memory) {
        (x, y) = (compress(x), compress(y));
        return mul(x, Rnum(y.s, y.d, y.n));
    }

    function compress(Rnum memory num) private pure returns (Rnum memory) {
        uint256[] memory zero = NaturalNum.encode(0);
        require(!num.d.eq(zero), "zero denominator");
        if (num.n.eq(zero)) {
            num.s = false;
            num.d = NaturalNum.encode(1);
        }
        return num;
    }
}
