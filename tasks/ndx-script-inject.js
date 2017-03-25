(function() {
  'use strict';
  var async, cheerio, fs, path;

  async = require('async');

  cheerio = require('cheerio');

  path = require('path');

  fs = require('fs');

  module.exports = function(grunt) {
    return grunt.registerMultiTask('ndx-script-inject', 'Inject scripts into index.html', function() {
      var done, options;
      done = this.async();
      options = this.options({
        dir: process.cwd()
      });
      return async.eachSeries(this.data.html, function(file, fileCallback) {
        var $, delayedScript, delayedScripts, filePath, html, i, len;
        filePath = path.join(options.dir, file);
        if (fs.existsSync(filePath)) {
          html = fs.readFileSync(filePath, 'utf8');
          $ = cheerio.load(html);
          $('head').append('  <!-- bower:css -->\n    <!-- endbower -->\n    ');
          $('head').append('<!-- injector:css -->\n    <!-- endinjector -->\n  ');
          if (options.sockets) {
            $('body').append('  <script src="https://cdn.socket.io/socket.io-1.4.5.js"></script>\n  ');
          }
          $('body').append('  <!-- bower:js -->\n    <!-- endbower -->\n    ');
          $('body').append('<!-- injector:js -->\n    <!-- endinjector -->\n  ');
          delayedScripts = $('script[delay="true"]');
          for (i = 0, len = delayedScripts.length; i < len; i++) {
            delayedScript = delayedScripts[i];
            $(delayedScript).remove();
            $('body').append(delayedScript);
          }
          fs.writeFile(filePath, $.html(), 'utf-8', function() {});
          return setTimeout(function() {
            grunt.task.run(['wiredep', 'injector']);
            return fileCallback();
          }, 500);
        }
      }, function() {
        return done();
      });
    });
  };

}).call(this);
