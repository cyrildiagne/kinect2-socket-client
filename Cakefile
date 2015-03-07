fs    = require 'fs-extra'
path  = require 'path'
which = require 'which'
{spawn, exec} = require 'child_process'

green = '\x1B[0;32m'
reset = '\x1B[0m'

lib_name  = 'kinect2-socket.js'
apps_path = path.join 'node_modules','.bin'

build_path  = path.join 'build'
bin_path    = path.join 'bin'

# ---

launch = (cmd, options) ->
  cmd = path.join apps_path, cmd
  prcss = spawn cmd, options
  prcss.stdout.pipe process.stdout
  prcss.stderr.pipe process.stderr

run = (cmd, options, callback) ->
  cmd = path.join apps_path, cmd
  opts = ' ' + options.join ' '
  prcss = exec cmd + opts, (error) -> 
    if error then console.log error
    else callback() if callback

log_done = -> 
  console.log green + 'done.' + reset

# ---

compile = (callback) ->
  console.log 'compiling..'
  run 'coffee', ['-c', '-b', '-o', build_path, 'src'], ->
    log_done()
    callback() if callback

link = (callback) ->
  console.log 'linking..'
  fs.ensureDirSync bin_path
  inp = path.join build_path, lib_name
  out = path.join bin_path, lib_name
  run 'browserify', ['-e', inp, '-o', out], ->
    log_done()
    callback() if callback
      
minify = (callback) ->
  console.log 'minifying..'
  min_name = lib_name.split('.').join '.min.'
  input = path.join bin_path, lib_name
  target = path.join bin_path, min_name
  run 'uglifyjs', ['-o', target, input], ->
    log_done()
    callback() if callback

# ---

task 'dev', 'start dev env', ->
  launch 'coffee', ['-w', '-c', '-b', '-o', build_path, 'src']

task 'clean', 'clean builds', ->
  fs.removeSync build_path
  fs.removeSync bin_path

task 'build', 'build lib', -> 
  compile -> link()

task 'export', 'build & export minified lib', -> 
  compile -> link -> minify()

task 'test', 'run tests', ->
  launch 'mocha', ['--compilers', 'coffee:coffee-script/register']
