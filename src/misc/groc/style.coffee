
path = require 'path'
{Default} = require('groc').styles

module.exports = -> class Style extends Default
  constructor: (args...) ->
    super(args...)

  renderDocFile: (segments, fileInfo, callback) ->
    unless fileInfo.targetPath is 'index'
      fileInfo.targetPath += path.extname(fileInfo.sourcePath)
    @log.trace 'goatee-script/misc/groc/style#renderDocFile(...)', fileInfo.targetPath
    super(segments, fileInfo, callback)
