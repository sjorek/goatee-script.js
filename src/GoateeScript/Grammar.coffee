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

exports = module?.exports ? this

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
aop = (op) -> o "REFERENCE #{op} Expression", ->
  new yy.Expression $2, [$1, $3]

#  binary operation shortcut
bop = (op) -> o "Expression #{op} Expression", ->
  new yy.Expression $2, [$1, $3]

exports.Grammar = Grammar =
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

      r /this\b/                  , -> 'THIS'
      r /[@]/                     , -> 'SELF'
      r /[$_]/                    , -> 'CONTEXT'
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
      r '--'                      , -> '--'
      r /\+\+/                    , -> '++'
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

  ##
  # The syntax description
  # ----------------------

  startSymbol : 'Script'
#  startSymbol : 'Map'

  bnf:
    # The **Script** is the top-level node in the syntax tree.
    # Since we parse bottom-up, all parsing must end here.
    Script: [
      r 'End'                       , -> new yy.Expression 'scalar', [undefined]
      r 'Statements End'            , -> $1
      r 'Seperator Statements End'  , -> $2
    ]
    # The **Map** is the top-level node in the syntax tree.
    # Since we parse bottom-up, all parsing must end here.
    Map: [
      r 'End'                       , -> new yy.Expression 'scalar', [undefined]
      r 'Rules End'                 , -> $1
      r 'Seperator Rules End'       , -> $2
    ]
    End: [
      r 'EOF'
      r 'Seperator EOF'
    ]
    Identifier: [
      o 'THIS'
      o 'REFERENCE'
    ]
    Statements: [
      o 'Statement'
      o 'Statements Seperator Statement', ->
        if $1.operator.name is 'block'
          $1.parameters.push $3
          $1
        else
          new yy.Expression 'block', [$1, $3]
    ]
    Rules: [
      o 'Rule'
      o 'Rules Seperator Rule'          , ->
        if $1.operator.name is 'block'
          $1.parameters.push $3
          $1
        else
          new yy.Expression 'block', [$1, $3]
    ]
    Rule: [
      o 'REFERENCE : List'              , ->
        new yy.Expression '=', [$1,
          if $3.operator.name is 'list'
            new yy.Expression 'group', [$3]
          else
            $3
        ]
    ]
    Seperator: [
      r ';'
      r 'Seperator ;'
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
      o 'Scalar'
      o 'Primitive'
      o 'Property'
    ]
    KeyValues: [
      o 'Key : Expression'          , -> [$1,$3]
      o 'KeyValues , KeyValues'     , -> $1.concat $3
    ]
    Object: [
      o '{ }'                       , -> new yy.Expression 'object', []
      o '{ KeyValues }'             , -> new yy.Expression 'object', $2
    ]
    Elements: [
      o ''                          , -> []
      o 'Expression'                , -> [$1]
      o 'Elements , Elements'       , ->
        $1.concat if $3.length is 0 then [undefined] else $3
    ]
    Array: [
      o '[ Elements ]'              , -> new yy.Expression 'array', $2
    ]
    Block: [
      o '{ Seperator }'             , -> new yy.Expression 'scalar', [undefined]
      o '{ Statements }'            , -> $2
      o '{ Statements Seperator }'  , -> $2
    ]
    Conditional: [
      o 'IF Group Block ELSE Conditional' , ->
        new yy.Expression 'if',  [$2,$3,$5]
      o 'IF Group Block ELSE Block'     , ->
        new yy.Expression 'if',  [$2,$3,$5]
      o 'IF Group Block'                , ->
        new yy.Expression 'if',  [$2,$3]
# THEN and ELSE conflict with Property and Reference
#      o 'IF Expression THEN Expression ELSE Statement' , ->
#        if $2.operator.name is 'group'
#          new yy.Expression 'if',  [$2,$4,$6]
#        else
#          new yy.Expression 'if',  [new yy.Expression('group', [$2]),$4,$6]
#      o 'IF Expression THEN Statement'       , ->
#        if $2.operator.name is 'group'
#          new yy.Expression 'if',  [$2,$4]
#        else
#          new yy.Expression 'if',  [new yy.Expression('group', [$2]),$4]

#      o 'FOR Expression Block'                 , ->
#        new yy.Expression 'for', [$2,$3]
    ]
    IncDec: [
      o "++"
      o "--"
    ]
    Assignment: [
      o "IncDec Identifier"                       , ->
        new yy.Expression $1, [$2, 0]
      o "Identifier IncDec"                       , ->
        new yy.Expression $2, [$1, 1]
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
    Scalar: [
      o 'NUMBER'                    , -> Number($1)
      o '+ NUMBER'                  , -> + Number($2)
      o '- NUMBER'                  , -> - Number($2)
      o 'STRING'                    , -> yy.escapeString($1)
    ]
    Primitive: [
      o 'NULL'                      , -> null
      o 'TRUE'                      , -> true
      o 'FALSE'                     , -> false
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
      o 'Scalar'                    , ->                # number, string
        new yy.Expression 'scalar',  [$1]
      o 'Primitive'                 , ->                # boolean, null
        new yy.Expression 'scalar',  [$1]
    ]
    Scope: [
      o 'CONTEXT'                   , ->                # global or local
        new yy.Expression 'context', [$1[0]]            # only the first letter is used
      o 'SELF'                      , ->                # this
        new yy.Expression 'context', [$1[0]]            # only the first letter is used
    ]
    Reference: [
      o 'Identifier'              , ->
        new yy.Expression 'reference', [$1]
      o 'Scope Property'          , ->                  # shorthand dot operator
        new yy.Expression '.', [$1, new yy.Expression('property', [$2])]
      o 'Scope'
    ]
    Property: [
      o 'THIS'
      o 'IF'
      o 'THEN'
      o 'ELSE'
      o 'YIELD'
      o 'INSTANCEOF'
      o 'VOID'
      o 'TYPEOF'
      o 'NEW'
      o 'RETURN'
      o 'CONTEXT'
      o 'REFERENCE'
      o 'CONTEXT Property'        , -> "#{$1}#{$2}"
      o 'CONTEXT Primitive'       , -> "#{$1}#{$2}"
    ]
    Chain: [
      o 'Expression . Primitive'  , ->
        new yy.Expression '.', [$1, new yy.Expression('property', [$3])]
      o 'Expression . Property'   , ->
        new yy.Expression '.', [$1, new yy.Expression('property', [$3])]
#      o 'Expression . THEN'   , ->
#        new yy.Expression '.', [$1, new yy.Expression('property', [$3])]
#      o 'Expression . ELSE'   , ->
#        new yy.Expression '.', [$1, new yy.Expression('property', [$3])]
    ]
    List: [
      o 'Statement'
      o 'List , Statement'        , ->
        if $1.operator.name is 'list'
          $1.parameters.push $3
          $1
        else
          new yy.Expression 'list', [$1, $3]
    ]
    Group: [
      o '( List )'                , -> new yy.Expression 'group', [$2]
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
      o 'Chain'
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
      alt[1] = "#{alt[1]}" if name is 'Script'
      alt
  for own name, alternatives of bnf
    bnf[name] = tokenize(name, alternatives)
  tokens.join ' '

# Initialize the **Parser** with our **Grammar**
Grammar.createParser = (grammar = Grammar, scope = yy) ->
    parser = new Parser grammar
    parser.yy = scope
    parser
