const TestContract = artifacts.require("UsageExample3");
const Utilities = require("./helpers/Utilities.js");
const Decimal = require("decimal.js");

const ITERATIONS = 32;

const toDecimal = actual => Decimal(actual[0].toString()).div(actual[1].toString());

describe(TestContract.contractName, () => {
    let testContract;

    before(async () => {
        testContract = await TestContract.new();
    });

    for (let n = -4; n <= 4; n++) {
        for (let d = 1; d <= 16; d++) {
            it(`exp(${n} / ${d})`, async () => {
                const expected = Decimal(n).div(d).exp();
                const actual = toDecimal(await testContract.exp([n / d < 0, [Math.abs(n)], [Math.abs(d)]], ITERATIONS));
                Utilities.assertAlmostEqual(actual, expected, "1e-18");
            });
        }
    }
});
