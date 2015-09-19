var zmq = require('zmq'); 


var sockSub = zmq.socket('sub');

sockSub.connect('tcp://192.168.0.11:50028');

sockSub.subscribe('LOGS');
sockSub.on('message', function(topic, message) {

console.log("topic: "+topic);
console.log("mess: "+message);
});



/*var sockLog = zmq.socket('pub');
sockSub.bindSync('tcp://192.168.0.16:50028');


sockLog.send(['NEWTOPICQUOTES', 'message']);
*/