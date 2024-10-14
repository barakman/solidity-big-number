const TestContract = artifacts.require("UsageExample3");
const Utilities = require("./helpers/Utilities.js");
const Decimal = require("decimal.js");

const toBN = web3.utils.toBN;

const toNatural = x => [...Array(Number(x.length)).keys()].reduce((a, n) => a.add(toBN(x[n]).shln(n * 256)), toBN(0));
const toDecimal = x => Decimal(toNatural(x[0]).toString()).div(toNatural(x[1]).toString());

describe(TestContract.contractName, () => {
    let testContract;

    before(async () => {
        testContract = await TestContract.new();
    });

    function test(n, d, iterations, maxError) {
        it(`exp(${n}, ${d}, ${iterations})`, async () => {
            const expected = Decimal(n).div(d).exp();
            const actual = toDecimal(await testContract.exp([[n], [d]], iterations));
            Utilities.assertAlmostEqual(actual, expected, maxError);
        });
    }

    for (let n = 0; n <= 4; n++)
        for (let d = 1; d <= 4; d++)
            test(n, d, 50, "1e-37");

    for (let n = 0; n <= 4; n++)
        for (let d = 5; d <= 20; d++)
            test(n, d, 40, "1e-53");
});
