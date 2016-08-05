module.exports = (grunt)->
    os   = require 'os'
    _    = require 'underscore'
    path = require 'path'
    jade = require 'jade'

    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-electron'
    grunt.loadNpmTasks 'grunt-release'
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
                transform: ['coffeeify', 'jadeify']
                browserifyOptions:
                    bare: true
                    extensions: ['.coffee', '.jade', '.js']

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
            app:
                files: [
                    {
                        expand: true
                        cwd: 'src/templates'
                        src: ['**/*.jade']
                        dest: 'app/templates/'
                        ext: '.js'
                    }
                ]

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
                files: ['src/templates/**/*.jade']
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

        electron:
            macos:
                options:
                    platform:   'darwin'
                    arch:       'x64'
                    dir:        './'
                    out:        './package'
                    icon:       './assets/icons/logo.icns'
                    name:       'Ciph'
                    ignore:     ['src/', 'docs/', 'build/', 'package/']
                    version:    '1.3.2'
                    prune:      true
                    overwrite:  true
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
                    version:    '1.3.2'
                    prune:      true
                    overwrite:  true
                    'app-version': pkg.version
                    'app-copyright': pkg.author

        srv:
            build:
                port: 8181
                logs: false
                root: './build'

        release:
            options:
                tagName: 'v<%= version %>'
                commitMessage: 'New version v<%= version %>'
                npm: false
                npmtag: false
                push: true
                pushTags: true
                github:
                    repo: 'ciphjs/ciph'
                    accessTokenVar: 'GH_TOKEN_REPO'


    grunt.registerMultiTask 'build', 'Build app', ->
        grunt.task.run @data

    grunt.registerTask 'rebuild', 'Rebuild project for dev', ->
        grunt.task.run ['build:web']

    grunt.registerTask 'dev', 'Init app for developing', ->
        grunt.task.run ['rebuild', 'watch']

    grunt.registerTask 'dev_srv', 'Init app for developing and start server', ->
        grunt.config.data.srv.build.keepalive = false
        grunt.task.run ['rebuild', 'srv:build', 'watch']

    grunt.registerTask 'pack', 'Pack desktop app', (platform)->
        if platform
            grunt.task.run ['build:app', "electron:#{platform}"]

        else
            grunt.task.run ['build:app', "electron"]

    grunt.registerMultiTask 'jade', 'Compile jade to nodejs files', ->
        separator = grunt.util.linefeed + grunt.util.linefeed

        @files.forEach (file)->
            tmpl = jade.compileFileClient file.src[0]

            output = []
            output.push "var jade = jade || require('jade').runtime;"
            output.push "var tmpl = #{tmpl};"
            output.push "if (typeof exports === 'object' && exports) {module.exports = tmpl;}"

            grunt.file.write file.dest, output.join grunt.util.normalizelf separator
            grunt.verbose.writeln 'File ' + file.dest + ' created.'

        grunt.log.ok @files.length + ' ' + grunt.util.pluralize(@files.length, 'file/files') + ' created.'
