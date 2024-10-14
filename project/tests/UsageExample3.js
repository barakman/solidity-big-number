const TestContract = artifacts.require("UsageExample3");
const Utilities = require("./helpers/Utilities.js");
const Decimal = require("decimal.js");

const toBN = web3.utils.toBN;

const ITERATIONS = 40;

const toNatural = x => [...Array(Number(x.length)).keys()].reduce((a, i) => a.add(toBN(x[i]).shln(i * 256)), toBN(0));
const toDecimal = x => Decimal(toNatural(x[0]).toString()).div(toNatural(x[1]).toString());

describe(TestContract.contractName, () => {
    let testContract;

    before(async () => {
        testContract = await TestContract.new();
    });

    for (let n = 0; n <= 4; n++) {
        for (let d = 1; d <= 20; d++) {
            it(`exp(${n}/${d})`, async () => {
                const expected = Decimal(n).div(d).exp();
                const actual = toDecimal(await testContract.exp([[n], [d]], ITERATIONS));
                Utilities.assertAlmostEqual(actual, expected, "1e-26");
            });
        }
    }
});
