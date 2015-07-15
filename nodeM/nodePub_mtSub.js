var http = require('http');
// Create a socket 
var zmq = require('zmq');
 
// pubber.js 

var sock = zmq.socket('push');

//sock_pub.bindSync('tcp://127.0.0.1:50016');
//sock_pub.connect('tcp://127.0.0.1:50022');
console.log('Publisher bound to port 50022');

/*setInterval(function(){
  console.log('sending a multipart message envelope');
  //sock_pub.send('cmd');
  //sock_pub.send('Message #1');

	sock_pub.send("mess 1");
  	sock_pub.send('mess 2');
  	sock_pub.send("mess 3");
}, 1500);*/
 
sock.connect('tcp://127.0.0.1:50023');
console.log('Publisher bound to port 3000');
 
setInterval(function(){
  console.log('sending a multipart message envelope');
  //sock.send(['casa 1', 'casa 2', 'casa 3']);
  sock.send('casa 2 ; casa 3');
}, 500);
