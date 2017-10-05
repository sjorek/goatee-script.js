###
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
###

###
# # Grammar …
# -----------
#
# … this time it's jison.coffee !
###
module.exports = (yy, notator) ->

  grammar = {}

  r = notator.resolve
  o = notator.operation

  ### Actually this is not needed, but it looks nicer ;-) ###
  $1 = $2 = $3 = $4 = $5 = $6 = $7 = $8 = null

  ###*
  # -------------
  # The parsers scope
  #
  # @type {Object}
  # @property yy
  # @static
  ###
  grammar.yy = yy

  ###*
  # -------------
  # assignment operation shortcut
  #
  # @method aop
  # @static
  ###
  grammar.aop = aop = (op) -> o "REFERENCE #{op} Expression", ->
    yy.goatee.create $2, [$1, $3]

  ###*
  # -------------
  #  binary operation shortcut
  #
  # @method bop
  # @static
  ###
  grammar.bop = bop = (op) -> o "Expression #{op} Expression", ->
    yy.goatee.create $2, [$1, $3]

  ###*
  # List of grammar tokens, automatically set by `Grammar`'s constructor
  #
  # @type {String}
  # @property tokens
  # @static
  ###
  grammar.tokens = null

  ###*
  # -------------
  # Use the default jison-lexer
  # @type {Object}
  # @property lex
  # @static
  ###
  grammar.lex =

    ### Declare all lexer tokens ###
    rules: [
      # ignore white-spaces
      r /\s+/

      # hexadecimal number
      r /0x[a-fA-F0-9]+\b/        , -> 'NUMBER'

      # decimal number
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
      # not yet implemented:
      #
      #      r /for\b/                   , -> 'FOR'
      #

      # the following reserved word are not allowed and
      # raise exceptions if used in the wrong place
      r /return\b/                , -> 'RETURN'
      r /new\b/                   , -> 'NEW'
      r /typeof\b/                , -> 'TYPEOF'
      r /void\b/                  , -> 'VOID'
      r /instanceof\b/            , -> 'INSTANCEOF'
      r /yield\b/                 , -> 'YIELD'
      r /constructor\b/           , -> 'CONSTRUCTOR'
      r /(__proto__|prototype)\b/ , -> 'PROTOTYPE'

      # identifier has to come AFTER reserved words

      r /this\b/                  , -> 'THIS'       # root context
      r /[@]/                     , -> 'SELF'       # current context

      # access context or variable from …
      #
      # … current scope:
      #
      #     $$ ~ SELF ~ current context
      #     $_        ~ current context's local variables
      #     _$        ~ current context's chain of scopes
      #     __        ~ current context's expression stack
      #
      # … parent contexts:
      #
      #     _0        ~ current - 1 level (parent) context
      #     _1        ~ current - 2 levels (grand-parent) context
      #     _2        ~ current - 3 levels context
      #     …
      #     _9        ~ current - 10 levels context
      #
      # … child contexts:
      #
      #     $9        ~ root + 9 levels context
      #     …
      #     $2        ~ root + 2 levels (grand-child) context
      #     $1        ~ root + 1 level (child) context
      #     $0 ~ THIS ~ root context
      #
      r /[$_][$_0-9]/             , -> 'CONTEXT'

      # mind the delibrately reduced set of allowed (start) characters
      # compare with ES3/ES5/ES6
      r /[$_a-zA-Z]\w*/           , -> 'REFERENCE'

      # identifier above

      # double-quoted string
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

      # single-quoted string
      r ///
        '
        (
          \\[/'\\bfnrt]     |
          \\u[a-fA-F0-9]{4} |
          [^\\']
        )*
        '
        ///                       , -> 'STRING'

      # ignore multiline-comments
      r /\/\*(?:.|[\r\n])*?\*\//

      # accessors below
      r /\./                      , -> '.'
      r /\[/                      , -> '['
      r /\]/                      , -> ']'
      r /\(/                      , -> '('
      r /\)/                      , -> ')'

      # operators below
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
      # Not (!) must be lower priority than != and !==
      r '!'                       , -> '!'

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
      # TODO Figure out why the EOF token is “$”
      r '$'                       , -> 'EOF'
    ]

  ###
  # Operator Precedence
  # # -----------------
  #
  # Declare operator precedence from highest to lowest,
  # see [Operator Precedence](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Operators/Operator_Precedence).
  #
  ###

  ###*
  # -------------
  # @type {Object}
  # @property operators
  # @static
  ###
  grammar.operators = [
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

  # Reverse the operators because jison orders precedence
  # from low to high, and we have it high to low,
  # see [Yacc](http://dinosaur.compilertools.net/yacc/index.html).
  ].reverse()

  ###*
  # -------------
  # The **Script** is the top-level node in the syntax tree.
  # @type {String}
  # @property startSymbol
  # @static
  ###
  grammar.startSymbol = 'Script'

  ###
  # # Syntax description …
  # ----------------------
  #
  # To build a grammar, a syntax is needed …
  #
  ###

  ###*
  # -------------
  # … which is notated here in Backus-Naur-Format.
  # @type {Object}
  # @property bnf
  # @static
  ###
  grammar.bnf =

    ### Since we parse bottom-up, all parsing must end here. ###
    Script: [
      # TODO use a precompiled “undefined” expression in Script » End
      r 'End'                       , -> yy.goatee.create 'scalar', [undefined]
      r 'Statements End'            , -> $1
      r 'Seperator Statements End'  , -> $2
    ]

    Statements: [
      o 'Statement'
      o 'Statements Seperator Statement', ->
        if $1.operator.name is 'block'
          $1.parameters.push $3
          $1
        else
          yy.goatee.create 'block', [$1, $3]
    ]

    End: [
      r 'EOF'
      r 'Seperator EOF'
    ]

    Identifier: [
      o 'THIS'
      o 'REFERENCE'
    ]

    Seperator: [
      r ';'
      r 'Seperator ;'
    ]

    Statement: [
      o 'Conditional'
      o 'Expression'
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
      o '{ }'                       , -> yy.goatee.create 'object', []
      o '{ KeyValues }'             , -> yy.goatee.create 'object', $2
    ]

    Elements: [
      o ''                          , -> []
      o 'Expression'                , -> [$1]
      o 'Elements , Elements'       , ->
        $1.concat if $3.length is 0 then [undefined] else $3
    ]

    Array: [
      o '[ Elements ]'              , -> yy.goatee.create 'array', $2
    ]

    Block: [
      # TODO use a precompiled undefined expression in Block » { Seperator }
      o '{ Seperator }'             , -> yy.goatee.create 'scalar', [undefined]
      o '{ Statements }'            , -> $2
      o '{ Statements Seperator }'  , -> $2
    ]

    If: [
      o 'IF Group Block'            , ->
        yy.goatee.create 'if',  [$2,$3]
      o 'If ELSE IF Group Block'    , ->
        yy.goatee.addElse $1, yy.goatee.create('if', [$4,$5])
    ]

    Conditional: [
      o 'If'
      o 'If ELSE Block'             , -> yy.goatee.addElse $1, $3
    ]

    IncDec: [
      o "++"
      o "--"
    ]

    Assignment: [
      o "IncDec Identifier"         , -> yy.goatee.create $1, [$2, 0]
      o "Identifier IncDec"         , -> yy.goatee.create $2, [$1, 1]
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
      o 'STRING'                    , -> yy.goatee.escape($1)
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
        yy.goatee.create '!' , [$2]
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
         yy.goatee.create '~' , [$2]
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
      o 'Primitive'                 , ->                # boolean, null
        yy.goatee.create 'scalar',  [$1]
      o 'Scalar'                    , ->                # number, string
        yy.goatee.create 'scalar',  [$1]
    ]

    Scope: [
      o 'CONTEXT'                   , ->                # context reference
        yy.goatee.create 'context', [$1]
      o 'SELF'                      , ->                # this reference ≠ this
        yy.goatee.create 'context', [$1]
    ]

    Reference: [
      o 'Identifier'              , ->
        yy.goatee.create 'reference', [$1]
      o 'Scope Property'          , ->                  # shorthand dot operator
        yy.goatee.create '.', [$1, yy.goatee.create('property', [$2])]
      o 'Scope'
    ]

    Property: [
      # CONSTRUCTOR and PROTOTYPE should be safe …
      o 'CONSTRUCTOR'
      o 'PROTOTYPE'
      # … if not remove them here and adjust tests accordingly !
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
      o 'CONTEXT Property'        , -> $1 + $2
      o 'CONTEXT Primitive'       , -> $1 + $2
    ]

    Chain: [
      o 'Expression . Primitive'  , ->
        yy.goatee.create '.', [$1, yy.goatee.create('property', [$3])]
      o 'Expression . Property'   , ->
        yy.goatee.create '.', [$1, yy.goatee.create('property', [$3])]
    ]

    List: [
      o 'Statement'
      o 'List , Statement'        , ->
        if $1.operator.name is 'list'
          $1.parameters.push $3
          $1
        else
          yy.goatee.create 'list', [$1, $3]
    ]

    Group: [
      o '( List )'                , -> yy.goatee.create 'group', [$2]
    ]

    Expression: [
      o 'Expression ? Expression : Expression', ->      # ternary conditional
        yy.goatee.create '?:', [$1, $3, $5]
      o 'Expression ( Parameters )', ->                 # function call
        yy.goatee.create '()', [$1].concat $3
      o 'Expression [ Expression ]', ->                 # indexer
        yy.goatee.create '[]', [$1, $3]
      o 'Assignment'
      o 'Reference'
      o 'Literal'
      o 'Operation'
      o 'Chain'
      o 'Group'
    ]

  grammar
