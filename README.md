=============
goatee-script
=============
         _______  _______  _______  _______  _______  _______
        |    ___||       ||       ||_     _||    ___||    ___|
        |   | __ |   _   ||   _   |  |   |  |   |___ |   |___
        |   ||  ||  |_|  ||  |_|  |  |   |  |    ___||    ___|
        |   |_| ||       ||   _   |  |   |  |   |___ |   |___
        |_______||_______||__| |__|  |___|  |_______||_______|
                                         . ,
                                         (\\
                                      .--, \\__
                                       `-.     *`-.__
                                         |          ')
                                        / \__.-'-, ~;
                                       /     |   { /
                        ._..,-.-"``~"-'      ;    (
                     .;'                    ;'    ´
                ~;,./                      ;'
                   ';                     ;'
                    ';                 /;'|
                     |    .;._.,;';\   |  |
                     \   /  /       \  |\ |
                      \ || |         | )| )
                      | || |         | || |
                ~~~~~ | \| \  ~~~~~~ | \| \  ~~~~~~~
                "''"' `##`##' "'"''" `##`##' '"''"'"
                '"'"''"'"''"''"''"'"'''"'"'''"''"'"'
                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
           _______  _______  ______    ___  _______  _______
          |  _____||     __||    _ |  |   ||    _  ||_     _|
          | |_____ |    |   |   |_||_ |   ||   |_| |  |   |
          |_____  ||    |   |    __  ||   ||    ___|  |   |
           _____| ||    |__ |   |  | ||   ||   |      |   |
          |_______||_______||___|  |_||___||___|      |___|

> :-{>~ A goatee is the perfect complement for handlebar mustaches. ~<}-:

GoateeScript provides an unique language that is implemented in, modelled after
and compiled to “ordinary” javascript. Sounds complicated ? It isn't ! Look at
the following example:

- Javascript:

    (function() { var test = 1 + 2 * 3 ; return test })();

- Coffeescript:

    do -> test = 1 + 2 * 3

- Goateescript:

    test = 1 + 2 * 3

All three examples are equivalent, the first two are just indentical and all of
them return … guess what ? … the number 7 !

## Javascript – the source and destination

The rule of thumb is: a goateescript is a single javascript expression without
any declarations or a collection of expressions suiteable to fit into a single
line. The last expression's value is always returned to the invoking context.

### Similarities to javascript

- The language is a subset of javascript, without any differences in syntax
  but with less grammar. You could take a goatee-script and run it as javascript
  … but usally you will get a completly different result

### Differences to javascript

- Variable assigments are always local to the given script
- Scripts have one or multiple contexts for each execution
- Scripts are either directly interpreted at runtime, compiled
  to interpretable bytecode (usefull for runtimes implemented
  in other languages than javascript), or pre-compiled to
  javascript, which is the fastest and production way to go
- Function declarations are forbidden
  - Hence not implemented
  - Of course you can use functions, provided by the context
  - You could provide methods to declare them, which would be somewhat arkward,
    but possible
- Regular-Expression declarations are forbidden
  - Hence not implemented
  - Of course you can use regular expressions, provided by the context
  - You could provide methods to declare them, which would be somewhat arkward,
    but possible
- Most javascript statements are forbidden
  - With the exception of “if”/“else” statements all the others (“for”, “return”
    “switch”, “yield” and so on) are not implemented.  This might change in
    future but for the time beeing all of them are not neccessary in the context
    of the goatee-framework.
  - Of course you can use use all of them in functions, provided by the context
  - You could provide methods to declare them, which would be somewhat arkward,
    but possible

## Objective

As “[goatee-js](https://github.com/sjorek/goatee-js)” provides attributes to
map data into markup, I decided the best way to go would be a language that is
compact, readable and (the most important feature) has a scope consisting of
a chain of contexts.  Still confused ?  Believe me, the haze will be lifted,
once the framework has reached a state where it is useable.  For the time
beeing there is a command-line interpreter to prove my concept.

Also see “[goatee-rules](https://github.com/sjorek/goatee-rules)”.

## Installation

    $ npm install -g goatee-script

## Usage

    $ goatee-script -h

    Usage: goatee-script [statements]... [options]

    statements     string passed from the command line to evaluate

    Options:
       -r STATEMENT, --run STATEMENT   string passed from the command line to evaluate
       -h, --help                      display this help message
       -i, --interactive               run an interactive `goatee-script` REPL
       -m MODE, --mode MODE            set execution-mode to [c]ompile, [e]valuate, [p]rint, [r]ender or [s]tringify given statements, default:  [eval]
       -c, --compress                  compress the abstract syntax tree (ast)  [false]
       --nodejs OPTION                 pass one option directly to the "node" binary, repeat for muliple options
       -v, --version                   display the version number and exit

    If called without options, `goatee-script` will run interactive.

## Development

    $ git clone https://github.com/sjorek/goatee-script
    $ cd goatee-script
    $ PATH=$PATH:./node_modules/.bin cake all

## Credits go to …

- … Zachary Carter and all contributors for their
  [jison parser generator](http://zaach.github.io/jison/)

- … Jeremy Ashkenas and all contributors for their
  [Coffee-Script](http://coffeescript.org/)
  as a source of inspiration

- … Kris Nye for his [Glass-Script](https://github.com/krisnye/glass-script/)
  as a source of inspiration

- … [Nodeclipse v0.4](https://github.com/Nodeclipse/nodeclipse-1)
 ([Eclipse Marketplace](http://marketplace.eclipse.org/content/nodeclipse), [site](http://www.nodeclipse.org))

