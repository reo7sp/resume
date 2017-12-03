const merge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');


module.exports = merge(commonConfig, {
    plugins: [
        new UglifyJsPlugin()
    ]
});