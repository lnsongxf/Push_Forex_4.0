var http = require('http');
// Create a socket 
var zmq = require('zmq');
var sock = zmq.socket('sub');
 

// pubber.js 

// producer.js
//sock.bindSync('tcp://127.0.0.1:50005');


// subber.js 

sock.connect('tcp://127.0.0.1:50004');
sock.subscribe('cmd1');
console.log('Subscriber connected to port 50004');

sock.on('message', function(topic, message) {
  console.log('received a message related to:', topic.toString(), 'containing message:', message.toString());
});



/*sock.connect('tcp://127.0.0.1:50004');
console.log('Worker connected to port 3000');

sock.on('message', function(msg){
  console.log('work: %s', msg.toString());
});*/

