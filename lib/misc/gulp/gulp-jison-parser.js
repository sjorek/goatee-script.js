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
    var PLUGIN_NAME, PluginError, map, util;

    map = require('map-stream');

    util = require('gulp-util');

    PluginError = util.PluginError;


    /*
     * # Gulp Jison Parser
     * -------------------
     *
     */

    PLUGIN_NAME = 'gulp-jison-parser';

    module.exports = function(options) {
        var Grammar, parser;
        Grammar = options.grammar;
        parser = function(file, cb) {
            var comment, data, p;
            p = Grammar.createParser(file.path);
            if (p instanceof Error) {
                return cb(p);
            }
            if (options.goatee != null) {
                data = Grammar.generateParser({
                    generate: function() {
                        return p.generate(options);
                    }
                });
            } else {
                data = p.generate(options);
            }
            if (data instanceof Error) {
                return cb(data);
            }
            if (options.beautify != null) {
                comment = data.match(/\/\*\s*(Returns a Parser object of the following structure:)[^\*]*(Parser:[^\*]*\})\s*\*\//);
                if (comment) {
                    data = data.replace(comment[0], "\n/** ------------\n *\n * " + comment[1] + "\n *\n *      " + (comment[2].split('\n').join('\n *    ').replace(/\*[ ]+\n/g, '*\n')) + "\n *\n */");
                }
            }
            file.contents = new Buffer(data);
            file.path = util.replaceExtension(file.path, '.js');
            return cb(null, file);
        };
        return map(parser);
    };

}).call(this);
//# sourceMappingURL=gulp-jison-parser.js.map
