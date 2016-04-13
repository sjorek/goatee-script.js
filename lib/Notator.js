
/*
© Copyright 2013-2016 Stephan Jorek <stephan.jorek@gmail.com>
© Copyright 2009-2013 Jeremy Ashkenas <https://github.com/jashkenas>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

(function() {
  var Notator, exports, ref;

  exports = (ref = typeof module !== "undefined" && module !== null ? module.exports : void 0) != null ? ref : this;

  exports.Notator = Notator = (function() {
    var unwrap, wrap;

    function Notator() {}

    Notator.unwrap = unwrap = /^function\s*\(\)\s*\{\s*return\s*([\s\S]*);\s*\}/;

    Notator.wrap = wrap = function(action) {
      return "(" + action + ".call(this))";
    };

    Notator.operation = Notator.o = function(pattern, action, options) {
      var match;
      if (!action) {
        return [pattern, '$$ = $1;', options];
      }
      action = (match = unwrap.exec(action)) ? match[1] : wrap(action);
      return [pattern, "$$ = " + action + ";", options];
    };

    Notator.resolve = Notator.r = function(pattern, action) {
      var match;
      if (pattern.source != null) {
        pattern = pattern.source;
      }
      if (!action) {
        return [pattern, 'return;'];
      }
      action = (match = unwrap.exec(action)) ? match[1] : wrap(action);
      return [pattern, "return " + action + ";"];
    };

    Notator.conditional = Notator.c = function(conditions, pattern, action) {
      return [conditions].concat(Notator.resolve(pattern, action));
    };

    return Notator;

  })();

}).call(this);

//# sourceMappingURL=Notator.js.map
