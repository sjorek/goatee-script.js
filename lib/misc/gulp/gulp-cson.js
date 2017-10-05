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
    var coffee, cson, map, util,
        hasProp = {}.hasOwnProperty;

    map = require('map-stream');

    coffee = require('coffee-script');

    util = require('gulp-util');

    cson = require('cson');


    /*
     * # Gulp CSON
     * -----------
     *
     */

    module.exports = function(options) {
        var format2ext, gcson, swap;
        format2ext = function(format) {
            switch (format) {
                case 'coffeescript':
                    return '.cs';
                case 'javascript':
                    return '.js';
                default:
                    return "." + format;
            }
        };
        swap = function(format) {
            switch (format) {
                case 'json':
                    return 'cson';
                case 'cson':
                    return 'json';
                case 'coffeescript':
                    return 'javascript';
                case 'javascript':
                    return 'coffeescript';
            }
        };
        gcson = function(file, cb) {
            var data, key, opts, value;
            opts = {};
            if (options != null) {
                for (key in options) {
                    if (!hasProp.call(options, key)) continue;
                    value = options[key];
                    opts[key] = value;
                }
            }
            opts.filename = file.path;
            if (!((opts.filename != null) || (opts.format != null))) {
                opts.format = 'cson';
            }
            data = cson.parseString(file.contents.toString(), opts);
            if (data instanceof Error) {
                return cb(data);
            }
            opts.format = swap(opts.format);
            if (opts.filename != null) {
                opts.filename = util.replaceExtension(opts.filename, format2ext(opts.format));
            }
            data = cson.createString(data, opts);
            if (data instanceof Error) {
                return cb(data);
            }
            file.contents = new Buffer(data);
            file.path = opts.filename;
            return cb(null, file);
        };
        return map(gcson);
    };

}).call(this);
//# sourceMappingURL=gulp-cson.js.map
