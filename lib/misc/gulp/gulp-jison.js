/* ^
BSD 3-Clause License

Copyright (c) 2017, Stephan Jorek
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
