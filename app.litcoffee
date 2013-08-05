    express = require 'express'
    http = require 'http'
    app = express()
    CoffeeScript = require 'coffee-script'
    teacup = require 'teacup'
    everyauth = require('everyauth')

    config =
      ghClientId: '3ce057dbdc810161435f'
      ghSecret: 'ef380838d7baa029b4cf5d34dc20de9f02c19ba8'

    connectConfig =
      src: 'app/public'
      jsDir: 'js'
      cssDir: 'css'
      jsCompilers: 
        litcoffee: 
          match: /\.js$/
          compileSync: (sourcePath, source) ->
            console.log "Compiling " + sourcePath
            CoffeeScript.compile source, filename: sourcePath, literate: true

    global.cdn_js = (url) ->
      teacup.js("#{js_libs_path}/#{url}")

    global.cdn_css = (url) ->
      teacup.css("#{css_libs_path}/#{url}")

    everyauth.github
      .appId(config.ghClientId)
      .appSecret(config.ghSecret)
      .findOrCreateUser((session, accessToken, accessTokenExtra, githubUserMetadata) ->
        session.oauth = accessToken
        session.uid = githubUserMetadata.login)
      .redirectPath '/'

    everyauth.everymodule.handleLogout (req, res) ->
      req.logout()
      req.session.uid = null
      res.writeHead 303, { 'Location': this.logoutRedirectPath() }
      res.end()

    app.configure ->
      app.set 'port', 33333
      app.set 'views', __dirname + '/views'
      app.locals.pretty = true
      app.use express.bodyParser()
      app.use express.cookieParser()
      app.use express.session secret: 'super-duper-secret-secret'
      app.use express.methodOverride()
      app.engine "coffee", require('teacup/lib/express').renderFile
      app.use require('teacup/lib/connect-assets') connectConfig
      app.set 'view engine', 'coffee'
      app.use require('stylus').middleware src: __dirname + '/assets'
      app.use express.static __dirname + '/assets'
      app.use everyauth.middleware()
    
    app.configure 'production', ->
      global.js_libs_path = '//cdnjs.cloudflare.com/ajax/libs/'
      global.css_libs_path = '//cdnjs.cloudflare.com/ajax/libs/'

    app.configure 'development', ->
      global.js_libs_path = 'cdn'
      global.css_libs_path = 'cdn'
      app.use express.errorHandler()
    
    require('./server/router') app

    http.createServer(app).listen app.get('port'), ->
      console.log "HasGithub server listening on port " + app.get 'port'

    
