class JointView

  constructor : (@joint) ->
    @view = new paper.Path.Circle
      center : [0, 0]
      radius : 3
    @view.fillColor = new paper.Color 0,0,0


class BoneView

  constructor : (@j1v, @j2v) ->
    @view = new paper.Path.Line 
      from : @j1v.position
      to   : @j2v.position
    @view.strokeColor = new paper.Color 0,0,0
    @update()

  update : ->
    @view.segments[0].point = @j1v.view.position
    @view.segments[1].point = @j2v.view.position


class SkeletonView

  constructor : (@skeleton) ->
    @view = new paper.Layer()
    @width = 0
    @height = 0
    @joints = []
    @bones = []
    @dataRatio = 1
    @setupJoints()
    @setupBones()

  setupJoints : () ->
    @joints = []
    @jointsGrp = new paper.Group()
    for j in @skeleton.joints
      jv = new JointView j
      @jointsGrp.addChild jv.view
      @joints.push jv
    @view.addChild @jointsGrp

  setupBones : () ->
    @bones = []
    @bonesGrp = new paper.Group()
    for bone in Skeleton.bones
      b = new BoneView @joints[bone[0]], @joints[bone[1]]
      @bonesGrp.addChild b.view
      @bones.push b
    @view.insertChild 0, @bonesGrp

  resize : (vp) ->
    if vp.width > vp.height
      @height = vp.height * 0.5
      @width = @height * @dataRatio
    else
      @width = vp.width * 0.5
      @height = @width * @dataRatio
    @update 1

  update : (speed=0.5) ->
    scale = @width
    for jnt in @joints
      jnt.view.position.x += ( jnt.joint.x * scale - jnt.view.position.x) * speed
      jnt.view.position.y += (-jnt.joint.y * scale - jnt.view.position.y) * speed
    bone.update() for bone in @bones


class PaperView

  constructor : (@skeleton) ->
    @canvas = document.createElement('canvas')
    @canvas.setAttribute 'data-paper-hidpi', ''
    @canvas.setAttribute 'data-paper-resize', ''
    document.body.appendChild @canvas

    paper.setup @canvas
    paper.view.onFrame = @onFrame

    @view = new paper.Layer()
    @view.transformContent = false

    @skeleton_view = new SkeletonView @skeleton
    @view.addChild @skeleton_view.view

    window.addEventListener 'resize', @windowResized
    @windowResized()

  onFrame : =>
    @skeleton_view.update()

  windowResized : (ev) =>
    viewport = 
      width  : paper.view.viewSize.width
      height : paper.view.viewSize.height
    
    @skeleton_view.resize viewport

    @view.position.x = viewport.width * 0.5
    @view.position.y = viewport.height * 0.5