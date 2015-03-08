###
  A proxy class that synchronizes a Kinect model to a websocket stream
###

if typeof navigator != 'undefined'
  saveAs = require '../../extras/FileSaver'

Zlib = require '../../extras/zlib-browserify/index'

class SocketStream
  
  constructor : (@tracker) ->
    @socket = null
    @record = null
    @isConnected = false
    @isRecording = false

  connect : (@endpoint) ->
    @socket = new WebSocket @endpoint
    @socket.onopen = @onSocketOpened
    @socket.onclose = @onSocketClosed
    @socket.onmessage = @onSocketMessage
    @socket.onerror = @onSocketError

  stop : ->
    @stopRecord() if @isRecording
    @socket.close()
    @socket.onopen = @socket.onclose = @socket.onmessage = null

  startRecord : ->
    @record = []
    @isRecording = true
    console.log 'recording started'

  stopRecord : (filename, bCompress=true) ->
    filename += ".json"
    if @isRecording
      output = JSON.stringify
        version : '0.3'
        frames : @record
      if filename
        opts = {type:'text/plain;charset=utf-8'}
        if bCompress
          Zlib.gzip output, (err, result) ->
            if err
              console.log err
              return
            saveAs new Blob([result], opts), filename + '.gz'
        else
          blob = new Blob [output], opts
          saveAs blob, filename
    @record = null
    @isRecording = false
    console.log 'recording stopped'

  toggleRecord : (filename = "default") ->
    if @isRecording
      @stopRecord filename
    else @startRecord()

  # record

  onSocketError : (err) =>
    console.log "websocket error"

  onSocketOpened : () =>
    console.log "websocket connected"    
    @isConnected = true

  onSocketClosed : () =>
    console.log "websocket disconnected"
    @socket.onopen = @socket.onclose = @socket.onmessage = null
    @socket = null
    @isConnected = false
    setTimeout =>
      @connect @endpoint
      console.log 'reconnecting in 1s...'
    ,1000

  onSocketMessage : (msg) =>
    data = JSON.parse msg.data
    if @record 
      @record.push data
    @tracker.update data

module.exports =
  SocketStream : SocketStream