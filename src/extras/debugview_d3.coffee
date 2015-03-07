###
  A Skeleton debug view mediator class that mediates kinect data 
###

class SkeletonViewMediator

  meterToPixels : 1000 * 0.25 # 1 mm = 0.5 pixel

  constructor : (@skeleton, @onUpdated) ->
    @jointsData = []
    @bonesData = []
    @handsData = []
    @skeleton.addUpdateListener @onSkeletonUpdate

  destructor : ->
    @skeleton.removeUpdateListener @onSkeletonUpdate

  onSkeletonUpdate : => 
    @updateJoints()
    @updateBones()
    @updateHands()
    @onUpdated @jointsData, @bonesData, @handsData

  updateJoints : ->
    for j,i in @skeleton.joints
      @jointsData[i] = @jointsData[i] || {}
      @jointsData[i].x = 0.5 * window.innerWidth  + j.x * SkeletonViewMediator::meterToPixels
      @jointsData[i].y = 0.5 * window.innerHeight - j.y * SkeletonViewMediator::meterToPixels

  updateBones : ->
    i=0
    for k,b of BonesDef.prototype
      @bonesData[i] = @bonesData[i] || {}
      @bonesData[i].j1 = @jointsData[b[0]]
      @bonesData[i].j2 = @jointsData[b[1]]
      i++

  updateHands : ->
    @handsData[0] = 
      pos    : @jointsData[ JointsDef::left_hand ]
      state  : @skeleton.leftHandState
    @handsData[1] =
      pos    : @jointsData[ JointsDef::right_hand ]
      state  : @skeleton.rightHandState


###
  A Skeleton Debug view class that draws mediated skeleton data using d3 
###

class SkeletonView

  constructor : (@container, @skeleton) ->
    @view = @container
      .append 'g' 
      .classed 'skeleton-debug '+@skeleton.id, true
    @mediator = new SkeletonViewMediator @skeleton, @onSkeletonUpdate

  remove : ->
    @mediator.destructor()
    @view.remove()

  onSkeletonUpdate : (jdata, bdata, hdata) =>
    @updateJoints jdata
    @updateBones bdata
    @updateHands hdata

  updateJoints : (jdata) ->
    joints = @view.selectAll 'circle.joint'
      .data jdata
      .attr 'r' , 3
      .attr 'cx', (d) -> d.x
      .attr 'cy', (d) -> d.y
    joints.enter()
      .append 'circle'
      .classed 'joint', true

  updateBones : (bdata) ->
    bones = @view.selectAll 'line.bone'
      .data bdata
      .attr 'x1', (d) -> d.j1.x
      .attr 'y1', (d) -> d.j1.y
      .attr 'x2', (d) -> d.j2.x
      .attr 'y2', (d) -> d.j2.y
    bones.enter()
      .append 'line'
      .classed 'bone', true

  updateHands : (hdata) ->
    hands = @view.selectAll 'circle.hand'
      .data hdata
      .attr 'data-state', (d) -> d.state
      .attr 'r', 50
      .attr 'cx', (d) -> d.pos.x
      .attr 'cy', (d) -> d.pos.y
    hands.enter()
      .append 'circle'
      .classed 'hand', true


###
  A Kinect helper/debug view class that draws kinect skeletons using d3 
###

class KinectDebugView

  constructor : (@container, @kinect) ->
    @view = @container
      .append 'g' 
      .classed 'kinect-debug', true
    @kinect.addListener 'user_in', @onUserIn
    @kinect.addListener 'user_out', @onUserOut
    @skeletons = {}

  bringToFront : ->
    @view.each -> @.parentNode.appendChild @

  setVisible : (isVisible) ->
    @view.classed 'hidden', !isVisible

  onUserIn : (skeleton) =>
    sv = new SkeletonView @view, skeleton
    @skeletons[skeleton.id] = sv

  onUserOut : (skeleton) =>
    id = skeleton.id
    @skeletons[id].remove()
    delete @skeletons[id]

