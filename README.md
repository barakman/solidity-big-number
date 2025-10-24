## Abstract

Mathematical computations over a size-limited fixed-point infrastructure, bare a fundamental tradeoff between Accuracy and Valid Input Range.

Within any computation, the only type of operation which can reduce the accuracy of the output is division.

The typical solution is to rearrange the computation such that division takes place only as the very last step.

Subsequently, intermediate results of the computation become more likely to overflow and revert the entire transaction.

This means that rearranging the computation will effectively reduce the range of input which can be handled successfully.

For example, consider `a / b + c / d` with `a = 100, b = 51, c = 1, d = 25`, and a size-limit of 8 bits (maximum value being 255).

The true value of this expression is `100 / 51 + 1 / 25 = 2.00078...`, so ideally on a fixed-point infrastructure, we would want our implementation to yield `2`.

The straightforward implementation `a / b + c / d` is very inaccurate of course.

It yields the output `100 / 51 + 1 / 25 = 1 + 0 = 1`, which reflects an inaccuracy of more than 50% compared with the true value.

But rearranging it such that division takes place as the very last step using `(a * d + b * c) / (b * d)` reverts the transaction.

It yields the intermediate computation of `a * d = 100 * 25`, which overflows the given size-limit.

This package consists of the following libraries:
- [NaturalNum](#naturalnum) - a set of functions over natural numbers
- [RationalNum](#rationalnum) - a set of functions over rational numbers

NaturalNum handles the size-limit internally, thus allowing to rearrange any computation and achieve maximum accuracy without reducing the size of valid input range.

In the example above, it yields `(100 * 25 + 51 * 1) / (51 * 25) = 2`, which reflects an inaccuracy of less than 0.04% compared with the true value.

RationalNum maintains the entire expression as a rational number, thus allowing to avoid the rearrangement and implement the computation in its "native form".

Using it will typically be less cost-effective, hence it is advisable to use NaturalNum whenever performance is considered critical.

<br/><br/>

---

<br/><br/>

## NaturalNum

This module implements arithmetic over natural numbers of any conceivable size.

The data structure used for representing a natural number is a `uint256` dynamic array.

For performance considerations, we have refrained from wrapping it within a `struct`.

Hopefully, future compilers will support the usage of `type` over this non-primitive type.

This module supports the following operations:
- Function `encode(uint256 val)` => `uint256[]`
- Function `decode(uint256[] num)` => `uint256`
- Function `eq(uint256[] x, uint256[] y)` => `bool`
- Function `gt(uint256[] x, uint256[] y)` => `bool`
- Function `lt(uint256[] x, uint256[] y)` => `bool`
- Function `gte(uint256[] x, uint256[] y)` => `bool`
- Function `lte(uint256[] x, uint256[] y)` => `bool`
- Function `and(uint256[] x, uint256[] y)` => `uint256[]`
- Function `or(uint256[] x, uint256[] y)` => `uint256[]`
- Function `xor(uint256[] x, uint256[] y)` => `uint256[]`
- Function `add(uint256[] x, uint256[] y)` => `uint256[]`
- Function `sub(uint256[] x, uint256[] y)` => `uint256[]`
- Function `mul(uint256[] x, uint256[] y)` => `uint256[]`
- Function `div(uint256[] x, uint256[] y)` => `uint256[]`
- Function `mod(uint256[] x, uint256[] y)` => `uint256[]`
- Function `pow(uint256[] x, uint256 n)` => `uint256[]`
- Function `shl(uint256[] x, uint256 n)` => `uint256[]`
- Function `shr(uint256[] x, uint256 n)` => `uint256[]`
- Function `bitLength(uint256[] x)` => `uint256`

This module assumes that every `uint256[]` input can ultimately be traced back to (i.e., created by) function `encode`.

Since the length of dynamic arrays is bounded by `2**64-1`, the maximum representable value is `(2**256)**(2**64-1)-1`.

<br/><br/>

---

<br/><br/>

## RationalNum

This module implements arithmetic over rational numbers of any conceivable size.

The data structure used for representing a rational number is:
```
struct Rnum {
    bool s;      // the represented value's negativity
    uint256[] n; // the represented value's numerator
    uint256[] d; // the represented value's denominator
}
```

This module supports the following operations:
- Function `encode(bool s, uint256 n, uint256 d)` => `Rnum`
- Function `decode(Rnum num)` => `(bool, uint256, uint256)`
- Function `eq(Rnum x, Rnum y)` => `bool`
- Function `gt(Rnum x, Rnum y)` => `bool`
- Function `lt(Rnum x, Rnum y)` => `bool`
- Function `gte(Rnum x, Rnum y)` => `bool`
- Function `lte(Rnum x, Rnum y)` => `bool`
- Function `add(Rnum x, Rnum y)` => `Rnum`
- Function `sub(Rnum x, Rnum y)` => `Rnum`
- Function `mul(Rnum x, Rnum y)` => `Rnum`
- Function `div(Rnum x, Rnum y)` => `Rnum`

<br/><br/>

---

<br/><br/>

## Testing

### Prerequisites

- `node 22.21.0`
- `yarn 1.22.22` or `npm 10.9.4`

### Installation

- `yarn install` or `npm install`

### Compilation

- `yarn build` or `npm run build`

### Execution

- `yarn test` or `npm run test`

### Verification

- `yarn verify` or `npm run verify`
