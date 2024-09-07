const TestContract = artifacts.require("UsageExample1");
const Utilities = require("./helpers/Utilities.js");

const toBN = web3.utils.toBN;

const MAX = toBN(1).shln(256).subn(1);

const Fraction = (n, d) => ({n: toBN(n), d: toBN(d)});

describe(TestContract.contractName, () => {
    let testContract;

    before(async () => {
        testContract = await TestContract.new();
    });

    function test(length, generator, description) {
        const values = [...Array(length).keys()].map(i => Fraction(...generator(i)));
        const fractions = values.map(value => ({n: value.n.toString(), d: value.d.toString()}));
        const sum = values.reduce((x, y) => Fraction(x.n.mul(y.d).add(x.d.mul(y.n)), x.d.mul(y.d)), Fraction(0, 1));

        it(`sumExact(${description})`, async () => {
            const expected = sum;
            if (expected.n.or(expected.d).lte(MAX)) {
                const actual = await testContract.sumExact(fractions);
                assert.equal(`${actual.n}/${actual.d}`, `${expected.n}/${expected.d}`);
            }
            else {
                await Utilities.assertRevert(testContract.sumExact(fractions), "overflow");
            }
        });

        it(`sumFloor(${description})`, async () => {
            const expected = sum.n.div(sum.d);
            if (expected.lte(MAX)) {
                const actual = await testContract.sumFloor(fractions);
                assert.equal(actual.toString(), expected.toString());
            }
            else {
                await Utilities.assertRevert(testContract.sumFloor(fractions), "overflow");
            }
        });

        it(`sumCeil(${description})`, async () => {
            const expected = sum.n.add(sum.d).subn(1).div(sum.d);
            if (expected.lte(MAX)) {
                const actual = await testContract.sumCeil(fractions);
                assert.equal(actual.toString(), expected.toString());
            }
            else {
                await Utilities.assertRevert(testContract.sumCeil(fractions), "overflow");
            }
        });
    }

    for (let length = 1; length <= 100; length++)
        test(length, i => [i + 1, i + 2], `i / (i + 1) for i in [1, ${length}]`);

    for (let length = 1; length <= 4; length++)
        test(length, i => [MAX, i + 2], `MAX / (i + 1) for i in [1, ${length}]`);

    for (let length = 1; length <= 8; length++)
        test(length, i => [MAX, 2 ** (i + 1)], `MAX / 2^i for i in [1, ${length}]`);
});
