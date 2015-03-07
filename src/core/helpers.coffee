class JointVelocityTracker

  constructor : (@joints) ->
    @prevLeftHand  = {x:0,y:0}
    @trackedJoints = {}

  add : (ksJointType) ->
    @trackedJoints[ksJointType] = 
      type : ksJointType
      prev : {x:0, y:0}
      vel  : {x:0, y:0}
      lenghtSquared : 0

  get : (ksJointType) ->
    @trackedJoints[ksJointType].vel

  getLengthSquared : (ksJointType) ->
    @trackedJoints[ksJointType].lenghtSquared

  update : ->
    for type,tj of @trackedJoints
      kinectJoint = @joints[tj.type]
      tj.vel.x  = kinectJoint.x - tj.prev.x
      tj.vel.y  = kinectJoint.y - tj.prev.y
      tj.prev.x  = kinectJoint.x
      tj.prev.y  = kinectJoint.y
      tj.lenghtSquared = (tj.vel.x * tj.vel.x) + (tj.vel.y * tj.vel.y)

module.exports = 
  JointVelocityTracker : JointVelocityTracker