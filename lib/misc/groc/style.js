(function() {
    var Default, path,
        extend = function(child, parent) {
            for (var key in parent) {
                if (hasProp.call(parent, key)) child[key] = parent[key];
            }

            function ctor() {
                this.constructor = child;
            }
            ctor.prototype = parent.prototype;
            child.prototype = new ctor();
            child.__super__ = parent.prototype;
            return child;
        },
        hasProp = {}.hasOwnProperty,
        slice = [].slice;

    path = require('path');

    Default = require('groc').styles.Default;

    module.exports = function() {
        var Style;
        return Style = (function(superClass) {
            extend(Style, superClass);

            function Style() {
                var args;
                args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
                Style.__super__.constructor.apply(this, args);
            }

            Style.prototype.renderDocFile = function(segments, fileInfo, callback) {
                if (fileInfo.targetPath !== 'index') {
                    fileInfo.targetPath += path.extname(fileInfo.sourcePath);
                }
                this.log.trace('goatee-script/misc/groc/style#renderDocFile(...)', fileInfo.targetPath);
                return Style.__super__.renderDocFile.call(this, segments, fileInfo, callback);
            };

            return Style;

        })(Default);
    };

}).call(this);
//# sourceMappingURL=style.js.map
