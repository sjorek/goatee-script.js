###
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
###

{Parser} = require 'jison'
yy       = require('./Scope').Scope

root = module?.exports ? this

$1 = $2 = $3 = $4 = $5 = $6 = $7 = $8 = null

#  lifted from coffeescript http:#jashkenas.github.com/coffee-script/documentation/docs/grammar.html
unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/

# return
r = (patternString, action) ->
    if patternString.source?
        patternString = patternString.source
    return [patternString, 'return;'] unless action
    action = if match = unwrap.exec action then match[1] else "(#{action}())"
    [patternString, "return #{action};"]

# operation
o = (patternString, action, options) ->
    return [patternString, '$$ = $1;', options] unless action
    action = if match = unwrap.exec action then match[1] else "(#{action}())"
    [patternString, "$$ = #{action};", options]

#  assignment operation shortcut
aop = (op) -> o "Identifier #{op} Expression", ->
  new yy.Expression $2, [$1, $3]

#  binary operation shortcut
bop = (op) -> o "Expression #{op} Expression", ->
  new yy.Expression $2, [$1, $3]

root.Grammar = Grammar =
  comment: 'Goatee Expression Parser'
  header: (comment) ->
      """
      /* #{comment} */
      (function() {

      """
  footer: ->
      """

      parser.yy = require('./Scope').Scope;

      }).call(this);
      """
  lex:
    rules: [
      r /\s+/                     , ->
      r /0[xX][a-fA-F0-9]+\b/     , -> 'NUMBER'
      r ///
        ([1-9][0-9]+|[0-9])
        (\.[0-9]+)?
        ([eE][-+]?[0-9]+)?
        \b
        ///                       , -> 'NUMBER'
      # constants
      r /null\b/                  , -> 'NULL'
      r /true\b/                  , -> 'TRUE'
      r /false\b/                 , -> 'FALSE'
      # control flow statements
      r /if\b/                    , -> 'IF'
      r /then\b/                  , -> 'THEN'
      r /else\b/                  , -> 'ELSE'
      #r /for\b/                   , -> 'FOR'
      r /return\b/                , -> 'RETURN'
      # operational statements
      r /new\b/                   , -> 'NEW'
      r /typeof\b/                , -> 'TYPEOF'
      r /void\b/                  , -> 'VOID'
      r /instanceof\b/            , -> 'INSTANCEOF'
      r /yield\b/                 , -> 'YIELD'

      r /[@$]/                    , -> 'CONTEXT'
      r /[$_a-zA-Z]\w*/           , -> 'REFERENCE'
      # identifier has to come AFTER reserved words

      # identifier above
      r ///
        "
        (
          \\x[a-fA-F0-9]{2} |
          \\u[a-fA-F0-9]{4} |
          \\[^xu]           |
          [^\\"]
        )*
        "
        ///                       , -> 'STRING'
      r ///
        '
        (
          \\[/'\\bfnrt]     |
          \\u[a-fA-F0-9]{4} |
          [^\\']
        )*
        '
        ///                       , -> 'STRING'
      r /\/\*(?:.|[\r\n])*?\*\//  , ->
      # operators below

      r /\./                      , -> '.'
      r /\[/                      , -> '['
      r /\]/                      , -> ']'
      r /\(/                      , -> '('
      r /\)/                      , -> ')'

      r /\?/                      , -> '?'
      r ':'                       , -> ':'
      r ';'                       , -> ';'
      r ','                       , -> ','
      r '{'                       , -> '{'
      r '}'                       , -> '}'
      # Mathematical assigment operators
      r '-='                      , ->   '-='
      r /\+=/                     , ->   '+='
      r /\*=/                     , ->   '*='
      r /\/=/                     , ->   '/='
      r '%='                      , ->   '%='
      # Bitwise assigment operators
      r '>>>='                    , -> '>>>='
      r '>>='                     , ->  '>>='
      r '<<='                     , ->  '<<='
      r /\&=/                     , ->   '&='
      r /\|=/                     , ->   '|='
      r /\^=/                     , ->   '^='
      # Boolean operators
      r '==='                     , -> '==='
      r '!=='                     , -> '!=='
      r '=='                      , -> '=='
      r '!='                      , -> '!='
      r '<='                      , -> '<='
      r '>='                      , -> '>='
      r '<'                       , -> '<'
      r '>'                       , -> '>'
      r /\&\&/                    , -> '&&'
      r /\|\|/                    , -> '||'
      r '!'                       , -> '!'    # must be lower priority than != and !==
      # Mathemetical operators
      r '-'                       , -> '-'
      r /\+/                      , -> '+'
      r /\*/                      , -> '*'
      r /\//                      , -> '/'
      r /\^/                      , -> '^'
      r '%'                       , -> '%'
      # Bitwise operators
      r '>>>'                     , -> '>>>'
      r '>>'                      , -> '>>'
      r '<<'                      , -> '<<'
      r /\&/                      , -> '&'
      r /\|/                      , -> '|'
      r '~'                       , -> '~'
      # Assignment operator
      r '='                       , -> '='
      # EOF is always last …
      r '$'                       , -> 'EOF' # TODO have to figure out why the token is “$”
    ]
  operators: [
    # from highest to lowest precedence
    # @see https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Operators/Operator_Precedence
    ['left', '.', '[', ']']                  #  1 member
    ['right', 'NEW']                         #    new
    ['left', '(', ')']                       #  2 call
    ['nonassoc', '++', '--']                 #  3 decrement
    ['right', '!', '~', \ # '+', '-', \      #  4 usually contains unary +/-
              'TYPEOF', 'VOID', 'DELETE']
    ['left', '*', '/', '%']                  #  5 multiply, divide, modulus
    ['left', '+', '-']                       #  6 plus/add, minus/substract
    ['left', '>>>', '>>', '<<']              #  7 bitwise shift
    ['left', '<=', '>=', '<', '>']           #  8 relational
    ['left', 'IN', 'INSTANCEOF']             #   … in …, … instanceof …
    ['left', '===', '!==', '==', '!=']       #  9 equality
    ['left', '^']                            # 11 bitwise and
    ['left', '&']                            # 10 bitwise xor
    ['left', '|']                            # 12 bitwise or
    ['left', '&&']                           # 13 logical and
    ['left', '||']                           # 14 logical or
    ['right', '?', ':']                      # 15 inline conditional
    ['right', 'YIELD']                       # 16 yield is not (yet?) supported
    ['right', '=',    '+=', '-=',  '*=', \   # 17 assignments
              '/=',   '%=', '<<=', '>>=',
              '>>>=', '&=', '^=',  '|=']
    ['left', ',']                            # 18 comma
  # Reverse the operators because Jison orders precedence from low to high,
  # and we have it high to low
  # (as in [Yacc](http://dinosaur.compilertools.net/yacc/index.html)).
  ].reverse()
  startSymbol : 'Root'

  ##
  # The syntax description
  # ----------------------
  bnf:
    # The **Root** is the top-level node in the syntax tree.
    # Since we parse bottom-up, all parsing must end here.
    Root: [
      r 'EOF'                       , ->
        new yy.Expression 'primitive', [null]
      r 'Statements EOF'   , ->
        if $1 is yy.Empty then new yy.Expression 'primitive', [null] else $1
    ]
    Statements: [
      o 'Seperator Seperated Seperator', -> $2
      o 'Seperator Seperated'          , -> $2
      o 'Seperated Seperator'
      o 'Seperated'
      o 'Seperator'
    ]
    Seperator: [
      o ';'                         , -> yy.Empty
      o 'Seperator ;'               , -> yy.Empty
    ]
    Seperated: [
      o 'Statement'
      o 'Seperated Seperator Statement', ->
        if $1 is yy.Empty
          if $3 is yy.Empty
            yy.Empty
          else
            new yy.Expression 'block', [$3]
        else if $1.operator.name is 'block'
          $1.parameters.push $3 unless $3 is yy.Empty
          $1
        else if $3 is yy.Empty
          new yy.Expression 'block', [$1]
        else
          new yy.Expression 'block', [$1, $3]
    ]
    Statement: [
      o 'Expression'
      o 'Conditional'
    ]
    Parameters: [
      o ''                          , -> []
      o 'Expression'                , -> [$1]
      o 'Parameters , Expression'   , -> $1.concat $3
    ]
    Key: [
      o 'Primitive'
      o 'Identifier'
    ]
    KeyValue: [
      o 'Key : Expression'          , -> [$1,$3]
    ]
    KeyValues: [
      o ''                          , -> []
      o 'KeyValue'
      o 'KeyValues , KeyValue'      , -> $1.concat $3
    ]
    Object: [
      o '{ KeyValues }'             , ->
        new yy.Expression 'object', $2
    ]
    Elements: [
      o ''                          , -> []
      o 'Expression'                , -> [$1]
      o 'Elements , Expression'     , -> $1.concat $3
    ]
    Array: [
      o '[ Elements ]'              , ->
        new yy.Expression 'array', $2
    ]
    Block: [
      o '{ }'                       , ->
        new yy.Expression 'primitive', [null]
      o '{ Statements }'   , ->
        if $2 is yy.Empty then new yy.Expression 'primitive', [null] else $2
    ]
    Conditional: [
      o 'IF ( Expression ) Block ELSE Conditional' , ->
        new yy.Expression 'if',  [$3,$5,$7]
      o 'IF ( Expression ) Block ELSE Block'       , ->
        new yy.Expression 'if',  [$3,$5,$7]
      o 'IF ( Expression ) Block'                  , ->
        new yy.Expression 'if',  [$3,$5]
      #o 'FOR ( Expression ) Block'                 , ->
      #  new yy.Expression 'for', [$2,$3]
    ]
    Assignment: [
      aop '-='
      aop '+='
      aop '*='
      aop '/='
      aop '%='
      aop '^='
      aop '>>>='
      aop '>>='
      aop '<<='
      aop '&='
      aop '|='
      aop '='
    ]
    Primitive: [
      o 'NUMBER'                    , -> Number($1)
      o '+ NUMBER'                  , -> + Number($2)
      o '- NUMBER'                  , -> - Number($2)
      o 'NULL'                      , -> null
      o 'TRUE'                      , -> true
      o 'FALSE'                     , -> false
      o 'STRING'                    , -> yy.escapeString($1)
    ]
    Operation: [
      # Mathemetical operations
      bop '*'
      bop '/'
      bop '%'
      bop '+'
      bop '-'
      # Boolean operations
      o '! Expression'              , ->                # logical not
        new yy.Expression '!' , [$2]
      bop '<='
      bop '>='
      bop '<'
      bop '>'
      bop '==='
      bop '!=='
      bop '=='
      bop '!='
      bop '&&'
      bop '||'
      # Bitwise operations
      o '~ Expression'              , ->                # bitwise not
         new yy.Expression '~' , [$2]
      bop '>>>'
      bop '>>'
      bop '<<'
      bop '&'
      bop '|'
      bop '^'
    ]
    Literal: [
      o 'Object'                                        # object literal
      o 'Array'                                         # array literal
      o 'Primitive'                , ->                 # number, boolean,
        new yy.Expression 'primitive',  [$1]            # string, null
    ]
    Identifier: [
      o 'REFERENCE'
    ]
    Scope: [
      o 'CONTEXT'                  , ->                 # global or local
        new yy.Expression 'context', [$1[0]]            # only the first letter is used
    ]
    Reference: [
      o 'Identifier'               , ->
        new yy.Expression 'reference', [$1]
      o 'Scope Identifier'         , ->                 # shorthand dot operator
        new yy.Expression '.', [$1, new yy.Expression('reference', [$2])]
      o 'Scope'
    ]
    Group: [
      o '( Expression )'          , -> $2
    ]
    Path: [
      o 'Expression . Identifier' , ->
        new yy.Expression '.', [$1, new yy.Expression('reference', [$3])]
    ]
    Expression: [
      o 'Expression ? Expression : Expression', ->      # ternary conditional
        new yy.Expression '?:', [$1, $3, $5]
      o 'Expression ( Parameters )', ->                 # function call
        new yy.Expression '()', [$1].concat $3
      o 'Expression [ Expression ]', ->                 # indexer
        new yy.Expression '[]', [$1, $3]
      o 'Assignment'
      o 'Reference'
      o 'Literal'
      o 'Operation'
      o 'Path'
      o 'Group'
    ]

# Wrapping Up
# -----------

# Finally, now that we have our **Grammar.bnf** and our **Grammar.operators**,
# we can create our **Jison.Parser**.  We do this by processing all of our
# rules, recording all terminals (every symbol which does not appear as the
# name of a rule above) as "tokens".
Grammar.tokens = do ->
  tokens = []
  bnf = Grammar.bnf
  known = {}
  tokenize = (name, alternatives) ->
    for alt in alternatives
      for token in alt[0].split ' '
        tokens.push token if not bnf[token]? and not known[token]?
        known[token] = true
      alt[1] = "#{alt[1]}" if name is 'Root'
      alt
  for own name, alternatives of bnf
    bnf[name] = tokenize(name, alternatives)
  tokens.join ' '

# Initialize the **Parser** with our **Grammar**
Grammar.createParser = (grammar = Grammar, scope = yy) ->
    parser = new Parser grammar
    parser.yy = scope
    parser
