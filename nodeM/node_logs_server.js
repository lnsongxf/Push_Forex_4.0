var bunyan = require('bunyan');
var zmq = require('zmq'); 
var BunyanSlack = require('bunyan-slack');
//var log;



var sockSub = zmq.socket('sub');
sockSub.connect('tcp://localhost:50028');
var log = bunyan.createLogger({
	name: '4casterLogApp',
	streams: [
    {
    	level: 'trace',
      stream: process.stdout         // log INFO and above to stdout
    },
    {
    	level: 'error',
    	path: '../../NodeLogs/4casterLogApp-error.log',  // log INFO and above to a file
    	period: '1d',   // daily rotation
    	count: 5        // keep 3 back copies
    },
    {
    	level: 'info',
    	path: '../../NodeLogs/4casterLogApp-info.log',  // log INFO and above to a file
    	period: '1d',   // daily rotation
    	count: 5,        // keep 3 back copies
    	stream: new BunyanSlack({
        webhook_url: "https://hooks.slack.com/services/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",
        channel: "#logs-node-beta",
        username: "admin",
        customFormatter: function(record, levelName){
            return {text: "[" + levelName + "] " + record.msg }
        }
      })
    },
    {
      level: 'fatal',
      path: '../../NodeLogs/4casterLogApp-fatal.log',  // log INFO and above to a file
      period: '1d',   // daily rotation
      count: 5        // keep 3 back copies
    }
  ]
});


sockSub.subscribe('LOGS');
sockSub.on('message', function(topic, message) {

	if (topic == "LOGS@INFO") {
		log.info(message);
	}else if (topic == "LOGS@FATAL") {
		log.fatal(message);
	}else if( topic == "LOGS@ERROR" ){
		log.error(message);
	}else if (topic == "LOGS@TRACE") {
		log.trace(message);
	};
});


