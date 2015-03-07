###
  Joints types
###
JointType =

  SPINE_BASE     : 0
  SPINE_MID      : 1
  NECK           : 2
  HEAD           : 3
  LEFT_SHOULDER  : 4
  LEFT_ELBOW     : 5
  LEFT_WRIST     : 6
  LEFT_HAND      : 7
  RIGHT_SHOULDER : 8
  RIGHT_ELBOW    : 9
  RIGHT_WRIST    : 10
  RIGHT_HAND     : 11
  LEFT_HIP       : 12
  LEFT_KNEE      : 13
  LEFT_ANKLE     : 14
  LEFT_FOOT      : 15
  RIGHT_HIP      : 16
  RIGHT_KNEE     : 17
  RIGHT_ANKLE    : 18
  RIGHT_FOOT     : 19
  SPINE_SHOULDER : 20
  LEFT_HAND_TIP  : 21
  LEFT_THUMB     : 22
  RIGHT_HAND_TIP : 23
  RIGHT_THUMB    : 24


###
  Bones types
###
BoneType =

  HEAD            : [ JointType.HEAD,            JointType.NECK ]
  NECK            : [ JointType.NECK,            JointType.SPINE_SHOULDER ]

  TORSO           : [ JointType.SPINE_SHOULDER,  JointType.SPINE_MID ]
  STOMACH         : [ JointType.SPINE_MID,       JointType.SPINE_BASE ]

  RIGHT_SHOULDER  : [ JointType.SPINE_SHOULDER,  JointType.RIGHT_SHOULDER ]
  RIGHT_UPPER_ARM : [ JointType.RIGHT_SHOULDER,  JointType.RIGHT_ELBOW ]
  RIGHT_LOWER_ARM : [ JointType.RIGHT_ELBOW,     JointType.RIGHT_WRIST ]
  RIGHT_PALM      : [ JointType.RIGHT_WRIST,     JointType.RIGHT_HAND ]
  RIGHT_FINGERS   : [ JointType.RIGHT_HAND,      JointType.RIGHT_HAND_TIP ]
  RIGHT_THUMB     : [ JointType.RIGHT_WRIST,     JointType.RIGHT_THUMB ]

  LEFT_SHOULDER   : [ JointType.SPINE_SHOULDER,  JointType.LEFT_SHOULDER ]
  LEFT_UPPER_ARM  : [ JointType.LEFT_SHOULDER,   JointType.LEFT_ELBOW ]
  LEFT_LOWER_ARM  : [ JointType.LEFT_ELBOW,      JointType.LEFT_WRIST ]
  LEFT_PALM       : [ JointType.LEFT_WRIST,      JointType.LEFT_HAND ]
  LEFT_FINGERS    : [ JointType.LEFT_HAND,       JointType.LEFT_HAND_TIP ]
  LEFT_THUMB      : [ JointType.LEFT_WRIST,      JointType.LEFT_THUMB ]

  RIGHT_HIP       : [ JointType.SPINE_BASE,      JointType.RIGHT_HIP ]
  RIGHT_UPPER_LEG : [ JointType.RIGHT_HIP,       JointType.RIGHT_KNEE ]
  RIGHT_LOWER_LEG : [ JointType.RIGHT_KNEE,      JointType.RIGHT_ANKLE ]
  RIGHT_FOOT      : [ JointType.RIGHT_ANKLE,     JointType.RIGHT_FOOT ]

  LEFT_HIP        : [ JointType.SPINE_BASE,      JointType.LEFT_HIP ]
  LEFT_UPPER_LEG  : [ JointType.LEFT_HIP,        JointType.LEFT_KNEE ]
  LEFT_LOWER_LEG  : [ JointType.LEFT_KNEE,       JointType.LEFT_ANKLE ]
  LEFT_FOOT       : [ JointType.LEFT_ANKLE,      JointType.LEFT_FOOT ]


###
  Hand states
###
HandState =

  UNKNOWN    : 'unknown'
  NOTTRACKED : 'nottracked'
  OPEN       : 'open'
  CLOSED     : 'closed'
  LASSO      : 'lasso'


###
  Face properties
###
FaceProperty =

  HAPPY            : 'happy'
  ENGAGED          : 'engaged'
  WEARING_GLASSES  : 'wearing_glasses'
  LEFT_EYE_CLOSED  : 'left_eye_closed'
  RIGHT_EYE_CLOSED : 'right_eye_closed'
  MOUTH_OPEN       : 'mouth_open'
  MOUTH_MOVED      : 'mouth_moved'
  LOOKING_AWAY     : 'looking_away'


###
  Results
###
ResultType =

  UNKNOWN : 'unknown'
  NO      : 'no'
  MAYBE   : 'maybe'
  YES     : 'yes'


###
  Events
###
EventType =

  USER_IN            : 'user_in'
  USER_OUT           : 'user_out'
  FACE_PROP_CHANGED  : 'face_prop_changed'
  HAND_STATE_CHANGED : 'hand_state_changed'


###
  Gestures
###
GestureType =

  CONTINUOUS         : 'continuous'
  DISCRETE           : 'discrete'


# export
module.exports =

  JointType    : JointType
  BoneType     : BoneType
  HandState    : HandState
  FaceProperty : FaceProperty
  ResultType   : ResultType
  EventType    : EventType
  GestureType  : GestureType