// Generated by CoffeeScript 1.6.3
/*
© Copyright 2013 Stephan Jorek <stephan.jorek@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
*/


(function() {
  var Compiler, Expression, aliases, arraySlice, bindFunction, exports, isArray, isExpression, isFunction, isNumber, isString, parse, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  Expression = require('./Expression').Expression;

  aliases = require('./Runtime').Runtime.aliases;

  _ref = require('./Utility').Utility, arraySlice = _ref.arraySlice, bindFunction = _ref.bindFunction, isString = _ref.isString, isArray = _ref.isArray, isNumber = _ref.isNumber, isFunction = _ref.isFunction, isExpression = _ref.isExpression, parse = _ref.parse;

  exports = (_ref1 = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? _ref1 : this;

  exports.Compiler = Compiler = (function() {
    var _aliasSymbol, _aliases, _arguments, _compile, _operations, _scalar, _wrap;

    _aliasSymbol = /^[a-zA-Z$_]$/;

    _operations = Expression.operations;

    _scalar = _operations.scalar.name;

    _aliases = aliases().join(',');

    _arguments = ",'" + aliases().join("','") + "'";

    _wrap = function(code, map) {
      var args, k, keys, v;
      if (map != null) {
        keys = isArray(map) ? map : (function() {
          var _results;
          _results = [];
          for (k in map) {
            if (!__hasProp.call(map, k)) continue;
            v = map[k];
            _results.push(k);
          }
          return _results;
        })();
        args = keys.length === 0 ? '' : ",'" + keys.join("','") + "'";
        keys = keys.join(',');
      } else {
        keys = _aliases;
        args = _arguments;
      }
      return "(function(" + keys + ") { return " + code + "; }).call(this" + args + ")";
    };

    function Compiler(parseImpl) {
      this.parseImpl = parseImpl != null ? parseImpl : parse;
    }

    Compiler.prototype.compress = function(ast, map) {
      var c, code, o;
      if (map == null) {
        map = {};
      }
      code = (function() {
        var _i, _len, _ref2, _results;
        _results = [];
        for (_i = 0, _len = ast.length; _i < _len; _i++) {
          o = ast[_i];
          if (o == null) {
            _results.push('' + o);
          } else if (o.length == null) {
            _results.push(o);
          } else if (o.substring != null) {
            if (_aliasSymbol.exec(o)) {
              if (map[o] != null) {
                ++map[o];
              } else {
                map[o] = 1;
              }
              _results.push(o);
            } else {
              _results.push(JSON.stringify(o));
            }
          } else {
            _ref2 = this.compress(o, map), c = _ref2[0], map = _ref2[1];
            _results.push(c);
          }
        }
        return _results;
      }).call(this);
      return ["[" + (code.join(',')) + "]", map];
    };

    Compiler.prototype.expand = (function() {
      var code;
      code = _wrap("function(opcode){ return eval('[' + opcode + '][0]'); }");
      return Function("return " + code)();
    })();

    Compiler.prototype.toExpression = function(opcode) {
      var index, operator, parameters, state, value, _i, _len;
      state = false;
      if ((opcode == null) || !(state = isArray(opcode)) || 2 > (state = opcode.length)) {
        return new Expression('scalar', state ? opcode : [state === 0 ? void 0 : opcode]);
      }
      parameters = [].concat(opcode);
      operator = parameters.shift();
      for (index = _i = 0, _len = parameters.length; _i < _len; index = ++_i) {
        value = parameters[index];
        parameters[index] = isArray(value) ? this.toExpression(value) : value;
      }
      return new Expression(operator, parameters);
    };

    Compiler.prototype.parse = function(code) {
      if (isString(code)) {
        return this.parseImpl(code);
      }
      return this.toExpression(code);
    };

    Compiler.prototype.evaluate = function(code, context, variables, scope, stack) {
      var expression;
      expression = this.parse(code);
      return expression.evaluate(context, variables, scope, stack);
    };

    Compiler.prototype.render = function(code) {
      return this.parse(code).toString();
    };

    Compiler.prototype.save = function(expression, callback, compress) {
      var opcode, parameter, _i, _len, _ref2;
      if (compress == null) {
        compress = true;
      }
      if (compress && expression.operator.name === _scalar) {
        return expression.parameters;
      }
      opcode = [compress && (expression.operator.alias != null) ? expression.operator.alias : expression.operator.name];
      _ref2 = expression.parameters;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        parameter = _ref2[_i];
        opcode.push(isExpression(parameter) ? this.save(parameter, callback, compress) : parameter);
      }
      return opcode;
    };

    Compiler.prototype.ast = function(data, callback, compress) {
      var ast, expression;
      if (compress == null) {
        compress = true;
      }
      expression = isExpression(data) ? data : this.parse(data);
      ast = this.save(expression, callback, compress);
      if (compress) {
        return this.compress(ast);
      } else {
        return ast;
      }
    };

    Compiler.prototype.stringify = function(data, callback, compress) {
      var opcode;
      if (compress == null) {
        compress = true;
      }
      opcode = this.ast(data, callback, compress);
      if (compress) {
        return "[" + opcode[0] + "," + (JSON.stringify(opcode[1])) + "]";
      } else {
        return JSON.stringify(opcode);
      }
    };

    Compiler.prototype.closure = function(data, callback, compress, prefix) {
      var code, opcode;
      if (compress == null) {
        compress = true;
      }
      opcode = this.ast(data, callback, compress);
      if (compress) {
        code = _wrap(opcode);
      } else {
        code = JSON.stringify(opcode);
      }
      return Function("" + (prefix || '') + "return " + code + ";");
    };

    _compile = function() {
      var compress, id, operation, operator, parameter, parameters;
      compress = arguments[0], operator = arguments[1], parameters = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (parameters.length === 0) {
        return JSON.stringify(operator);
      }
      operation = _operations[operator];
      if (isString(operation)) {
        operator = operation;
        operation = _operations[operator];
      }
      if (operator === _scalar) {
        return JSON.stringify(parameters[0]);
      }
      id = compress ? operation.alias : "_[\"" + operator + "\"]";
      parameters = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = parameters.length; _i < _len; _i++) {
          parameter = parameters[_i];
          if (isArray(parameter)) {
            _results.push(_compile.apply(null, [compress].concat(parameter)));
          } else {
            _results.push(JSON.stringify(parameter));
          }
        }
        return _results;
      })();
      return "" + id + "(" + (parameters.join(',')) + ")";
    };

    Compiler.prototype.load = function(data, compress) {
      var opcode;
      if (compress == null) {
        compress = true;
      }
      opcode = isArray(data) ? data : this.expand(data);
      return _compile.apply(null, [compress].concat(opcode));
    };

    Compiler.prototype.compile = function(data, callback, compress) {
      var opcode;
      if (compress == null) {
        compress = true;
      }
      opcode = isArray(data) ? data : this.ast(data, callback, false);
      return this.load(opcode, compress);
    };

    return Compiler;

  })();

}).call(this);

/*
//@ sourceMappingURL=Compiler.map
*/