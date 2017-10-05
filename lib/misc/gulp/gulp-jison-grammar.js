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
     * # Gulp Jison Grammar
     * -------------------
     *
     */

    PLUGIN_NAME = 'gulp-jison-grammar';

    module.exports = function(options) {
        var Grammar, grammar;
        Grammar = options.grammar;
        grammar = function(file, cb) {
            var data, filepath, g, ref, ref1, ref2;
            filepath = (ref = options.moduleName) != null ? ref : file.path;
            g = Grammar.create(filepath);
            if (g instanceof Error) {
                return cb(g);
            }
            data = g.toJSONString((ref1 = options.replacer) != null ? ref1 : null, (ref2 = options.indent) != null ? ref2 : null);
            if (data instanceof Error) {
                return cb(data);
            }
            file.contents = new Buffer(data);
            file.path = util.replaceExtension(file.path, '.json');
            return cb(null, file);
        };
        return map(grammar);
    };

}).call(this);
//# sourceMappingURL=gulp-jison-grammar.js.map
