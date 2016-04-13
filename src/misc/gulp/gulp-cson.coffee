map = require 'map-stream'
coffee = require 'coffee-script'
rext = require 'replace-ext'
cson = require 'cson'

module.exports = (options) ->

  format2ext = (format) ->
    return switch format
      when 'coffeescript' then '.cs'
      when 'javascript' then '.js'
      else ".#{format}"

  swap = (format) ->
    return switch format
      when 'json' then 'cson'
      when 'cson' then 'json'
      when 'coffeescript' then 'javascript'
      when 'javascript' then 'coffeescript'

  gcson = (file, cb) ->

    opts = {}
    opts[key] = value for own key, value of options if options?


    opts.filename = file.path
    opts.format = 'cson' unless opts.filename? or opts.format?

    data = cson.parseString(file.contents.toString(), opts)
    return cb data if data instanceof Error

    opts.format = swap(opts.format)
    opts.filename = rext opts.filename, format2ext(opts.format) if opts.filename?

    data = cson.createString data, opts
    return cb data if data instanceof Error

    file.contents = new Buffer data
    file.path = opts.filename

    cb null, file

  return map gcson
