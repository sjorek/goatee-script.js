/*
© Copyright 2013-2017 Stephan Jorek <stephan.jorek@gmail.com>

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
