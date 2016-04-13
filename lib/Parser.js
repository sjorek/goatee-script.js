
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
  var Grammar, exports, parser, ref;

  Grammar = require('./Grammar').Grammar;

  exports = (ref = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? ref : this;

  exports.parser = parser = Grammar.createParser();

  exports.Parser = parser.Parser;

  exports.parse = function() {
    return parser.parse.apply(parser, arguments);
  };

  exports.main = function(args) {
    var source;
    if (!args[1]) {
      console.log("Usage: " + args[0] + " FILE");
      process.exit(1);
    }
    source = require('fs').readFileSync(require('path').normalize(args[1]), "utf8");
    return parser.parse(source);
  };

  if (module !== void 0 && require.main === module) {
    exports.main(process.argv.slice(1));
  }

}).call(this);

//# sourceMappingURL=Parser.js.map
