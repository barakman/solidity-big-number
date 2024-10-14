const TestContract = artifacts.require("UsageExample2");

const toBN = web3.utils.toBN;

const continuedFraction = values => values.slice(1).reduce((x, y) => ({n: x.n.muln(y).add(x.d), d: x.n}), {n: toBN(values[0]), d: toBN(1)});

describe(TestContract.contractName, () => {
    let testContract;

    before(async () => {
        testContract = await TestContract.new();
    });

    function test(length, generator) {
        const values = [...Array(length).keys()].map(generator);
        it(`continuedFraction(${values})`, async () => {
            const expected = continuedFraction(values.slice().reverse());
            const actual = await testContract.continuedFraction(values);
            assert.equal(`${actual.n}/${actual.d}`, `${expected.n}/${expected.d}`);
        });
    }

    for (let i = 1; i <= 8; i++)
        test(80, j => i);
    test(56, j => j + 1);
    test(56, j => 56 - j);
});
