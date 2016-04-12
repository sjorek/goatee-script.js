###
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
###

{Expression}    = require './Expression'

{Utility:{
  arraySlice,
  bindFunction,
  isString,
  isArray,
  isNumber,
  isFunction,
  isExpression,
  parse
}}              = require './Utility'

exports = module?.exports ? this

## Runtime
# -------------
# Implements several expression-runtime related methods.

#  -------------
# @class Runtime
# @namepace GoateeScript
exports.Runtime = class Runtime

  _operations = Expression.operations

  #  -------------
  # @method aliases
  # @return {Array}
  # @static
  Runtime.aliases  = _aliases = do ->
    index = null
    () ->
      index ? index = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$_'.split('')

  #  -------------
  # @method generate
  # @param  {Boolean} [compress=true]
  # @return {String}
  # @static
  Runtime.generate = do ->

    aliases     = []
    for alias in _aliases().reverse() when not _operations[alias]?
      aliases.push alias
    index       = aliases.length

    return if index is 0

    for key, value of _operations when value.name? and not value.alias?
      _operations[value.alias = aliases[--index]] = key
      if index is 0
        break

    _operations['()'].code = """
      function(){
        var a,f;
        f=arguments[0],a=2<=arguments.length?aS(arguments,1):[];
        return f.apply(this,a);
      }
      """

    runtime =

      global        :
        name        : 'global'
        alias       : if index is 0 then '_g' else aliases[--index]
        code        : 'null'

      local         :
        name        : 'local'
        alias       : if index is 0 then '_l' else aliases[--index]
        code        : 'null'

      stack         :
        name        : 'stack'
        alias       : if index is 0 then 'st' else aliases[--index]
        code        : '[]'

      scope         :
        name        : 'scope'
        alias       : if index is 0 then 'sc' else aliases[--index]
        code        : '[]'

      evaluate      :
        name        : 'evaluate'
        alias       : if index is 0 then '_e' else aliases[--index]
        code        : """
                      function(c,e,v,_,$) {
                        var g,r;
                        if(!(isFunction(e) && e.name)){return e;}
                        g = _global === null ? _evaluate : false;
                        if (g) {
                          _global   = c||{};
                          _local    = v||{};
                          _scope    = _||_scope.length = 0||_scope;
                          _stack    = $||_stack.length = 0||_stack;
                          _evaluate = _execute;
                        };
                        r = _execute(c,e);
                        if (g) {
                          _global   = null;
                          _evaluate = g;
                        };
                        return r;
                      }
                      """
        evaluate    : Expression.evaluate

      execute       :
        name        : 'execute'
        alias       : if index is 0 then '_x' else aliases[--index]
        code        : """
                      function(c,e) {
                        var r,f;
                        if(!(isFunction(e) && e.name)){return e;};
                        _scope.push(c);
                        _stack.push(e);
                        try {
                          r = _process(c,e); /* ?!?!?!?! */
                        } catch(f) {};
                        _scope.pop();
                        _stack.pop();
                        return r;
                      }
                      """
        evaluate    : Expression.execute

      call          :
        name        : 'call'
        alias       : if index is 0 then 'ca' else aliases[--index]
        code        : 'Function.prototype.call'

      slice         :
        name        : 'slice'
        alias       : if index is 0 then 'sl' else aliases[--index]
        code        : 'Array.prototype.slice'

      toString      :
        name        : 'toString'
        alias       : if index is 0 then 'tS' else aliases[--index]
        code        : 'Object.prototype.toString'

      booleanize    :
        name        : 'booleanize'
        alias       : if index is 0 then '_b' else aliases[--index]
        evaluate    : Expression.booleanize

      isFunction    :
        name        : 'isFunction'
        alias       : if index is 0 then 'iF' else aliases[--index]
        evaluate    : isFunction

      bindFunction  :
        name        : 'bindFunction'
        alias       : if index is 0 then 'bF' else aliases[--index]
        code        : """
                      (function(bindFunction) {
                        return bindFunction ? function() {
                            return bindFunction.apply(arguments);
                          } : function() {
                            var f, c, a;
                            f = arguments[0];
                            c = arguments[1];
                            a = 3 <= arguments.length ? arraySlice(arguments, 2) : [];
                            return a.length === 0
                              ? function() { return f.call(c); }
                              : function() { return f.apply(c, a); };
                          }
                      })(Function.prototype.bind)
                      """
        evaluate    : bindFunction

      isArray       :
        name        : 'isArray'
        alias       : if index is 0 then 'iA' else aliases[--index]
        code        : """
                      (function(isArray) {
                        return isArray || function(o){return _toString.call(o)==='[object Array]';};
                      })(Array.isArray)
                      """
        evaluate    : isArray

      arraySlice    :
        name        : 'arraySlice'
        alias       : if index is 0 then 'aS' else aliases[--index]
        #code        : '[].slice'
        evaluate    : arraySlice

      hasProperty   :
        name        : 'hasProperty'
        alias       : if index is 0 then 'hP' else aliases[--index]
        code        : """
                      (function(hasProperty) {
                        return function() {
                          hasProperty.apply(arguments);
                        };
                      })({}.hasOwnProperty)
                      """

      isProperty    :
        name        : 'isProperty'
        alias       : if index is 0 then 'iP' else aliases[--index]
        code        : """
                      function() {
                        if(_stack.length < 2){return false;}
                        var p = _stack.length > 1 ? _stack[_stack.length-2] : void(0),
                            c = _stack.length > 0 ? _stack[_stack.length-1] : void(0);
                        return p.toString() === '#{_operations['.'].alias}' && p[1] === c;
                      }
                      """
