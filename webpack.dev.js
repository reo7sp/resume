const merge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');


module.exports = merge(commonConfig, {
    mode: 'development',
    devtool: 'inline-source-map',
    devServer: {
        contentBase: './dist'
    },
    watch: true
});