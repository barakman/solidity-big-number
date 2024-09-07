// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

library NaturalNum {
    function encode(uint256 val) internal pure returns (uint256[] memory) { unchecked {
        uint256[] memory num;
        if (val > 0) {
            num = allocate(1);
            num[0] = val;
        }
        return num;
    }}

    function decode(uint256[] memory num) internal pure returns (uint256) { unchecked {
        if (num.length == 0)
            return 0;
        if (num.length == 1)
            return num[0];
        revert("overflow");
    }}

    function eq(uint256[] memory x, uint256[] memory y) internal pure returns (bool) { unchecked {
        if (x.length != y.length)
            return false;
        for (uint256 i = x.length; i > 0; --i)
            if (x[i - 1] != y[i - 1])
                return false;
        return true;
    }}

    function gt(uint256[] memory x, uint256[] memory y) internal pure returns (bool) { unchecked {
        if (x.length != y.length)
            return x.length > y.length;
        for (uint256 i = x.length; i > 0; --i)
            if (x[i - 1] != y[i - 1])
                return x[i - 1] > y[i - 1];
        return false;
    }}

    function lt(uint256[] memory x, uint256[] memory y) internal pure returns (bool) { unchecked {
        if (x.length != y.length)
            return x.length < y.length;
        for (uint256 i = x.length; i > 0; --i)
            if (x[i - 1] != y[i - 1])
                return x[i - 1] < y[i - 1];
        return false;
    }}

    function gte(uint256[] memory x, uint256[] memory y) internal pure returns (bool) { unchecked {
        return !lt(x, y);
    }}

    function lte(uint256[] memory x, uint256[] memory y) internal pure returns (bool) { unchecked {
        return !gt(x, y);
    }}

    function and(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        (uint256[] memory min, uint256[] memory max) = x.length < y.length ? (x, y) : (y, x);

        for (uint256 i = 0; i < min.length; ++i)
            min[i] &= max[i];

        return compress(min);
    }}

    function or(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        (uint256[] memory min, uint256[] memory max) = x.length < y.length ? (x, y) : (y, x);

        for (uint256 i = 0; i < min.length; ++i)
            max[i] |= min[i];

        return max;
    }}

    function xor(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        (uint256[] memory min, uint256[] memory max) = x.length < y.length ? (x, y) : (y, x);

        for (uint256 i = 0; i < min.length; ++i)
            max[i] ^= min[i];

        return compress(max);
    }}

    function add(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        (uint256[] memory min, uint256[] memory max) = x.length < y.length ? (x, y) : (y, x);

        uint256[] memory result = allocate(max.length + 1);
        uint256 carry = 0;

        for (uint256 i = 0; i < min.length; ++i)
            (result[i], carry) = add(min[i], max[i], carry);

        for (uint256 i = min.length; i < max.length; ++i)
            (result[i], carry) = add(0, max[i], carry);

        result[max.length] = carry;
        return compress(result);
    }}

    function sub(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        require(x.length >= y.length, "underflow");

        uint256[] memory result = allocate(x.length);
        uint256 carry = 0;

        for (uint256 i = 0; i < y.length; ++i)
            (result[i], carry) = sub(x[i], y[i], carry);

        for (uint256 i = y.length; i < x.length; ++i)
            (result[i], carry) = sub(x[i], 0, carry);

        require(carry == 0, "underflow");
        return compress(result);
    }}

    function mul(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        uint256[] memory result;

        for (uint256 i = 0; i < x.length; i++)
            for (uint256 j = 0; j < y.length; j++)
                result = add(result, shl(mul(x[i], y[j]), (i + j) * 256));

        return result;
    }}

    function div(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        require(y.length > 0, "division by zero");

        uint256[] memory result;
        uint256[] memory one = encode(1);

        uint256 xBitLength = bitLength(x);
        uint256 yBitLength = bitLength(y);

        while (xBitLength > yBitLength) {
            uint256 shift = xBitLength - yBitLength - 1;
            result = add(result, shl(one, shift));
            x = sub(x, shl(y, shift));
            xBitLength = bitLength(x);
        }

        if (gte(x, y))
            return add(result, one);
        return result;
    }}

    function mod(uint256[] memory x, uint256[] memory y) internal pure returns (uint256[] memory) { unchecked {
        return sub(x, mul(div(x, y), y));
    }}

    function pow(uint256[] memory x, uint256 n) internal pure returns (uint256[] memory) { unchecked {
        if (x.length == 0 || n == 0)
            return encode(x.length ** n);

        uint256[] memory result = encode(1);
        uint256[][] memory factors = new uint256[][](bitLength(n));

        factors[0] = x;
        for (uint256 i = 0; (n >> i) > 1; ++i)
            factors[i + 1] = mul(factors[i], factors[i]);

        for (uint256 i = 0; (n >> i) > 0; ++i)
            if (((n >> i) & 1) > 0)
                result = mul(result, factors[i]);

        return result;
    }}

    function shl(uint256[] memory x, uint256 n) internal pure returns (uint256[] memory) { unchecked {
        if (x.length == 0 || n == 0)
            return x;

        uint256 uintShift = n / 256;
        uint256 bitsShift = n % 256;
        uint256 compShift = 256 - bitsShift;

        uint256[] memory result = allocate(x.length + uintShift + 1);
        uint256 lastIndex = result.length - 1;
        uint256 remainder = 0;

        for (uint256 i = uintShift; i < lastIndex; ++i) {
            uint256 u = x[i - uintShift];
            result[i] = (u << bitsShift) | remainder;
            remainder = u >> compShift;
        }

        result[lastIndex] = remainder;
        return compress(result);
    }}

    function shr(uint256[] memory x, uint256 n) internal pure returns (uint256[] memory) { unchecked {
        if (x.length == 0 || n == 0)
            return x;

        uint256 uintShift = n / 256;
        uint256 bitsShift = n % 256;
        uint256 compShift = 256 - bitsShift;

        if (uintShift >= x.length)
            return encode(0);

        uint256[] memory result = allocate(x.length - uintShift);
        uint256 lastIndex = result.length - 1;

        for (uint256 i = 0; i < lastIndex; ++i) {
            uint256 k = i + uintShift;
            result[i] = (x[k] >> bitsShift) | (x[k + 1] << compShift);
        }

        result[lastIndex] = x[lastIndex + uintShift] >> bitsShift;
        return compress(result);
    }}

    function bitLength(uint256[] memory x) internal pure returns (uint256) { unchecked {
        if (x.length > 0)
            return (x.length - 1) * 256 + bitLength(x[x.length - 1]);
        return 0;
    }}

    function add(uint256 x, uint256 y, uint256 carry) private pure returns (uint256, uint256) { unchecked {
        if (x < type(uint256).max)
            return add(x + carry, y);
        if (y < type(uint256).max)
            return add(x, y + carry);
        return (type(uint256).max - 1 + carry, 1);
    }}

    function add(uint256 x, uint256 y) private pure returns (uint256, uint256) { unchecked {
        uint256 z = x + y;
        return (z, cast(z < x));
    }}

    function sub(uint256 x, uint256 y, uint256 carry) private pure returns (uint256, uint256) { unchecked {
        if (x > 0)
            return sub(x - carry, y);
        if (y < type(uint256).max)
            return sub(x, y + carry);
        return (1 - carry, 1);
    }}

    function sub(uint256 x, uint256 y) private pure returns (uint256, uint256) { unchecked {
        uint256 z = x - y;
        return (z, cast(z > x));
    }}

    function mul(uint256 x, uint256 y) private pure returns (uint256[] memory) { unchecked {
        uint256[] memory result = allocate(2);

        uint256 p = mulmod(x, y, type(uint256).max);
        uint256 q = x * y;

        result[0] = q;
        result[1] = p - q - cast(p < q);

        return compress(result);
    }}

    function bitLength(uint256 n) private pure returns (uint256) { unchecked {
        uint256 m;

        for (uint256 s = 128; s > 0; s >>= 1) {
            if (n >= 1 << s) {
                n >>= s;
                m |= s;
            }
        }

        return m + 1;
    }}

    function allocate(uint256 length) private pure returns (uint256[] memory) { unchecked {
        return new uint256[](length);
    }}

    function compress(uint256[] memory num) private pure returns (uint256[] memory) { unchecked {
        uint256 length = num.length;

        while (length > 0 && num[length - 1] == 0)
            --length;

        assembly { mstore(num, length) }
        return num;
    }}

    function cast(bool b) private pure returns (uint256 u) { unchecked {
        assembly { u := b }
    }}
}
