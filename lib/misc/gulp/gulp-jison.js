/*
© Copyright 2013-2016 Stephan Jorek <stephan.jorek@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
 */

(function() {
    var PLUGIN_NAME, PluginError, cli, fs, map, path, util,
        hasProp = {}.hasOwnProperty;

    fs = require('fs');

    path = require('path');

    map = require('map-stream');

    util = require('gulp-util');

    PluginError = util.PluginError;

    cli = require('jison/lib/cli');


    /*
     * # Gulp Jison
     * ------------
     *
     */

    PLUGIN_NAME = 'gulp-jison';

    module.exports = function(options) {
        var jison, lex, processFile;
        lex = null;
        if (options.lexfile != null) {
            lex = fs.readFileSync(path.normalize(options.lexfile), 'utf8');
        }
        processFile = function(file, options) {
            var grammar, key, name, opts, raw, ref, value;
            opts = {};
            if (options != null) {
                for (key in options) {
                    if (!hasProp.call(options, key)) continue;
                    value = options[key];
                    opts[key] = value;
                }
            }
            opts.file = file.path;
            raw = file.contents.toString();
            if (!opts.json) {
                opts.json = path.extname(opts.file) === '.json';
            }
            name = path.basename((ref = opts.outfile) != null ? ref : opts.file).replace(/\..*$/g, '');
            if (opts.outfile == null) {
                opts.outfile = name + ".js";
            }
            if ((opts.moduleName == null) && name) {
                opts.moduleName = name.replace(/-\w/g, function(match) {
                    return match.charAt(1).toUpperCase();
                });
            }
            grammar = cli.processGrammars(raw, lex, opts.json);
            return cli.generateParserString(opts, grammar);
        };
        jison = function(file, cb) {
            var contents;
            contents = processFile(file, options);
            if (contents instanceof Error) {
                return cb(contents);
            }
            file.contents = new Buffer(contents);
            file.path = util.replaceExtension('.js');
            return callback(null, file);
        };
        return map(jison);
    };

}).call(this);
//# sourceMappingURL=gulp-jison.js.map
