var http = require('http');
// Create a socket 
var zmq = require('zmq');
var sock = zmq.socket('sub');
var sock1 = zmq.socket('push'); 

sock.bindSync('tcp://127.0.0.1:50004');
sock1.bindSync('tcp://127.0.0.1:50005');
console.log('Node Sub from Matlab on port 50004');
console.log('Node Pub to Metatrader on port 50005');


sock.subscribe('OPEN@EURUSD@30m@40');
sock.subscribe('OPEN@EURUSD@5m@40');

sock.on('message', function(message1, message2) {
  var message = message1.toString().split(" ");
  console.log('received a message related to:', message[0], 'containing message:', message[1]);


  // TOPIC OPEN@EURUSD@30m@40 FROM MATLAB TO NODE TO METATRADER 
  if (message[0] == "OPEN@EURUSD@30m@40") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sock1.send(message[0] + ";" +message[1]);
  };
  
  if (message[0] == "OPEN@EURUSD@5m@40") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sock1.send(message[0] + ";" +message[1]);
  };


});


