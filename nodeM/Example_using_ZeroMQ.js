var http = require('http');
// Create a socket 
var zmq = require('zmq');

var sock1 = zmq.socket('pub'); 



sock1.bindSync('tcp://127.0.0.1:50005');


setInterval(function(){
  console.log("sending");
  sock1.send(["EURUSD","1234"]);
},500);
    



