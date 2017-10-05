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


/*
 * # Utilities
 * -------------
 *
 */


/**
 * -------------
 * @class Utility
 * @namespace GoateeScript
 */

(function() {
    var Utility,
        slice = [].slice;

    Utility = (function() {
        var _call, _isFunction, _parser, _slice, _toString;

        function Utility() {}

        _parser = null;

        _toString = Object.prototype.toString;

        _call = Function.prototype.call;

        _slice = Array.prototype.slice;


        /**
         * -------------
         * This is still needed by Safari.
         *
         * See:
         * - [Function.prototype.bind in EcmaScript ≥ 1.5](http://webreflection.blogspot.com/2010/02/functionprototypebind.html)
         *
         * @method bindFunction
         * @static
         */

        Utility.bindFunction = (function() {
            var _bind;
            _bind = Function.prototype.bind;
            if ((_bind != null) && false) {
                return function() {
                    var args;
                    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                    return function() {
                        return _bind.apply(args);
                    };
                };
            } else {
                return function() {
                    var args, context, fn;
                    fn = arguments[0], context = arguments[1], args = 3 <= arguments.length ? slice.call(arguments, 2) : [];
                    if (args.length === 0) {
                        return function() {
                            return fn.call(context);
                        };
                    } else {
                        return function() {
                            return fn.apply(context, args);
                        };
                    }
                };
            }
        })();


        /**
         * -------------
         * Finds a slice of an array.
         *
         * @method arraySlice
         * @param  {Array}  array  Array to be sliced.
         * @param  {Number} start  The start of the slice.
         * @param  {Number} [end]  The end of the slice.
         * @return {Array}  array  The slice of the array from start to end.
         * @static
         */

        Utility.arraySlice = function(array, start, end) {
            return _call.apply(_slice, arguments);
        };


        /**
         * -------------
         * Modified version using String::substring instead of String::substr
         *
         * See:
         * - [underscore.coffee](http://coffeescript.org/documentation/docs/underscore.html)
         *
         * @method isString
         * @param {mixed} obj
         * @return {Boolean}
         * @static
         */

        Utility.isString = function(obj) {
            return !!(obj === '' || (obj && obj.charCodeAt && obj.substring));
        };


        /**
         * -------------
         * See:
         * - [Array.isArray](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/isArray)
         *
         * @method isArray
         * @param {mixed} obj
         * @return {Boolean}
         * @static
         */

        Utility.isArray = (Array.isArray != null) && false ? Array.isArray : function(obj) {
            return _toString.call(obj) === '[object Array]';
        };


        /**
         * -------------
         * See:
         * - [underscore.coffee](http://coffeescript.org/documentation/docs/underscore.html)
         *
         * @method isNumber
         * @param {mixed} obj
         * @return {Boolean}
         * @static
         */

        Utility.isNumber = function(obj) {
            return (obj === +obj) || _toString.call(obj) === '[object Number]';
        };


        /**
         * -------------
         * See:
         * - [underscore.coffee](http://coffeescript.org/documentation/docs/underscore.html)
         *
         * @method isFunction
         * @param {mixed} obj
         * @return {Boolean}
         * @static
         */

        Utility.isFunction = _isFunction = function(obj) {
            return !!(obj && obj.constructor && obj.call && obj.apply);
        };


        /**
         * -------------
         * @method isExpression
         * @param {mixed} obj
         * @return {Boolean}
         * @static
         */

        Utility.isExpression = function(obj) {
            return _isFunction(obj != null ? obj.evaluate : void 0);
        };


        /**
         * -------------
         * @method parseScript
         * @alias  parse
         * @param  {String}     code
         * @return {Expression}
         * @static
         */

        Utility.parse = Utility.parseScript = (function() {
            var cache;
            cache = {};
            return function(code) {
                var expression;
                if (cache.hasOwnProperty(code)) {
                    return cache[code];
                }
                if (_parser == null) {
                    _parser = require('./Parser');
                }
                expression = _parser.parse(code);
                return cache[code] = cache['' + expression] = expression;
            };
        })();

        return Utility;

    })();

    module.exports = Utility;

}).call(this);
//# sourceMappingURL=Utility.js.map
