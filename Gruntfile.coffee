module.exports = (grunt)->
    os   = require 'os'
    _    = require 'underscore'
    path = require 'path'

    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-electron-packager'
    grunt.loadNpmTasks 'node-srv'

    buildConfig = {}
    pkg = grunt.file.readJSON 'package.json'

    grunt.initConfig
        pkg: pkg
        settings: buildConfig

        clean:
            build: ['build']
            app: ['app']

        browserify:
            options:
                transform: ['coffeeify']
                browserifyOptions:
                    bare: true
                    extensions: ['.coffee']

            web:
                files:
                    "build/app.js": ["src/web/main.coffee"]

        coffee:
            app:
                options:
                    join: false
                    sourceMap: false
                    bare: true
                files: [
                    {
                        expand: true
                        cwd: 'src/'
                        src: ['*.coffee', 'models/**/*.coffee', 'views/**/*.coffee']
                        dest: 'app/'
                        ext: '.js'
                    },
                    {
                        expand: true
                        cwd: 'src/app/'
                        src: ['**/*.coffee']
                        dest: 'app/'
                        ext: '.js'
                    }
                ]

        jade:
            options:
                client: true
                namespace: 'AppTemplates'
                processName: (filename)->
                    filename = filename.replace("assets/templates/", '').split('/')
                    templateName = ''

                    for part in filename
                        templateName += part.slice(0,1).toUpperCase() + part.slice(1)

                    templateName = templateName.replace(/\.jade$/, '')

                    return templateName

                processContent: (content, srcpath)->
                    settings = _.omit grunt.config.data.settings.build, (value, key, object)->
                        return _.isObject(value)

                    return grunt.template.process(content, {data: settings})

            web:
                files: "build/templates.js": ["assets/templates/**/*.jade"]

            app:
                files: "app/templates.js": ["assets/templates/**/*.jade"]

        less:
            web:
                files: "build/styles.css": "assets/styles/global.less"

            app:
                files: "app/styles.css": "assets/styles/global.less"

        copy:
            web:
                files: [
                    {
                        expand: true
                        cwd: 'assets/'
                        src: ['fonts/*', 'images/**/*']
                        dest: 'build/'
                    },
                    "build/index.html": "assets/layouts/web.html"
                ]

            app:
                files: [
                    {
                        expand: true
                        cwd: 'assets/'
                        src: ['fonts/*', 'images/**/*']
                        dest: 'app/'
                    },
                    "app/index.html": "assets/layouts/app.html"
                ]

        watch:
            web:
                files: ['src/**/*.coffee']
                tasks: ['browserify:web']
                options:
                    interrupt: true

            less:
                files: ['assets/styles/**/*.less']
                tasks: ['less:web']
                options:
                    interrupt: true

            jade:
                files: ['assets/templates/**/*.jade']
                tasks: ['jade:web']
                options:
                    interrupt: true

            files:
                files: ['assets/icons/**/*', 'assets/images/**/*', 'assets/fonts/**/*']
                tasks: ['copy:web']
                options:
                    interrupt: true

        build:
            web: [
                'clean:build'
                'jade:web'
                'less:web'
                'copy:web'
                'browserify:web'
            ]
            app: [
                'clean:app'
                'jade:app'
                'less:app'
                'copy:app'
                'coffee:app'
            ]

        'electron-packager':
            macos:
                options:
                    platform:   'darwin'
                    arch:       'x64'
                    dir:        './'
                    out:        './package'
                    icon:       './assets/icons/logo.icns'
                    name:       'Ciph'
                    ignore:     ['src/', 'docs/', 'build/', 'package/']
                    version:    '1.3.1'
                    prune:      true
                    overwrite:  true
                    name:       'Ciph'
                    'app-version': pkg.version
                    'app-copyright': pkg.author

            win:
                options:
                    platform:   'win32'
                    arch:       'ia32'
                    dir:        './'
                    out:        './package'
                    icon:       './assets/icons/logo.ico'
                    name:       'Ciph'
                    ignore:     ['src/', 'docs/', 'build/', 'package/']
                    version:    '1.3.1'
                    prune:      true
                    overwrite:  true
                    name:       'Ciph'
                    'app-version': pkg.version
                    'app-copyright': pkg.author

        srv:
            build:
                port: 8181
                logs: false
                root: './build'


    grunt.registerMultiTask 'build', 'Build app', ->
        grunt.task.run @data

    grunt.registerTask 'rebuild', 'Rebuild project for dev', ->
        grunt.task.run ['build:web']

    grunt.registerTask 'dev', 'Init app for developing', ->
        grunt.task.run ['rebuild', 'watch']

    grunt.registerTask 'dev_srv', 'Init app for developing and start server', ->
        grunt.config.data.srv.build.keepalive = false
        grunt.task.run ['rebuild', 'srv:build', 'watch']
