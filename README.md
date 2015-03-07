Kinect2 Socket Client
----

a javascript client library that can connect to a kinect2-socket application or load playback files.
It runs in the browser or with nodejs.

*example/simple.html* :
![Simple Example](https://raw.githubusercontent.com/kikko/kinect2-socket-client/master/example/simple.png)

## Usage

### Browser 

1) include the `kinect2-socket.min.js` file located in the `bin` folder :
```html
<script src="kinect2-socket.min.js"></script>
```

2) initialize the tracker and a data proxy (`ks.SocketStream` or `ks.Playback`) :
```javascript
var tracker = new ks.Tracker
tracker.addListener('user_in',  onKinectUserIn);
tracker.addListener('user_out', onKinectUserOut);

var kinectProxy = new ks.Playback(tracker);
kinectProxy.play('replay.json.gz', 30);

function onKinectUserIn(event) {
  console.log('> user in ' + event.body.id);
  bodies.push(event.body);
}

function onKinectUserOut(event) {
  console.log('< user out ' + event.body.id);
  bodies.splice(bodies.indexOf(event.body),1);
}
```

- look at `examples/simple.html` for a more complete usage example

### Nodejs / Browserify

Same as browser, except you import the library using
```javascript
ks = require('src/kinect2-socket');
```


## Dev

- clone this repository
- install dependencies with `npm install`
- make sure everything's fine `cake test`
- start developping with `cake dev`
- export minified with `cake export`