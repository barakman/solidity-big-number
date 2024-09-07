const TestContract = artifacts.require("NaturalNumUser");
const Utilities = require("./helpers/Utilities.js");

const toBN = web3.utils.toBN;

const MIN = toBN(0);
const MID = toBN(1).shln(128).subn(1);
const MAX = toBN(1).shln(256).subn(1);

const SMALL_VALUES = [
    ...[...Array(4).keys()].map(n => MIN.addn(n)),
    ...[...Array(4).keys()].map(n => MID.addn(n)),
    ...[...Array(4).keys()].map(n => MAX.addn(n)),
];

const LARGE_VALUES = [
    ...[...Array(4).keys()].map(n => MAX.subn(n).pow(toBN(2))),
    ...[...Array(4).keys()].map(n => MAX.subn(n).pow(toBN(3))),
    ...[...Array(4).keys()].map(n => MAX.subn(n).pow(toBN(4))),
];

describe(TestContract.contractName, () => {
    let testContract;

    before(async () => {
        testContract = await TestContract.new();
    });

    const encode = x => [...Array(Math.ceil(x.bitLength() / 256)).keys()].map(n => toBN(x.shrn(n * 256).maskn(256)));
    const decode = x => [...Array(Number(x.length)).keys()].reduce((a, n) => a.add(toBN(x[n]).shln(n * 256)), toBN(0));

    const funcs = {
        eq : {expected: (x, y) => x.eq  (y), actual: async (x, y) =>        await testContract.eq (encode(x), encode(y)) },
        gt : {expected: (x, y) => x.gt  (y), actual: async (x, y) =>        await testContract.gt (encode(x), encode(y)) },
        lt : {expected: (x, y) => x.lt  (y), actual: async (x, y) =>        await testContract.lt (encode(x), encode(y)) },
        gte: {expected: (x, y) => x.gte (y), actual: async (x, y) =>        await testContract.gte(encode(x), encode(y)) },
        lte: {expected: (x, y) => x.lte (y), actual: async (x, y) =>        await testContract.lte(encode(x), encode(y)) },
        and: {expected: (x, y) => x.and (y), actual: async (x, y) => decode(await testContract.and(encode(x), encode(y)))},
        or : {expected: (x, y) => x.or  (y), actual: async (x, y) => decode(await testContract.or (encode(x), encode(y)))},
        xor: {expected: (x, y) => x.xor (y), actual: async (x, y) => decode(await testContract.xor(encode(x), encode(y)))},
        add: {expected: (x, y) => x.add (y), actual: async (x, y) => decode(await testContract.add(encode(x), encode(y)))},
        sub: {expected: (x, y) => x.sub (y), actual: async (x, y) => decode(await testContract.sub(encode(x), encode(y)))},
        mul: {expected: (x, y) => x.mul (y), actual: async (x, y) => decode(await testContract.mul(encode(x), encode(y)))},
        div: {expected: (x, y) => x.div (y), actual: async (x, y) => decode(await testContract.div(encode(x), encode(y)))},
        mod: {expected: (x, y) => x.mod (y), actual: async (x, y) => decode(await testContract.mod(encode(x), encode(y)))},
        pow: {expected: (x, n) => x.pow (n), actual: async (x, n) => decode(await testContract.pow(encode(x), n))},
        shl: {expected: (x, n) => x.shln(n), actual: async (x, n) => decode(await testContract.shl(encode(x), n))},
        shr: {expected: (x, n) => x.shrn(n), actual: async (x, n) => decode(await testContract.shr(encode(x), n))},
    };

    for (const value of [...SMALL_VALUES, ...LARGE_VALUES]) {
        it(`cast(${value})`, async () => {
            if (value.lte(MAX)) {
                const number = await testContract.encode(value);
                assert.equal(await testContract.decode(number), value.toString());
                assert.equal(await testContract.bitLength(number), value.bitLength());
            }
            else {
                const number = encode(value);
                await Utilities.assertRevert(testContract.decode(number), "overflow");
                assert.equal(await testContract.bitLength(number), value.bitLength());
            }
        });
    }

    for (const func of ["eq", "gt", "lt", "gte", "lte"]) {
        for (const x of [...SMALL_VALUES, ...LARGE_VALUES]) {
            for (const y of [...SMALL_VALUES, ...LARGE_VALUES]) {
                it(`${func}(${x}, ${y})`, async () => {
                    const expected = funcs[func].expected(x, y);
                    const actual = await funcs[func].actual(x, y);
                    assert.equal(actual, expected);
                });
            }
        }
    }

    for (const func of ["and", "or", "xor", "add", "sub", "mul", "div", "mod"]) {
        for (const values of [SMALL_VALUES, LARGE_VALUES]) {
            for (const x of values) {
                for (const y of values) {
                    it(`${func}(${x}, ${y})`, async () => {
                        if (func == "sub" && x.lt(y)) {
                            await Utilities.assertRevert(funcs[func].actual(x, y), "underflow");
                        }
                        else if ((func == "div" || func == "mod") && y.eqn(0)) {
                            await Utilities.assertRevert(funcs[func].actual(x, y), "division by zero");
                        }
                        else {
                            const expected = funcs[func].expected(x, y);
                            const actual = await funcs[func].actual(x, y);
                            assert.equal(actual.toString(), expected.toString());
                        }
                    });
                }
            }
        }
    }

    for (const func of ["shl", "shr"]) {
        for (const x of [...SMALL_VALUES, ...LARGE_VALUES]) {
            for (let n = 0, k = 1; n < 1024; n += k, k += 1) {
                it(`${func}(${x}, ${n})`, async () => {
                    const expected = funcs[func].expected(x, n);
                    const actual = await funcs[func].actual(x, n);
                    assert.equal(actual.toString(), expected.toString());
                });
            }
        }
    }

    for (let n = 0; n < 64; n++) {
        it(`div(${n}!, 2^${n})`, async () => {
            const x = [...Array(n).keys()].reduce((k, i) => k.muln(i + 1), toBN(1));
            const y = toBN(1).shln(n);
            const expected = funcs.div.expected(x, y);
            const actual = await funcs.div.actual(x, y);
            assert.equal(actual.toString(), expected.toString());
        });
    }

    for (let n = 0; n < 32; n++) {
        it(`pow(2^${256 - n}-1, ${n})`, async () => {
            const x = toBN(1).shln(256 - n).subn(1);
            const expected = funcs.pow.expected(x, toBN(n));
            const actual = await funcs.pow.actual(x, toBN(n));
            assert.equal(actual.toString(), expected.toString());
        });
    }

    for (let x = 0; x < 10; x++) {
        for (let n = 0; n < 10; n++) {
            it(`pow(${x}, ${n})`, async () => {
                const expected = funcs.pow.expected(toBN(x), toBN(n));
                const actual = await funcs.pow.actual(toBN(x), toBN(n));
                assert.equal(actual.toString(), expected.toString());
            });
        }
    }
});
