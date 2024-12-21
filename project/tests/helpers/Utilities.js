module.exports.assertRevert = async function (promise, reason) {
    try {
        await promise;
        throw null;
    }
    catch (error) {
        assert(error, "expected an error but did not get one");
        assert.include(error.message, "revert");
        if (reason)
            assert.include(error.message, reason);
    }
};

module.exports.assertAlmostEqual = function (actual, expected, maxError) {
    if (!actual.eq(expected)) {
        const error = actual.div(expected).sub(1).abs();
        assert(error.lte(maxError),
            `\nexpected = ${expected.toFixed()}` +
            `\nactual   = ${actual  .toFixed()}` +
            `\nerror    = ${error   .toFixed()}`
        );
    }
};
