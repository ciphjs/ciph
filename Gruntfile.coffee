module.exports = (grunt)->
    _    = require 'underscore'
    path = require 'path'

    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-browserify'
    grunt.loadNpmTasks 'node-srv'

    buildConfig = {}

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
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

        jade:
            templates:
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

                files:
                    "build/templates.js": ["assets/templates/**/*.jade"]

        less:
            web:
                files: "build/styles.css": "assets/styles/global.less"

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
                tasks: ['jade:templates']
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
                'jade:templates'
                'less:web'
                'copy:web'
                'browserify:web'
            ]

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
