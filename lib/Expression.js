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
    var Expression, Stack, bindFunction, exports, isArray, isExpression, isFunction, isNumber, isString, ref, ref1, toString,
        slice = [].slice;

    Stack = require('./Stack').Stack;

    ref = require('./Utility').Utility, bindFunction = ref.bindFunction, toString = ref.toString, isString = ref.isString, isArray = ref.isArray, isNumber = ref.isNumber, isFunction = ref.isFunction, isExpression = ref.isExpression;

    exports = (ref1 = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? ref1 : this;


    /*
     * # Expressions …
     * ---------------
     *
     * … are the glue between runtime-evaluation, -interpretation and
     * -compilation.  The parser emits these expressions, whereas the
     * compiler consumes them.
     */


    /**
     * -------------
     * @class Expression
     * @namespace GoateeScript
     */

    exports.Expression = Expression = (function() {
        var _assignment, _booleanize, _callback, _errors, _evaluate, _execute, _global, _isProperty, _local, _operations, _operator, _parser, _process, _property, _reference, _resolve, _scalar, _scope, _stack, _stringify, _variable;

        _stack = null;

        _scope = null;

        _errors = null;

        _global = null;

        _local = null;

        _operations = null;

        _parser = null;

        _scalar = null;

        _property = null;

        _callback = null;

        _reference = null;

        _variable = null;

        _resolve = null;

        _assignment = null;


        /**
         * -------------
         * Determine if the current state resolves to a property.  Used by
         * `Expression.operations.reference.evaluate`
         *
         * @function _isProperty
         * @return {Boolean}
         * @private
         */

        _isProperty = function() {
            var p;
            p = _stack.previous();
            return (p != null) && p.operator.name === _property && p.parameters[1] === _stack.current();
        };


        /**
         * -------------
         * @method execute
         * @param {Object}           context
         * @param {Expression|mixed} expression
         * @return {mixed}
         * @static
         */

        Expression.execute = _execute = function(context, expression) {
            var e, error, result;
            if (!isExpression(expression)) {
                return expression;
            }
            _stack.push(context, expression);
            try {
                result = _process(context, expression);
            } catch (error) {
                e = error;
                (_errors != null ? _errors : _errors = []).push(e);
            }
            _stack.pop();
            return result;
        };


        /**
         * -------------
         * Set a static callback, to be invoked after an expression has been
         * evaluated, but before the stack gets cleared.  Implemented as:
         *
         *      callback(expression, result, _stack, _errors)
         *
         * @method callback
         * @param  {Function}  A callback-function (closure) to invoke
         * @static
         */

        Expression.callback = function(callback) {
            _callback = callback;
        };


        /**
         * -------------
         * Get an array of all errors caught and collected during evaluation or
         * `false` if none of them occured.
         *
         * @method errors
         * @return {Boolean|Array<Error>}
         * @static
         */

        Expression.errors = function() {
            if ((_errors != null) && _errors.length !== 0) {
                _errors;
            }
            return false;
        };


        /**
         * -------------
         * This is the start and finish of evaluations.  Resets the environment before
         * and after any execution.  This implementation avoids self-recursion as it
         * reassigns the evaluation function.
         *
         * @method evaluate
         * @param {Object}           [context]
         * @param {Expression|mixed} [expression]
         * @param {Object}           [variables]
         * @param {Array}            [scope]
         * @param {Array}            [stack]
         * @return {mixed}
         * @static
         */

        Expression.evaluate = _evaluate = function(context, expression, variables, scope, stack) {
            var isGlobalScope, result;
            if (context == null) {
                context = {};
            }
            if (!isExpression(expression)) {
                return expression;
            }
            isGlobalScope = _stack == null;
            if (isGlobalScope) {
                _stack = new Stack(context, variables, scope, stack);
                _scope = _stack.scope;
                _errors = null;
                _global = _stack.global;
                _local = _stack.local;
                _evaluate = _execute;
            }
            result = _execute(context, expression);
            if (isGlobalScope) {
                if (_callback != null) {
                    _callback(expression, result, _stack, _errors);
                }
                _stack.destructor();
                _stack = null;
                _scope = null;
                _global = null;
                _local = null;
                _evaluate = Expression.evaluate;
            }
            return result;
        };


        /**
         * -------------
         * Process the expression and evaluate its result. Chained (sub-)expressions
         * and vector operations are resolved here.
         *
         * @function _process
         * @param {Object} context
         * @param {Expression} expression
         * @return {mixed}
         * @private
         */

        _process = function(context, expression) {
            var j, left, leftValue, len, len1, m, operator, parameters, right, rightValue, value, values;
            operator = expression.operator, parameters = expression.parameters;
            if (operator.chain) {
                if (parameters.length !== 2) {
                    throw new Error("chain only supports 2 parameters");
                }
                left = parameters[0], right = parameters[1];
                context = _execute(context, left);
                if (left.vector) {
                    values = [];
                    for (j = 0, len = context.length; j < len; j++) {
                        leftValue = context[j];
                        rightValue = _execute(leftValue, right);
                        value = operator.evaluate.call(leftValue, leftValue, rightValue);
                        if (right.vector) {
                            if (!isArray(value)) {
                                throw new Error("vector operation did not return an array as expected: " + (JSON.stringify(operator)));
                            }
                            values.push.apply(values, value);
                        } else if (value != null) {
                            values.push(value);
                        }
                    }
                    return values;
                }
                rightValue = _execute(context, right);
                return operator.evaluate.call(context, context, rightValue);
            }
            if (operator.raw) {
                return operator.evaluate.apply(context, parameters);
            }
            values = [];
            for (m = 0, len1 = parameters.length; m < len1; m++) {
                rightValue = parameters[m];
                values.push(_execute(context, rightValue));
            }
            return operator.evaluate.apply(context, values);
        };


        /**
         * -------------
         * Determine the expression's boolean value, as defined in Ecmascript 3/5/6.
         * Therefor arrays are processed recursivly item by item and if one of them
         * resolves to a false value, this function returns false immediatly.
         *
         * @method booleanize
         * @param  {mixed}   value
         * @return {Booelan}
         * @static
         */

        Expression.booleanize = _booleanize = function(value) {
            var item, j, len;
            if (isArray(value)) {
                for (j = 0, len = value.length; j < len; j++) {
                    item = value[j];
                    if (_booleanize(item)) {
                        return true;
                    }
                }
                return false;
            }
            return Boolean(value);
        };


        /**
         * -------------
         * Returns the given value as string.  If the given value is not an expression
         * `JSON.stringify` will be called to deliver the result.  If the expression's
         * operator has a `format` function (see Èxpression.operations` below) it will
         * be called with the expression parameters, otherwise a string will be build
         * from those parameters.
         *
         * @method stringify
         * @param  {mixed}   value
         * @return {String}
         * @static
         */

        Expression.stringify = _stringify = function(value) {
            var format, j, len, operator, parameter, parameters;
            if (!isExpression(value)) {
                return JSON.stringify(value);
            }
            operator = value.operator, parameters = value.parameters;
            format = operator.format;
            if (format != null) {
                return format.apply(this, parameters);
            } else if (parameters.length === 2) {
                return "" + (_stringify(parameters[0])) + operator + (_stringify(parameters[1]));
            } else {
                format = [];
                for (j = 0, len = parameters.length; j < len; j++) {
                    parameter = parameters[j];
                    format.push(_stringify(parameter));
                }
                return format.join(' ');
            }
        };


        /**
         * -------------
         * A dictionary of all known operations an expression might perform.
         * Used during runtime interpretation, stringification and compilation.
         *
         * @property operations
         * @type {Object}
         * @static
         */

        Expression.operations = _operations = {
            '=': {
                evaluate: function(a, b) {
                    return _local[a] = b;
                }
            },
            '.': {
                chain: true,
                evaluate: function(a, b) {
                    if (a !== _global && isFunction(b)) {
                        return bindFunction(b, a);
                    } else {
                        return b;
                    }
                }
            },
            '&&': {
                raw: true,
                constant: true,
                evaluate: function(a, b) {
                    a = _execute(this, a);
                    if (!a) {
                        return a;
                    }
                    b = _execute(this, b);
                    return b;
                }
            },
            '||': {
                raw: true,
                constant: true,
                evaluate: function(a, b) {
                    a = _execute(this, a);
                    if (a) {
                        return a;
                    }
                    b = _execute(this, b);
                    return b;
                }
            },
            '?:': {
                constant: true,
                raw: true,
                vector: false,
                format: function(a, b, c) {
                    return "(" + (_stringify(a)) + "?" + (_stringify(b)) + ":" + (_stringify(c)) + ")";
                },
                evaluate: function(a, b, c) {
                    a = _execute(this, a);
                    return _execute(this, _booleanize(a) ? b : c);
                }
            },
            '()': {
                vector: false,
                format: function() {
                    var a, f;
                    f = arguments[0], a = 2 <= arguments.length ? slice.call(arguments, 1) : [];
                    return f + '(' + a.join(',') + ')';
                },
                evaluate: function() {
                    var a, f;
                    f = arguments[0], a = 2 <= arguments.length ? slice.call(arguments, 1) : [];
                    if (f == null) {
                        throw new Error("Missing argument to call.");
                    }
                    if (!isFunction(f)) {
                        throw new Error("Given argument is not callable.");
                    }
                    return f.apply(this, a);
                }
            },
            '[]': {
                chain: false,
                vector: false,
                format: function(a, b) {
                    return a + "[" + b + "]";
                },
                evaluate: function(a, b) {
                    if (isNumber(b) && b < 0) {
                        return a[(a.length != null ? a.length : 0) + b];
                    } else {
                        return a[b];
                    }
                }
            },
            context: {
                alias: 'c',
                format: function(c) {
                    switch (c) {
                        case "@":
                            return "this";
                        case "$$":
                            return "_global";
                        case "$_":
                            return "_local";
                        case "_$":
                            return "_scope";
                        case "__":
                            return "_stack";
                        case "$0":
                        case "$1":
                        case "$2":
                        case "$3":
                        case "$4":
                        case "$5":
                        case "$6":
                        case "$7":
                        case "$8":
                        case "$9":
                            return "_scope[" + c[1] + "]";
                        case "_0":
                        case "_1":
                        case "_2":
                        case "_3":
                        case "_4":
                        case "_5":
                        case "_6":
                        case "_7":
                        case "_8":
                        case "_9":
                            return "_scope[_scope.length-" + (c[1] + 1) + "]";
                        default:
                            return "undefined";
                    }
                },
                vector: false,
                evaluate: function(c) {
                    switch (c) {
                        case "@":
                            return this;
                        case "$$":
                            return _global;
                        case "$_":
                            return _local;
                        case "_$":
                            return _scope;
                        case "__":
                            return _stack.stack;
                        case "$0":
                        case "$1":
                        case "$2":
                        case "$3":
                        case "$4":
                        case "$5":
                        case "$6":
                        case "$7":
                        case "$8":
                        case "$9":
                        case "_0":
                        case "_1":
                        case "_2":
                        case "_3":
                        case "_4":
                        case "_5":
                        case "_6":
                        case "_7":
                        case "_8":
                        case "_9":
                            return _scope[c[0] === "$" ? c[1] : _scope.length - c[1] - 1];
                        default:
                            return void 0;
                    }
                }
            },
            property: {
                alias: 'p',
                format: function(a) {
                    return a;
                },
                vector: false,
                evaluate: function(a) {
                    if (a === "constructor" || a === "__proto__" || a === "prototype") {
                        return void 0;
                    } else {
                        return this[a];
                    }
                }
            },
            reference: {
                alias: 'r',
                format: function(a) {
                    if (a === "this") {
                        return "this";
                    } else {
                        return "_resolve(this," + (JSON.stringify(a)) + ")." + a;
                    }
                },
                vector: false,
                evaluate: function(a) {
                    var c, j, v;
                    if (a === "this") {
                        return this;
                    } else if (a === "constructor" || a === "__proto__" || a === "prototype") {
                        return void 0;
                    } else {
                        v = this[a];
                        if (this === _local) {
                            return v;
                        }
                        if (_isProperty()) {
                            if (this.hasOwnProperty(a)) {
                                return v;
                            }
                        } else {
                            if (_local.hasOwnProperty(a)) {
                                return _local[a];
                            }
                            for (j = _scope.length - 1; j >= 0; j += -1) {
                                c = _scope[j];
                                if (c.hasOwnProperty(a)) {
                                    return c[a];
                                }
                            }
                        }
                        return v;
                    }
                }
            },
            scalar: {
                alias: 's',
                constant: true,
                vector: false,
                format: function(a) {
                    if (a === void 0) {
                        return '';
                    } else {
                        return JSON.stringify(a);
                    }
                },
                evaluate: function(a) {
                    return a;
                }
            },
            block: {
                alias: 'b',
                format: function() {
                    var s;
                    s = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                    return s.join(';');
                },
                evaluate: function() {
                    return arguments[arguments.length - 1];
                }
            },
            list: {
                alias: 'l',
                format: function() {
                    var s;
                    s = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                    return "" + (s.join(','));
                },
                evaluate: function() {
                    return arguments[arguments.length - 1];
                }
            },
            group: {
                alias: 'g',
                format: function(l) {
                    return "(" + l + ")";
                },
                evaluate: function(l) {
                    return _execute(this, l);
                }
            },
            "if": {
                alias: 'i',
                raw: true,
                format: function(a, b, c) {
                    if (c != null) {
                        return "if " + a + " {" + b + "} else {" + c + "}";
                    } else {
                        return "if " + a + " {" + b + "}";
                    }
                },
                evaluate: function(a, b, c) {
                    if (_booleanize(_execute(this, a))) {
                        return _execute(this, b);
                    } else if (c != null) {
                        return _execute(this, c);
                    } else {
                        return void 0;
                    }
                }
            },
            array: {
                alias: 'a',
                format: function() {
                    var e;
                    e = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                    return "[" + (e.join(',')) + "]";
                },
                evaluate: function() {
                    var e;
                    e = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                    return e;
                }
            },
            object: {
                alias: 'o',
                format: function() {
                    var i, j, k, len, o;
                    o = [];
                    for (i = j = 0, len = arguments.length; j < len; i = j += 2) {
                        k = arguments[i];
                        o.push(k + ":" + arguments[i + 1]);
                    }
                    return "{" + (o.join(',')) + "}";
                },
                evaluate: function() {
                    var i, j, k, len, o;
                    o = {};
                    for (i = j = 0, len = arguments.length; j < len; i = j += 2) {
                        k = arguments[i];
                        o[k] = arguments[i + 1];
                    }
                    return o;
                }
            }
        };


        /**
         * -------------
         * Fill and add missing `Expression.operations`
         *
         * @function
         * @private
         */

        (function() {
            var _assign, _bools, _incdec, _pairs, _raws, _single, j, key, len, len1, len2, len3, len4, len5, m, n, q, r, ref2, t, value;
            _reference = _operations.reference.format;
            _variable = function(a) {
                return _reference.call(this, a).replace(/^_resolve/, '_variable');
            };
            _resolve = _operations.reference.evaluate;
            _assignment = _operations['='].evaluate;
            _incdec = ['++', '--'];
            _single = ['!', '~'];
            _pairs = ['+', '-', '*', '/', '%', '^', '>>>', '>>', '<<', '&', '|'];
            _bools = ['<', '>', '<=', '>=', '===', '!=='];
            _raws = ['==', '!='];
            _assign = ['=', '-=', '+=', '*=', '/=', '%=', '^=', '>>>=', '>>=', '<<=', '&=', '|='];
            for (j = 0, len = _incdec.length; j < len; j++) {
                key = _incdec[j];
                _operations[key] = {
                    format: (function() {
                        var k;
                        k = key;
                        return function(a, b) {
                            if (b) {
                                return "" + (_variable.call(this, a)) + k;
                            } else {
                                return "" + k + (_variable.call(this, a));
                            }
                        };
                    })(),
                    evaluate: (function() {
                        var i;
                        i = key === "++" ? +1 : -1;
                        return function(a, b) {
                            var c;
                            c = Number(_resolve.call(this, a));
                            _assignment.call(this, a, c + i);
                            if (b) {
                                return c;
                            } else {
                                return c + i;
                            }
                        };
                    })()
                };
            }
            for (m = 0, len1 = _single.length; m < len1; m++) {
                key = _single[m];
                _operations[key] = {
                    constant: true,
                    evaluate: Function("return function(a) { return " + key + " a ; };")()
                };
            }
            ref2 = _pairs.concat(_bools).concat(_raws);
            for (n = 0, len2 = ref2.length; n < len2; n++) {
                key = ref2[n];
                _operations[key] = {
                    constant: true,
                    evaluate: Function("return function(a,b) { return a " + key + " b ; };")()
                };
            }
            for (q = 0, len3 = _bools.length; q < len3; q++) {
                key = _bools[q];
                value = _operations[key];
                value.vector = false;
            }
            for (r = 0, len4 = _raws.length; r < len4; r++) {
                key = _raws[r];
                value = _operations[key];
                value.raw = true;
            }
            for (t = 0, len5 = _assign.length; t < len5; t++) {
                key = _assign[t];
                value = _operations[key] != null ? _operations[key] : _operations[key] = {};
                if (value.format == null) {
                    value.format = (function() {
                        var k;
                        k = key;
                        return function(a, b) {
                            return "" + (_variable.call(this, a)) + k + (_stringify(b));
                        };
                    })();
                }
                if (value.evaluate == null) {
                    value.evaluate = (function() {
                        var _op;
                        _op = _operations[key.substring(0, key.length - 1)].evaluate;
                        return function(a, b) {
                            return _assignment.call(this, a, _op(_resolve.call(this, a), b));
                        };
                    })();
                }
            }
            for (key in _operations) {
                value = _operations[key];
                value.name = key;
                value.toString = (function() {
                    var k;
                    k = key;
                    return function() {
                        return k;
                    };
                })();
                value.toJSON = function() {
                    return this.name;
                };
                if ((value.alias != null) && (_operations[value.alias] == null)) {
                    _operations[value.alias] = key;
                }
            }
            _scalar = _operations.scalar.name;
            _property = _operations['.'].name;
        })();


        /**
         * -------------
         * Lookup an operation by its name (~ key in `Expression.operations`)
         *
         * @method operator
         * @param  {String}  name
         * @return {Object}
         * @throws {Error}
         * @static
         */

        Expression.operator = _operator = function(name) {
            var op;
            if ((op = _operations[name]) != null) {
                if (op.name != null) {
                    return op;
                } else {
                    return _operator(op);
                }
            }
            throw new Error("operation not found: " + name);
        };


        /**
         * -------------
         * The expressions constructor.  Depending on the operations' constant and
         * vector the given paramters might get evaluated here, to save nesting depth.
         *
         * @param  {String} op             expression's operation name
         * @param  {Array}  [parameters]   optional array of parameters
         * @return {Expression|void}       expression or an early resolved new instance
         * @constructor
         */

        function Expression(op, parameters1) {
            var j, len, len1, m, parameter, ref2, ref3;
            this.parameters = parameters1 != null ? parameters1 : [];
            this.operator = _operator(op);
            this.constant = this.operator.constant === true;
            if (this.constant) {
                ref2 = this.parameters;
                for (j = 0, len = ref2.length; j < len; j++) {
                    parameter = ref2[j];
                    if (isExpression(parameter) && !parameter.constant) {
                        this.constant = false;
                        break;
                    }
                }
            }
            this.vector = this.operator.vector;
            if (this.vector === void 0) {
                this.vector = false;
                ref3 = this.parameters;
                for (m = 0, len1 = ref3.length; m < len1; m++) {
                    parameter = ref3[m];
                    if (isExpression(parameter) && parameter.vector) {
                        this.vector = true;
                        break;
                    }
                }
            }
            if (this.constant && this.operator.name !== _scalar) {
                return new Expression('scalar', [this.evaluate(_global)]);
            }
            return;
        }


        /**
         * -------------
         * Allows expressions to be turned into strings
         *
         * @method toString
         * @return {String}
         */

        Expression.prototype.toString = function() {
            if (this.text !== void 0) {
                return this.text;
            }
            return this.text = _stringify(this);
        };


        /**
         * -------------
         * Allows expression to be turned into a kind of json-ast.  See
         * `Compiler.coffee` for a complete ast-implementation
         *
         * @method toJSON
         * @return {Object.<String:op,Array:parameters>}
         */

        Expression.prototype.toJSON = function(callback) {
            var parameter, parameters;
            if (callback) {
                return callback(this);
            }
            if (this.operator.name === 'scalar') {
                parameters = this.parameters;
            } else {
                parameters = (function() {
                    var j, len, ref2, results;
                    ref2 = this.parameters;
                    results = [];
                    for (j = 0, len = ref2.length; j < len; j++) {
                        parameter = ref2[j];
                        if (parameter.toJSON != null) {
                            results.push(parameter.toJSON());
                        } else {
                            results.push(parameter);
                        }
                    }
                    return results;
                }).call(this);
            }
            return [this.operator.name].concat(parameters);
        };


        /**
         * -------------
         * Evaluate this expressions value
         *
         * @method evaluate
         * @param {Object} [context]
         * @param {Object} [variables]
         * @param {Array}  [scope]
         * @param {Array}  [stack]
         * @return {mixed}
         */

        Expression.prototype.evaluate = function(context, variables, scope, stack) {
            return _evaluate(context, this, variables, scope, stack);
        };

        return Expression;

    })();

}).call(this);
//# sourceMappingURL=Expression.js.map