#      Number        :
#        name        : 'Number'
#        alias       : if index is 0 then 'Nu' else aliases[--index]
#        code        : "Number"
#        evaluate    : Number

    unwrap  = /^function\s*\(([^\)]*)\)\s*\{\s*(\S[\s\S]*[;|\}])\s*\}$/
    pattern = [
      /(\s|\n)+/g                 , ' '
      /_assignment/g              , _operations['='].alias
      /_reference/g               , _operations.reference.alias
      /_global/g                  , runtime.global.alias
      /_local/g                   , runtime.local.alias
      /_scope/g                   , runtime.scope.alias
      /_stack/g                   , runtime.stack.alias
      /_evaluate/g                , runtime.evaluate.alias
      /_execute/g                 , runtime.execute.alias
      /_booleanize/g              , runtime.booleanize.alias
      /__slice\.call|arraySlice/g , runtime.arraySlice.alias
      /_slice/g                   , runtime.slice.alias
      /_call/g                    , runtime.call.alias
      /([^\.])isArray/g           , "$1#{runtime.isArray.alias}"
      /_toString/g                , runtime.toString.alias
      /isNumber/g                 , runtime.global.alias
#      /(Nu)mber/g                 , runtime.Number.alias
      /isFunction/g               , runtime.isFunction.alias
      /bindFunction/g             , runtime.bindFunction.alias
      /_isProperty/g              , runtime.isProperty.alias
      /hasProperty/g              , runtime.hasProperty.alias
      ///
        ([a-zA-Z]+)\.hasOwnProperty\(
      ///g                        , "#{runtime.hasProperty.alias}($1,"
      /(_l)en/g                   , if index is 0 then "$1" else aliases[--index]
      /obj([^e])|item/g           , 'o$1'
      /value/g                    , 'v'
      /\(array,start,end\)/g      , '()'
      /([a-z0-9])\s([^a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([^a-z0-9])/gi, '$1$2'
      /([a-z0-9])\s([^a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([a-z0-9])/gi , '$1$2'
      /([^a-z0-9])\s([^a-z0-9])/gi, '$1$2'
      /return(\S)/gi              , 'return $1'
    ]
    clean  = (key, value, code) ->
      for search, index in pattern by 2
        code = code.replace(search, pattern[index+1])

      if key.length > 1 and key[key.length-1] is '='
        alias = _operations[key.substring(0,key.length-1)].alias
        code = code.replace('_op', alias)

      code

    vars = []
    body = []

    assemble = (object) ->
      for key, value of object when value.name?
        code = clean(
          key, value,
          if value.code? then value.code else value.evaluate.toString()
        )
        vars.push [
          '/* ', key, ' */ ',
          value.alias
        ].join ''
        body.push [
          '/* ', key, ' */ ',
          value.alias, '=', code
        ].join ''

    assemble runtime
    assemble _operations

    code = "var #{vars.join ',\n'};\n#{body.join ';\n'};"
    # remove comments and linebreaks
    js = code
      .replace( /\/\*(?:.|[\r\n])*?\*\/\s*|/g   , ''  )
      .replace( /\s*[;]\s*[\}]/g                , '}' )
      .replace( /([,;])[\r\n]/g                 , '$1')

    (compress=on) ->
      if compress is on then js else code
