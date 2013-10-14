var fs = require('fs'),
  path = require('path'),
  logger = require('./logger.js');

module.exports = function (dir, func) {
  function filesOnly (dir) {
    function _filesOnly (dir, subpath) {
      return subpath !== 'index.js' && subpath[0] !== '_' && fs.statSync(path.resolve(dir, subpath)).isFile();
    }

    return _filesOnly.bind(undefined, dir);
  }

  function addObj (obj, dir) {
    function _ (obj, dir, file) {
      var mod;
      try {
        mod = require(path.resolve(dir, file));
      }
      catch (e) {
        logger.warn("unable to load '%s': %s", path.resolve(dir, file), e);
      }
    }

    return _.bind(undefined, obj, dir);
  }

  function obj (dir, files) {
    var o = {};
    files.forEach(addObj(o, dir));
  }

  function parseFiles(files, dir, func) {
    if (func) {
      return func(files);
    } else {
      return obj(dir, files);
    }
  }

  return parseFiles(fs.readdirSync(dir).filter(filesOnly(path)), dir, func);
};