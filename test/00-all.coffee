fs     = require 'fs'
should = require 'should'
path   = require 'path'
ks     = require '../src/kinect2-socket'
zlib   = require 'zlib'


describe 'Properties', ->

  it 'should define joints types', ->
    ks.JointType.should.be.ok
    ks.JointType.SPINE_SHOULDER
      .should.equal 20

  it 'should define bones types', ->
    ks.BoneType.should.be.ok
    ks.BoneType.LEFT_SHOULDER
      .should.have.property 0, ks.JointType.SPINE_SHOULDER

  it 'should define hand states', ->
    ks.HandState.should.be.ok
    ks.HandState.LASSO.should.be.ok

  it 'should define face properties', ->
    ks.FaceProperty.should.be.ok
    ks.FaceProperty.HAPPY.should.be.ok

  it 'should define results types', ->
    ks.ResultType.should.be.ok
    ks.ResultType.MAYBE.should.be.ok

  it 'should define event types', ->
    ks.EventType.should.be.ok
    ks.EventType.FACE_PROP_CHANGED.should.be.ok
    ks.EventType.HAND_STATE_CHANGED.should.be.ok


describe 'Tracker & Playback', ->

  json1_path = path.join __dirname, '..', 'extras/data/test_record.json'
  json1 = fs.readFileSync json1_path, 'utf8'

  json_path = path.join __dirname, '..', 'extras/data/dance_simple.json.gz'
  json = fs.readFileSync json_path

  tracker = new ks.Tracker
  playback = null
  frame = 0

  it 'should be able to load a v0.1 playback json', ->
    playback1 = new ks.Playback tracker, false
    playback1.loadJSON json1
    playback1.frames.length.should.not.equal(0)

  it 'should be able to load a compressed v0.3 playback json', (done) ->
    playback = new ks.Playback tracker, false
    zlib.gunzip json, (err, data) ->
      json = data.toString('utf8')
      playback.loadJSON json
      playback.frames.length.should.not.equal(0)
      done()
    

  it 'should provide new users', ->
    playback.update() for i in [0...5]
    tracker.bodies.length.should.equal(1)
    playback.reset()

  it 'should trigger hand state events', (done) ->
    evName = ks.EventType.HAND_STATE_CHANGED
    tracker.addListener evName, (evt) ->
      hs = [ks.HandState.UNKNOWN, ks.HandState.NOTTRACKED, ks.HandState.OPEN, ks.HandState.CLOSED, ks.HandState.LASSO]
      hs.should.containEql evt.oldState
      hs.should.containEql evt.newState
      tracker.removeListener evName
      tracker.listeners[evName].should.be.empty
      done()
    playback.update() for i in [0...20]

  it 'should trigger face properties events', (done) ->
    evName = ks.EventType.FACE_PROP_CHANGED
    tracker.addListener evName, (evt) ->
      tracker.removeListener evName
      tracker.listeners[evName].should.be.empty
      done()
    playback.update() for i in [0...50]

  it 'should provide face activity', ->
    while playback.currFrame < playback.frames.length-1
      playback.update() 
      body = tracker.bodies[0]
      if body
        for k,v of body.face
          if v != 'no'
            found = true
    found.should.be.ok