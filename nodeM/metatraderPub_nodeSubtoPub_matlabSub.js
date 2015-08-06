var http = require('http');
// Create a socket 
var zmq = require('zmq'); 

var sock0 = zmq.socket('pub');
var sock = zmq.socket('pub');
var sock1 = zmq.socket('sub');
var sock2 = zmq.socket('pub');
var sock3 = zmq.socket('sub');

sock0.bindSync('tcp://127.0.0.1:60000');

sock1.bindSync('tcp://127.0.0.1:50025');
sock.bindSync('tcp://127.0.0.1:50026');   //EURUSD@30m@40
sock2.bindSync('tcp://127.0.0.1:50027');  //EURUSD@5m@40
sock3.bindSync('tcp://127.0.0.1:50028');  


console.log('Matlab configuration on port 60000');
console.log('Node Sub from Metatrader on port 50025');
console.log('Node Pub to Matlab on port 50025');

var TopicList0 = "EURUSD@30m@40$50026;EURUSD@5m@40$50027";
var TopicList1 = "EURUSD@30m@40$50026;EURUSD@5m@40$50027kkkkkkkkkkkkkkkkkkkkkk";
b = 0
console.log("Sending Topic List to Matlab: "+TopicList0+ "to Metatrader");
setInterval(function(){ 
	if (b == 1) {
		setTimeout(function(){
			sock0.send(['TOPICS_LIST', TopicList1]);
		},10000);
	}else{
		setTimeout(function(){
			sock0.send(['TOPICS_LIST', TopicList0]);
			b = 1;
		},10000);
	}
}, 3000);

 
// TOPIC EURUSD@30m@40 FROM METATRADER TO NODE TO MATLAB
sock1.subscribe('EURUSD@30m@40');
sock1.on('message', function(topic, message) {
  console.log('received a message related to:', topic.toString(), 'containing message:', message.toString());
  if ( topic.toString() == "EURUSD@30m@40") {
  	sock.send(['EURUSD@30m@40', message.toString()]);
  };
});

setInterval(function(){ 
	sock.send(['EURUSD$30m$40', '2.45']);
}, 3000);

setInterval(function(){ 
	sock.send(['EURUSD$5m$40', '12.45']);
}, 4000);

sock3.subscribe('OPEN$EURUSD');
sock3.on('message', function(message) {
	console.log('message: ',message.toString());
	//console.log('received a message related to:', topic.toString(), 'containing message:', message.toString());
});