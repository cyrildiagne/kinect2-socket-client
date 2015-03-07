{JointType, BoneType, HandState, FaceProperty, ResultType, EventType} = require './definitions'
{JointVelocityTracker} = require './helpers'

###
  Joint model class
###

class Joint
  constructor : () ->
    @x = 0
    @y = 0
    @z = 0


###
  Body model class
###

class Body

  NUM_JOINTS : 25

  constructor : (@id) ->
    @leftHandState = 0
    @rightHandState = 0
    @listeners = {}
    @face = {}
    @gestures = {}
    @isTracked = false
    @joints = []
    @setupJoints()
    @velocityTracker = new JointVelocityTracker @joints

  addListener : (event, listener) ->
    if event is undefined
      throw new Error 'Body::addListener(event,listener) -> event is undefined'
    @listeners[event] = @listeners[event] || []
    @listeners[event].push listener

  removeListener : (event, listener) ->
    l = @listeners[event]
    if l
      l.splice l.indexOf(listener),1

  setupJoints : ->
    @joints = []
    for i in [0...Body::NUM_JOINTS]
      j = new Joint
      @joints.push j

  set : (data) ->

    # set left hand states
    if data.leftHandState != @leftHandState
      @notifyHandStateChange 
        handId    : JointType.LEFT_HAND
        oldState  : @leftHandState
        newState  : data.leftHandState
    @leftHandState  = data.leftHandState

    # set right hand states
    if data.rightHandState != @rightHandState
      @notifyHandStateChange 
        handId    : JointType.RIGHT_HAND
        oldState  : @rightHandState
        newState  : data.rightHandState
    @rightHandState = data.rightHandState

    # set face properties
    for k,v of data.face
      if @face[k] != v
        @notifyFacePropertyChange
          faceProperty : k
          oldState  : @face[k]
          newState  : v
      @face[k] = v

    # set gestures statuses
    for k,v of data.gestures
      @gestures[k] = v

    # set joints position
    for i in [0...data.joints.length]
      @joints[i].x =  data.joints[i].x
      @joints[i].y = -data.joints[i].y
      @joints[i].z =  data.joints[i].z

    @velocityTracker.update()

  notifyHandStateChange : (evt) ->
    evName = EventType.HAND_STATE_CHANGED
    if @listeners[evName]
      evt.body = @
      evt.type = evName
      cb evt for cb in @listeners[evName]

  notifyFacePropertyChange : (evt) ->
    evName = EventType.FACE_PROP_CHANGED
    if @listeners[evName]
      evt.body = @
      evt.type = evName
      cb evt for cb in @listeners[evName]

  toString : ->
    str = ""
    for i in [0...@data.length] by 3
      str += "#{i/3} - #{@data[i]} - #{@data[i+1]}" + '\n'
    return str

module.exports =
  Joint : Joint
  Body  : Body