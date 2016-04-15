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
    var Utility, exports, ref,
        slice = [].slice;

    exports = (ref = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? ref : this;


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

    exports.Utility = Utility = (function() {
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

}).call(this);
//# sourceMappingURL=Utility.js.map
