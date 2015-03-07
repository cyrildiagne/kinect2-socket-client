{JointType, BoneType, HandState, FaceProperty, ResultType, EventType} = require './definitions'
{Joint, Body } = require './body'

###
  Tracker model class
###

class Tracker

  constructor : ->
    @bodies = []
    @listeners = {}
    @jointTypesTracked = []

  update : (data) ->
    
    b.isTracked = false for b in @bodies 

    if data.bodies

      for bdata in data.bodies
        body = @getBodyById bdata.id
        if !body
          body = @userIn bdata.id
        body.set bdata
        body.isTracked = true

      i = 0
      while i<@bodies.length
        b = @bodies[i]
        if !b.isTracked
          @userOut b.id
        else i++


    if @listeners['update']
      cb() for cb in @listeners['update']


  getBodyById : (id) ->
    for body in @bodies
      return body if body.id is id
    null

  trackVelocityFor : (jointType) ->
    @jointTypesTracked.push jointType
    b.velocityTracker.add jointType for b in @bodies

  userIn : (id) ->
    body = new Body id
    body.velocityTracker.add jt for jt in @jointTypesTracked
    body.addListener EventType.HAND_STATE_CHANGED, @bodyEventHandler
    body.addListener EventType.FACE_PROP_CHANGED, @bodyEventHandler
    @bodies.push body
    if @listeners[EventType.USER_IN]
      evt = 
        type : EventType.USER_IN
        body : body
      cb evt for cb in @listeners[EventType.USER_IN]
    return body

  userOut : (id) ->
    body = @getBodyById id
    @bodies.splice @bodies.indexOf(body),1
    if @listeners[EventType.USER_OUT]
      evt = 
        type : EventType.USER_OUT
        body : body
      cb evt for cb in @listeners[EventType.USER_OUT]

  addListener : (event, listener) ->
    if event is undefined
      throw new Error 'Tracker::addListener(event,listener) -> event is undefined'
    @listeners[event] = @listeners[event] || []
    @listeners[event].push listener

  removeListener : (event, listener) ->
    l = @listeners[event]
    if l
      l.splice l.indexOf(listener),1

  bodyEventHandler : (evt) =>
    if @listeners[evt.type]
      cb evt for cb in @listeners[evt.type]

  reset : ->
    for b in @bodies
      @userOut b.id 

module.exports =
  Tracker : Tracker