const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
    const devMode = options.mode !== 'production';

    return {
        optimization: {
            minimizer: [
                new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode })
            ]
        },
        entry: {
            'app': glob.sync('./vendor/**/*.js').concat(['./js/app.js']),
            'account': ['./js/account.js'],

            'registration_new': ['./js/registration_new.js'],

            'session_new': ['./js/session_new.js'],

            'reset_password_edit': ['./js/reset_password_edit.js'],

            'browsers': ['./js/browsers.js'],
            'lists': ['./js/lists.js', './js/encryption.js'],
            'bookmarks': ['./js/bookmarks.js'],
        },
        output: {
            filename: '[name].js',
            path: path.resolve(__dirname, '../priv/static/js'),
            publicPath: '/js/'
        },
        devtool: devMode ? 'source-map' : undefined,
        module: {
            rules: [
                {
                    test: /\.js$/,
                    exclude: /node_modules/,
                    use: {
                        loader: 'babel-loader'
                    }
                },
                {
                    test: /\.[s]?css$/,
                    use: [
                        MiniCssExtractPlugin.loader,
                        'css-loader',
                        'sass-loader',
                    ],
                },
                {
                    test: /\.(woff(2)?|ttf|otf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
                    use: [
                        {
                            loader: 'file-loader',
                            options: { name: '[name].[ext]', outputPath: '../fonts'}
                        }
                    ]
                }
            ]
        },
        plugins: [
            new MiniCssExtractPlugin({ filename: '../css/app.css' }),
            new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
        ]
    }
};
