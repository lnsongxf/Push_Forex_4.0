module.exports = function(grunt) {

  grunt.initConfig({
    copy: {
      main: {
        files: [
          // includes files within path
          {expand: true, src: ['bower_components/**'], dest: 'public/libs/'}
        ],
      },
    }
  });
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask('default', ['copy']);

};