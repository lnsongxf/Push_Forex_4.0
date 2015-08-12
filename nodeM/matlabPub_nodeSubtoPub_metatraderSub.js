var http = require('http');
// Create a socket 
var zmq = require('zmq');
var sock = zmq.socket('sub');
var sock1 = zmq.socket('push'); 


sock.bindSync('tcp://127.0.0.1:50004');
sock1.bindSync('tcp://127.0.0.1:50005');
sock.bindSync('tcp://127.0.0.1:50028'); 


sock.subscribe('OPEN$EURUSD');
sock.subscribe('CLOSE$EURUSD');

sock.on('message', function(messageSub) {
  var message = messageSub.toString().split(" ");
  console.log('received a message related to:', message[0], 'containing message:', message[1]);


  // TOPIC OPEN@EURUSD@30m@40 FROM MATLAB TO NODE TO METATRADER 
  if (message[0] == "OPEN@EURUSD") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sock1.send(message[0] + ";" +message[1]);
  };
  
  if (message[0] == "CLOSE@EURUSD") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sock1.send(message[0] + ";" +message[1]);
  };


});


