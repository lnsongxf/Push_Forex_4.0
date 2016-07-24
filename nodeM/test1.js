var zmq = require('zmq'); 


//var sockPub = zmq.socket('pub');
//sockPub.bindSync('tcp://*:53652');

var sockSub = zmq.socket('sub');

sockSub.bindSync('tcp://127.0.0.1:53662');


//TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v100
sockSub.subscribe('NEWTOPIC');
sockSub.on('message', function(topic, message) {

	console.log("sub topic: "+topic);
	console.log("sub mess: "+message);
});

