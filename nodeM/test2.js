var zmq = require('zmq'); 


var sockPub = zmq.socket('pub');
//sockPub.bindSync('tcp://*:53661');

sockPub.connect('tcp://127.0.0.1:53662');

//TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m30@v100


setInterval(function(){
  console.log('sending a multipart message envelope');
  sockPub.send(['NEWTOPIC', 'sadasdasd']);
}, 2000);