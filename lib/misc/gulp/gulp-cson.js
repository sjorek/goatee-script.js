(function() {
  var coffee, cson, map, rext,
    hasProp = {}.hasOwnProperty;

  map = require('map-stream');

  coffee = require('coffee-script');

  rext = require('replace-ext');

  cson = require('cson');

  module.exports = function(options) {
    var format2ext, gcson, swap;
    format2ext = function(format) {
      switch (format) {
        case 'coffeescript':
          return '.cs';
        case 'javascript':
          return '.js';
        default:
          return "." + format;
      }
    };
    swap = function(format) {
      switch (format) {
        case 'json':
          return 'cson';
        case 'cson':
          return 'json';
        case 'coffeescript':
          return 'javascript';
        case 'javascript':
          return 'coffeescript';
      }
    };
    gcson = function(file, cb) {
      var data, key, opts, value;
      opts = {};
      if (options != null) {
        for (key in options) {
          if (!hasProp.call(options, key)) continue;
          value = options[key];
          opts[key] = value;
        }
      }
      opts.filename = file.path;
      if (!((opts.filename != null) || (opts.format != null))) {
        opts.format = 'cson';
      }
      data = cson.parseString(file.contents.toString(), opts);
      if (data instanceof Error) {
        return cb(data);
      }
      opts.format = swap(opts.format);
      if (opts.filename != null) {
        opts.filename = rext(opts.filename, format2ext(opts.format));
      }
      data = cson.createString(data, opts);
      if (data instanceof Error) {
        return cb(data);
      }
      file.contents = new Buffer(data);
      file.path = opts.filename;
      return cb(null, file);
    };
    return map(gcson);
  };

}).call(this);

//# sourceMappingURL=gulp-cson.js.map
