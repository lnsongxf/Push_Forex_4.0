var http = require('http');
// Create a socket 
var zmq = require('zmq');

var sock1 = zmq.socket('pub'); 



sock1.bindSync('tcp://*:50005');


setInterval(function(){
  console.log("sending");
  sock1.send(["123","Message to metatrader"]);
},5000);