const RationalNum = artifacts.require("RationalNumUser");

const assertRevert = require("./helpers/Utilities.js").assertRevert;

const Decimal = require("decimal.js");

const BN = web3.utils.BN;

const MIN = new BN(0);
const MAX = new BN(1).shln(256).subn(1);

const SMALL_VALUES = [...Array(5).keys()].map(n => MIN.addn(n));
const LARGE_VALUES = [...Array(5).keys()].map(n => MAX.subn(n));

contract("RationalNum", () => {
    let rationalNum;

    before(async () => {
        rationalNum = await RationalNum.new();
    });

    const str = (s, n, d) => `${s ? "-" : "+"}${n}/${d}`;
    const val = (s, n, d) => Decimal(s ? -1 : +1).mul(`${n}`).div(`${d}`);
    const num = (s, n, d) => ({s, n, d, str: str(s, n, d), val: val(s, n, d)});

    const encode = x => [x.s, encodeComponent(x.n), encodeComponent(x.d)];
    const decode = x => val(x[0], decodeComponent(x[1]), decodeComponent(x[2]));

    const encodeComponent = x => [...Array(Math.ceil(x.bitLength() / 256)).keys()].map(n => new BN(x.shrn(n * 256).maskn(256)));
    const decodeComponent = x => [...Array(Number(x.length)).keys()].reduce((a, n) => a.add(new BN(x[n]).shln(n * 256)), new BN(0));

    const funcs = {
        eq : {expected: (x, y) => x.val.eq (y.val), actual: async (x, y) =>        await rationalNum.eq (encode(x), encode(y)) },
        gt : {expected: (x, y) => x.val.gt (y.val), actual: async (x, y) =>        await rationalNum.gt (encode(x), encode(y)) },
        lt : {expected: (x, y) => x.val.lt (y.val), actual: async (x, y) =>        await rationalNum.lt (encode(x), encode(y)) },
        gte: {expected: (x, y) => x.val.gte(y.val), actual: async (x, y) =>        await rationalNum.gte(encode(x), encode(y)) },
        lte: {expected: (x, y) => x.val.lte(y.val), actual: async (x, y) =>        await rationalNum.lte(encode(x), encode(y)) },
        add: {expected: (x, y) => x.val.add(y.val), actual: async (x, y) => decode(await rationalNum.add(encode(x), encode(y)))},
        sub: {expected: (x, y) => x.val.sub(y.val), actual: async (x, y) => decode(await rationalNum.sub(encode(x), encode(y)))},
        mul: {expected: (x, y) => x.val.mul(y.val), actual: async (x, y) => decode(await rationalNum.mul(encode(x), encode(y)))},
        div: {expected: (x, y) => x.val.div(y.val), actual: async (x, y) => decode(await rationalNum.div(encode(x), encode(y)))},
    };

    for (const s of [false, true]) {
        for (const n of [...SMALL_VALUES, ...LARGE_VALUES]) {
            for (const d of [...SMALL_VALUES, ...LARGE_VALUES]) {
                it(`cast(${str(s, n, d)})`, async () => {
                    if (d.eqn(0)) {
                        await assertRevert(rationalNum.encode(s, n, d), "zero denominator");
                    }
                    else {
                        const expected = decode(encode({s, n, d}));
                        const actual = decode(await rationalNum.encode(s, n, d));
                        assert.equal(actual.toFixed(), expected.toFixed());
                    }
                });
            }
        }
    }

    for (const func of ["eq", "gt", "lt", "gte", "lte"]) {
        for (const values of [SMALL_VALUES, LARGE_VALUES]) {
            for (const sx of [false, true]) {
                for (const sy of [false, true]) {
                    for (const nx of values) {
                        for (const ny of values) {
                            for (const dx of values) {
                                for (const dy of values) {
                                    const x = num(sx, nx, dx);
                                    const y = num(sy, ny, dy);
                                    it(`${func}(${x.str}, ${y.str})`, async () => {
                                        if (dx.eqn(0) || dy.eqn(0)) {
                                            await assertRevert(funcs[func].actual(x, y), "zero denominator");
                                        }
                                        else {
                                            const expected = funcs[func].expected(x, y);
                                            const actual = await funcs[func].actual(x, y);
                                            assert.equal(actual, expected);
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    for (const func of ["add", "sub", "mul", "div"]) {
        for (const values of [SMALL_VALUES, LARGE_VALUES]) {
            for (const sx of [false, true]) {
                for (const sy of [false, true]) {
                    for (const nx of values) {
                        for (const ny of values) {
                            for (const dx of values) {
                                for (const dy of values) {
                                    const x = num(sx, nx, dx);
                                    const y = num(sy, ny, dy);
                                    it(`${func}(${x.str}, ${y.str})`, async () => {
                                        if (dx.eqn(0) || dy.eqn(0) || (ny.eqn(0) && func == "div")) {
                                            await assertRevert(funcs[func].actual(x, y), "zero denominator");
                                        }
                                        else {
                                            const expected = funcs[func].expected(x, y);
                                            const actual = await funcs[func].actual(x, y);
                                            if (!actual.eq(expected)) {
                                                const error = actual.div(expected).sub(1).abs();
                                                assert(error.lte("1e-100"),
                                                    `\nexpected = ${expected.toFixed()}` +
                                                    `\nactual   = ${actual  .toFixed()}` +
                                                    `\nerror    = ${error   .toFixed()}`
                                                );
                                            }
                                        }
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }
    }
});
