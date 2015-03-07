# extend util borrowed from FieldKit.js https://github.com/field/FieldKit.js
extend = (obj, source) ->
  # ECMAScript5 compatibility based on: http://www.nczonline.net/blog/2012/12/11/are-your-mixins-ecmascript-5-compatible/
  if Object.keys
    keys = Object.keys(source)
    i = 0
    il = keys.length

    while i < il
      prop = keys[i]
      Object.defineProperty obj, prop, Object.getOwnPropertyDescriptor(source, prop)
      i++
  else
    safeHasOwnProperty = {}.hasOwnProperty
    for prop of source
      obj[prop] = source[prop]  if safeHasOwnProperty.call(source, prop)
  obj

# namespace 
ks = {}

# extend
extend ks, require './core/definitions'
extend ks, require './core/body'
extend ks, require './core/tracker'
extend ks, require './core/helpers'
extend ks, require './sync/playback'
extend ks, require './sync/socket_stream'
extend ks, require './extras/debugview_canvas'

# export
module.exports = ks

# attach to global window object in browser based environments
window.ks = ks if window?