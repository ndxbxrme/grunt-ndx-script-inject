'use strict'
async = require 'async'
cheerio = require 'cheerio'
path = require 'path'
fs = require 'fs'

module.exports = (grunt) ->
  grunt.registerMultiTask 'ndx-script-inject', 'Inject scripts into index.html', ->
    done = @async()
    options = @options
      dir: process.cwd()
    async.eachSeries @data.html, (file, fileCallback) ->
      filePath = path.join(options.dir, file)
      if fs.existsSync filePath
        html = fs.readFileSync filePath, 'utf8'
        $ = cheerio.load html
        $('head').append('  <!-- bower:css -->\n    <!-- endbower -->\n    ');
        $('head').append('<!-- injector:css -->\n    <!-- endinjector -->\n  ');
        if options.sockets
          $('body').append('  <script src="https://cdn.socket.io/socket.io-1.4.5.js"></script>\n  ');
        if options.bower
          if options.bower.dependencies['ndx-socket']
            $('body').append('  <script src="https://cdn.socket.io/socket.io-1.4.5.js"></script>\n  ');
        if options.pkg
          if options.pkg.dependencies['ndx-brand']
            $('head').append('  <link rel="stylesheet" href="brand.css">\n  ');
            $('body').append('  <script src="brand.js"></script>\n  ');
        $('body').append('  <!-- bower:js -->\n    <!-- endbower -->\n    ');
        $('body').append('<!-- injector:js -->\n    <!-- endinjector -->\n  ');
        delayedScripts = $('script[delay="true"]')
        for delayedScript in delayedScripts
          $(delayedScript).remove()
          $('body').append delayedScript
        fs.writeFile filePath, $.html(), 'utf-8', ->
        setTimeout ->
          grunt.task.run ['wiredep', 'injector']
          fileCallback()
        , 500
    , ->
      done()