{Playback} = require '../sync/playback'
{Stream}   = require '../sync/socket_stream'

class DebugView

  constructor : (@tracker) ->
    @canvas = document.createElement 'canvas'
    @canvas.id = 'kinect-debug-view'
    @canvas.width = 380
    @canvas.height = 265
    @addControls() if document
      
    @proxy = null
    @ctx = @canvas.getContext '2d'

    @color = '#fff'
    @colorHighlight = '#0ff'
    @colorError = 'red'
    @colorInactive = '#404050'
    @colorLoading = '#009090'
    @colorActive = '#90ffff'
    @colorBgHighlight = 'rgba(0,255,255,0.2)'
    @colorBgHighlightDark = '#19192c'

    @faceColors = {}
    @faceColors[ks.ResultType.UNKNOWN] = @colorError
    @faceColors[ks.ResultType.NO]      = @colorInactive
    @faceColors[ks.ResultType.MAYBE]   = @colorLoading
    @faceColors[ks.ResultType.YES]     = @colorActive

    @gestures = {}
    @gHistoryLength = 40
    @gesturesGraphWidth = 110
    @gesturesGraphHeight = 80
    @lineHeight = 11

    @margin = 8
    @scale = 1000 * 0.1
    @jointRadius = 2

  render : ->

    c = @ctx
    c.clearRect 0, 0, @canvas.width, @canvas.height

    c.fillStyle = 'rgba(0,0,40,0.8)'
    c.fillRect 0, 0, @canvas.width, @canvas.height
    
    x = @margin
    for b in @tracker.bodies
      if !b.isTracked then continue
      @renderSkeleton b
      # draw face properties
      y = 0
      c.font = '8px sans-serif'
      c.fillStyle = @color
      c.fillText 'FACE OF ...'+(''+b.id).slice(-4)+' :', x, (y+=@lineHeight)
      for k,v of b.face
        c.fillStyle = @faceColors[v]
        c.fillText k.toUpperCase(), x, (y+=@lineHeight)
      x += 90
      if Object.getOwnPropertyNames(b.gestures).length isnt 0
        @renderGestures b, @canvas.width-@gesturesGraphWidth-@margin, @lineHeight

    if @proxy
      if @proxy instanceof Playback
        @renderTimeline()
      else
        @renderSocketInfo()
    return

  addControls : ->

    window.addEventListener 'mouseup', (ev) =>
      window.removeEventListener 'mousemove', @timelineDragged

    @canvas.addEventListener 'mousedown', (ev) =>
      if @proxy instanceof Playback
        if ev.offsetY > @canvas.height - 40
          window.addEventListener 'mousemove', @timelineDragged
          @timelineDragged ev
        else 
          @proxy.togglePlay()
      else
        filename = null
        if @proxy.isRecording
          filename = prompt "Playback file name :", ""
        @proxy.toggleRecord filename


  timelineDragged : (e) =>

    x = Math.min(Math.max(0, e.offsetX), @canvas.width)
    @proxy.currFrame = Math.floor(x / @canvas.width * (@proxy.frames.length-1))
    @proxy.update()
      

  renderSkeleton : (body) ->

    c = @ctx
    c.save()
    c.translate @canvas.width*0.5, @canvas.height*0.5

    # draw bones
    c.lineWidth = 2
    c.strokeStyle = @color
    c.beginPath()
    for k,bone of ks.BoneType
      j1 = body.joints[bone[0]]
      j2 = body.joints[bone[1]]
      c.moveTo j1.x * @scale, j1.y * @scale
      c.lineTo j2.x * @scale, j2.y * @scale
    c.stroke()

    # draw joints
    c.fillStyle = @colorHighlight
    c.beginPath()
    for j in body.joints
      c.moveTo j.x * @scale, j.y * @scale
      c.arc    j.x * @scale, j.y * @scale, @jointRadius, 0, 2*Math.PI
    c.fill()

    # draw hand states
    c.strokeStyle = @colorHighlight
    c.fillStyle = 'rgba(0,255,255,0.6)'
    c.lineWidth = 1
    hands = [ks.JointType.LEFT_HAND, ks.JointType.RIGHT_HAND]
    for state,i in [body.leftHandState, body.rightHandState]
      
      continue if state in [ks.HandState.UNKNOWN, ks.HandState.NOTTRACKED]
      radius = 10
      if state is ks.HandState.OPEN
        radius = 20

      c.beginPath()
      j = body.joints[ hands[i] ]
      x = j.x * @scale
      y = j.y * @scale
      c.moveTo x, y
      c.arc    x, y, radius, 0, 2*Math.PI
      c.stroke()
      c.fill() if state is ks.HandState.CLOSED

      if state is ks.HandState.LASSO
        c.fillStyle = '#ff0'
        c.fillText state.toUpperCase(), x+5, y

    # draw user id
    c.fillStyle = @color
    j = body.joints[ks.JointType.HEAD]
    c.fillText 'USER ...'+(''+body.id).slice(-4), j.x * @scale + 5, j.y * @scale

    c.restore()

  renderGestures : (b, x, y) ->
    c = @ctx

    c.fillStyle = @color
    c.fillText 'GESTURES OF ...'+(''+b.id).slice(-4), x, y

    c.save()
    c.translate x, y+@lineHeight*0.5
    
    # draw graph bg
    y = 0
    w = @gesturesGraphWidth
    h = @gesturesGraphHeight
    c.fillStyle = @colorBgHighlightDark
    c.fillRect 0, 0, w, h
    # draw labels
    for k,v of b.gestures
      g = @gestures[k]
      if !g
        g = @gestures[k] = 
          color : '#' + Math.floor(Math.random()*16000000).toString(16)
          history : []
      c.fillStyle = g.color
      k = k.toUpperCase()
      if v.type == ks.GestureType.CONTINUOUS
        g.history.push v.progress
        c.fillText k+' (CONT.)', 4, (y+=@lineHeight)
      else if v.type == ks.GestureType.DISCRETE
        g.history.push v.confidence
        c.fillText k+' (DISC.)', 4, (y+=@lineHeight)
      g.history.shift() if g.history.length > @gHistoryLength
      # draw graph
      c.beginPath()
      c.strokeStyle = g.color
      x = 0
      l = w / @gHistoryLength
      c.moveTo x, (1-g.history[0])*h
      for val in g.history
        c.lineTo x+=l, (1-val)*h
      c.stroke()
    c.restore()

  renderTimeline : (h = 40)->
    p = @proxy
    return if !p.frames || !p.frames.length

    pos = p.currFrame / p.frames.length * @canvas.width
    c = @ctx
    ch = @canvas.height
    cw = @canvas.width

    action = @proxy.status.toUpperCase()

    c.fillStyle = @color
    c.font = '8px sans-serif'
    c.fillText 'PLAYBACK :  '+action, 5, ch-h-18
    c.fillStyle = @colorHighlight
    c.font = '9px sans-serif'
    c.fillText p.filename + ' - type : v'+p.version, 5, ch-h-6

    c.fillStyle = @colorBgHighlight
    c.beginPath()
    c.fillRect(0, ch-h, cw, h)
    c.fill()

    c.lineWidth = 2
    c.strokeStyle = @colorHighlight
    c.beginPath()
    c.moveTo pos, ch-h
    c.lineTo pos, ch
    c.stroke()

  renderSocketInfo : (h = 30)->
    c = @ctx
    ch = @canvas.height
    cw = @canvas.width

    c.save()
    action = if @proxy.isRecording then 'RECORDING' else ''

    if @proxy.isRecording
      c.fillStyle = 'red'
    else
      c.fillStyle = @color
    c.font = '8px sans-serif'
    c.fillText 'STREAM :  '+action, 5, ch-h-18
    c.fillStyle = @colorActive
    if !@proxy.isConnected
      c.fillStyle = @colorInactive
    c.font = '9px sans-serif'
    c.fillText @proxy.endpoint.toUpperCase(), 5, ch-h-6

    c.restore()

module.exports = 
  DebugView : DebugView