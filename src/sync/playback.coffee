{JointType, BoneType, HandState, FaceProperty, ResultType} = require '../core/definitions'

###
  A proxy class that synchronize a Kinect model to a playback file 
###

Zlib = require '../../extras/zlib-browserify/index'

class Playback

  constructor : (@tracker, @bLoop = true) ->
    @interval = -1
    @currFrame = 0
    @isPlaying = false
    @status    = 'no file loaded'
    @framerate = 30

    @filename = null
    @frames   = null
    @version  = null

  loadJSON : (json) ->
    @tracker.reset()
    data = JSON.parse json
    @frames = data.frames
    @version = data.version
    switch @version
      when '0.1' then @upgradeFrom_v01()

  load : (url, callback) ->
    
    @status = 'loading'

    r = new XMLHttpRequest()
    
    filename = url.substr(url.lastIndexOf('/')+1)
    extension = filename.substr(filename.lastIndexOf('.')+1)

    process = (data) =>
      @filename = filename
      @loadJSON data
      @status = 'loaded'
      callback() if callback

    getText = (data, callback) ->
      bb = new Blob([data])
      f = new FileReader()
      f.onload = (e) -> callback e.target.result
      f.readAsText bb

    r.onreadystatechange = -> 
      if r.readyState is 4 and r.status is 200
        type = r.getResponseHeader 'Content-Type'
        if extension is 'gz'
          if type is 'application/json'
            getText r.response, process
          else
            data = new Uint8Array(r.response)
            plain = new Zlib.gunzip data, (err, result) ->
              getText result, process
        else if extension is 'json'
          process r.responseText
        else
          console.log 'unknown file extension (json/gz only)'

    r.open 'GET', url
    r.responseType = "arraybuffer" if extension is 'gz'
    r.send()

  play : (file, @framerate=30) ->
    @stop() if @isPlaying
    if file
      @load file, => @play null, framerate
      return
    @isPlaying = true
    @status = 'playing'
    @interval = setInterval =>
      @update()
    , 1000/@framerate

  stop : ->
    clearInterval @interval
    @interval = -1
    @isPlaying = false
    @status = 'stopped'

  togglePlay : ->
    if @isPlaying
      @stop()
    else @play()

  reset : ->
    @currFrame = 0

  update : ->
    return if !@frames
    frame = @frames[@currFrame]
    @tracker.update frame
    if @currFrame is @frames.length-1
      if @bLoop then @reset()
      else @stop()
    else @currFrame++

  # support legacy files v0.1
  upgradeFrom_v01 : ->
    statesArr = [HandState.UNKNOWN, HandState.NOTTRACKED, HandState.OPEN, HandState.CLOSED, HandState.LASSO]
    for frame in @frames
      for b in frame.bodies
        b.leftHandState  = statesArr[b.leftHandState]
        b.rightHandState = statesArr[b.rightHandState]

module.exports =
  Playback : Playback