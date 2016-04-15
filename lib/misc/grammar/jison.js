
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


/*
 * # Grammar …
 * -----------
 *
 * … this time it's jison.coffee !
 */

(function() {
  module.exports = function(yy, notator) {
    var $1, $2, $3, $4, $5, $6, $7, $8, aop, bop, grammar, o, r;
    grammar = {};
    r = notator.resolve;
    o = notator.operation;

    /* Actually this is not needed, but it looks nicer ;-) */
    $1 = $2 = $3 = $4 = $5 = $6 = $7 = $8 = null;

    /**
     * -------------
     * The parsers scope
     *
     * @type {Object}
     * @property yy
     * @static
     */
    grammar.yy = yy;

    /**
     * -------------
     * assignment operation shortcut
     *
     * @method aop
     * @static
     */
    grammar.aop = aop = function(op) {
      return o("REFERENCE " + op + " Expression", function() {
        return yy.goatee.create($2, [$1, $3]);
      });
    };

    /**
     * -------------
     *  binary operation shortcut
     *
     * @method bop
     * @static
     */
    grammar.bop = bop = function(op) {
      return o("Expression " + op + " Expression", function() {
        return yy.goatee.create($2, [$1, $3]);
      });
    };

    /**
     * List of grammar tokens, automatically set by `Grammar`'s constructor
     *
     * @type {String}
     * @property tokens
     * @static
     */
    grammar.tokens = null;

    /**
     * -------------
     * Use the default jison-lexer
     * @type {Object}
     * @property lex
     * @static
     */
    grammar.lex = {

      /* Declare all lexer tokens */
      rules: [
        r(/\s+/), r(/0x[a-fA-F0-9]+\b/, function() {
          return 'NUMBER';
        }), r(/([1-9][0-9]+|[0-9])(\.[0-9]+)?([eE][-+]?[0-9]+)?\b/, function() {
          return 'NUMBER';
        }), r(/null\b/, function() {
          return 'NULL';
        }), r(/true\b/, function() {
          return 'TRUE';
        }), r(/false\b/, function() {
          return 'FALSE';
        }), r(/if\b/, function() {
          return 'IF';
        }), r(/then\b/, function() {
          return 'THEN';
        }), r(/else\b/, function() {
          return 'ELSE';
        }), r(/return\b/, function() {
          return 'RETURN';
        }), r(/new\b/, function() {
          return 'NEW';
        }), r(/typeof\b/, function() {
          return 'TYPEOF';
        }), r(/void\b/, function() {
          return 'VOID';
        }), r(/instanceof\b/, function() {
          return 'INSTANCEOF';
        }), r(/yield\b/, function() {
          return 'YIELD';
        }), r(/constructor\b/, function() {
          return 'CONSTRUCTOR';
        }), r(/(__proto__|prototype)\b/, function() {
          return 'PROTOTYPE';
        }), r(/this\b/, function() {
          return 'THIS';
        }), r(/[@]/, function() {
          return 'SELF';
        }), r(/[$_][$_0-9]/, function() {
          return 'CONTEXT';
        }), r(/[$_a-zA-Z]\w*/, function() {
          return 'REFERENCE';
        }), r(/"(\\x[a-fA-F0-9]{2}|\\u[a-fA-F0-9]{4}|\\[^xu]|[^\\"])*"/, function() {
          return 'STRING';
        }), r(/'(\\[\/'\\bfnrt]|\\u[a-fA-F0-9]{4}|[^\\'])*'/, function() {
          return 'STRING';
        }), r(/\/\*(?:.|[\r\n])*?\*\//), r(/\./, function() {
          return '.';
        }), r(/\[/, function() {
          return '[';
        }), r(/\]/, function() {
          return ']';
        }), r(/\(/, function() {
          return '(';
        }), r(/\)/, function() {
          return ')';
        }), r(/\?/, function() {
          return '?';
        }), r(':', function() {
          return ':';
        }), r(';', function() {
          return ';';
        }), r(',', function() {
          return ',';
        }), r('{', function() {
          return '{';
        }), r('}', function() {
          return '}';
        }), r('-=', function() {
          return '-=';
        }), r(/\+=/, function() {
          return '+=';
        }), r(/\*=/, function() {
          return '*=';
        }), r(/\/=/, function() {
          return '/=';
        }), r('%=', function() {
          return '%=';
        }), r('--', function() {
          return '--';
        }), r(/\+\+/, function() {
          return '++';
        }), r('>>>=', function() {
          return '>>>=';
        }), r('>>=', function() {
          return '>>=';
        }), r('<<=', function() {
          return '<<=';
        }), r(/\&=/, function() {
          return '&=';
        }), r(/\|=/, function() {
          return '|=';
        }), r(/\^=/, function() {
          return '^=';
        }), r('===', function() {
          return '===';
        }), r('!==', function() {
          return '!==';
        }), r('==', function() {
          return '==';
        }), r('!=', function() {
          return '!=';
        }), r('<=', function() {
          return '<=';
        }), r('>=', function() {
          return '>=';
        }), r('<', function() {
          return '<';
        }), r('>', function() {
          return '>';
        }), r(/\&\&/, function() {
          return '&&';
        }), r(/\|\|/, function() {
          return '||';
        }), r('!', function() {
          return '!';
        }), r('-', function() {
          return '-';
        }), r(/\+/, function() {
          return '+';
        }), r(/\*/, function() {
          return '*';
        }), r(/\//, function() {
          return '/';
        }), r(/\^/, function() {
          return '^';
        }), r('%', function() {
          return '%';
        }), r('>>>', function() {
          return '>>>';
        }), r('>>', function() {
          return '>>';
        }), r('<<', function() {
          return '<<';
        }), r(/\&/, function() {
          return '&';
        }), r(/\|/, function() {
          return '|';
        }), r('~', function() {
          return '~';
        }), r('=', function() {
          return '=';
        }), r('$', function() {
          return 'EOF';
        })
      ]
    };

    /*
     * Operator Precedence
     * # -----------------
     *
     * Declare operator precedence from highest to lowest,
     * see [Operator Precedence](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Operators/Operator_Precedence).
     *
     */

    /**
     * -------------
     * @type {Object}
     * @property operators
     * @static
     */
    grammar.operators = [['left', '.', '[', ']'], ['right', 'NEW'], ['left', '(', ')'], ['nonassoc', '++', '--'], ['right', '!', '~', 'TYPEOF', 'VOID', 'DELETE'], ['left', '*', '/', '%'], ['left', '+', '-'], ['left', '>>>', '>>', '<<'], ['left', '<=', '>=', '<', '>'], ['left', 'IN', 'INSTANCEOF'], ['left', '===', '!==', '==', '!='], ['left', '^'], ['left', '&'], ['left', '|'], ['left', '&&'], ['left', '||'], ['right', '?', ':'], ['right', 'YIELD'], ['right', '=', '+=', '-=', '*=', '/=', '%=', '<<=', '>>=', '>>>=', '&=', '^=', '|='], ['left', ',']].reverse();

    /**
     * -------------
     * The **Script** is the top-level node in the syntax tree.
     * @type {String}
     * @property startSymbol
     * @static
     */
    grammar.startSymbol = 'Script';

    /*
     * # Syntax description …
     * ----------------------
     *
     * To build a grammar, a syntax is needed …
     *
     */

    /**
     * -------------
     * … which is notated here in Backus-Naur-Format.
     * @type {Object}
     * @property bnf
     * @static
     */
    grammar.bnf = {

      /* Since we parse bottom-up, all parsing must end here. */
      Script: [
        r('End', function() {
          return yy.goatee.create('scalar', [void 0]);
        }), r('Statements End', function() {
          return $1;
        }), r('Seperator Statements End', function() {
          return $2;
        })
      ],
      Statements: [
        o('Statement'), o('Statements Seperator Statement', function() {
          if ($1.operator.name === 'block') {
            $1.parameters.push($3);
            return $1;
          } else {
            return yy.goatee.create('block', [$1, $3]);
          }
        })
      ],
      End: [r('EOF'), r('Seperator EOF')],
      Identifier: [o('THIS'), o('REFERENCE')],
      Seperator: [r(';'), r('Seperator ;')],
      Statement: [o('Conditional'), o('Expression')],
      Parameters: [
        o('', function() {
          return [];
        }), o('Expression', function() {
          return [$1];
        }), o('Parameters , Expression', function() {
          return $1.concat($3);
        })
      ],
      Key: [o('Scalar'), o('Primitive'), o('Property')],
      KeyValues: [
        o('Key : Expression', function() {
          return [$1, $3];
        }), o('KeyValues , KeyValues', function() {
          return $1.concat($3);
        })
      ],
      Object: [
        o('{ }', function() {
          return yy.goatee.create('object', []);
        }), o('{ KeyValues }', function() {
          return yy.goatee.create('object', $2);
        })
      ],
      Elements: [
        o('', function() {
          return [];
        }), o('Expression', function() {
          return [$1];
        }), o('Elements , Elements', function() {
          return $1.concat($3.length === 0 ? [void 0] : $3);
        })
      ],
      Array: [
        o('[ Elements ]', function() {
          return yy.goatee.create('array', $2);
        })
      ],
      Block: [
        o('{ Seperator }', function() {
          return yy.goatee.create('scalar', [void 0]);
        }), o('{ Statements }', function() {
          return $2;
        }), o('{ Statements Seperator }', function() {
          return $2;
        })
      ],
      If: [
        o('IF Group Block', function() {
          return yy.goatee.create('if', [$2, $3]);
        }), o('If ELSE IF Group Block', function() {
          return yy.goatee.addElse($1, yy.goatee.create('if', [$4, $5]));
        })
      ],
      Conditional: [
        o('If'), o('If ELSE Block', function() {
          return yy.goatee.addElse($1, $3);
        })
      ],
      IncDec: [o("++"), o("--")],
      Assignment: [
        o("IncDec Identifier", function() {
          return yy.goatee.create($1, [$2, 0]);
        }), o("Identifier IncDec", function() {
          return yy.goatee.create($2, [$1, 1]);
        }), aop('-='), aop('+='), aop('*='), aop('/='), aop('%='), aop('^='), aop('>>>='), aop('>>='), aop('<<='), aop('&='), aop('|='), aop('=')
      ],
      Scalar: [
        o('NUMBER', function() {
          return Number($1);
        }), o('+ NUMBER', function() {
          return +Number($2);
        }), o('- NUMBER', function() {
          return -Number($2);
        }), o('STRING', function() {
          return yy.goatee.escape($1);
        })
      ],
      Primitive: [
        o('NULL', function() {
          return null;
        }), o('TRUE', function() {
          return true;
        }), o('FALSE', function() {
          return false;
        })
      ],
      Operation: [
        bop('*'), bop('/'), bop('%'), bop('+'), bop('-'), o('! Expression', function() {
          return yy.goatee.create('!', [$2]);
        }), bop('<='), bop('>='), bop('<'), bop('>'), bop('==='), bop('!=='), bop('=='), bop('!='), bop('&&'), bop('||'), o('~ Expression', function() {
          return yy.goatee.create('~', [$2]);
        }), bop('>>>'), bop('>>'), bop('<<'), bop('&'), bop('|'), bop('^')
      ],
      Literal: [
        o('Object'), o('Array'), o('Primitive', function() {
          return yy.goatee.create('scalar', [$1]);
        }), o('Scalar', function() {
          return yy.goatee.create('scalar', [$1]);
        })
      ],
      Scope: [
        o('CONTEXT', function() {
          return yy.goatee.create('context', [$1]);
        }), o('SELF', function() {
          return yy.goatee.create('context', [$1]);
        })
      ],
      Reference: [
        o('Identifier', function() {
          return yy.goatee.create('reference', [$1]);
        }), o('Scope Property', function() {
          return yy.goatee.create('.', [$1, yy.goatee.create('property', [$2])]);
        }), o('Scope')
      ],
      Property: [
        o('CONSTRUCTOR'), o('PROTOTYPE'), o('THIS'), o('IF'), o('THEN'), o('ELSE'), o('YIELD'), o('INSTANCEOF'), o('VOID'), o('TYPEOF'), o('NEW'), o('RETURN'), o('CONTEXT'), o('REFERENCE'), o('CONTEXT Property', function() {
          return $1 + $2;
        }), o('CONTEXT Primitive', function() {
          return $1 + $2;
        })
      ],
      Chain: [
        o('Expression . Primitive', function() {
          return yy.goatee.create('.', [$1, yy.goatee.create('property', [$3])]);
        }), o('Expression . Property', function() {
          return yy.goatee.create('.', [$1, yy.goatee.create('property', [$3])]);
        })
      ],
      List: [
        o('Statement'), o('List , Statement', function() {
          if ($1.operator.name === 'list') {
            $1.parameters.push($3);
            return $1;
          } else {
            return yy.goatee.create('list', [$1, $3]);
          }
        })
      ],
      Group: [
        o('( List )', function() {
          return yy.goatee.create('group', [$2]);
        })
      ],
      Expression: [
        o('Expression ? Expression : Expression', function() {
          return yy.goatee.create('?:', [$1, $3, $5]);
        }), o('Expression ( Parameters )', function() {
          return yy.goatee.create('()', [$1].concat($3));
        }), o('Expression [ Expression ]', function() {
          return yy.goatee.create('[]', [$1, $3]);
        }), o('Assignment'), o('Reference'), o('Literal'), o('Operation'), o('Chain'), o('Group')
      ]
    };
    return grammar;
  };

}).call(this);

//# sourceMappingURL=jison.js.map
