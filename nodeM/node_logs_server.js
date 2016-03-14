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
    	level: 'errorStore',
    	path: '../../NodeLogs/4casterLogApp-error.log',  // log INFO and above to a file
    	period: '1d',   // daily rotation
    	count: 5        // keep 3 back copies
    },
    {
    	level: 'infoStore',
    	path: '../../NodeLogs/4casterLogApp-info.log',  // log INFO and above to a file
    	period: '1d',   // daily rotation
    	count: 5       // keep 3 back copies
    },
    {
      level: 'fatalStore',
      path: '../../NodeLogs/4casterLogApp-fatal.log',  // log INFO and above to a file
      period: '1d',   // daily rotation
      count: 5        // keep 3 back copies
    },
      {
      level: 'errorMessaging',
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
      level: 'infoMessaging',
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
      level: 'fatalMessaging',
      stream: new BunyanSlack({
        webhook_url: "https://hooks.slack.com/services/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",
        channel: "#logs-node-beta",
        username: "admin",
        customFormatter: function(record, levelName){
            return {text: "[" + levelName + "] " + record.msg }
        }
      })
    }
  ]
});


sockSub.subscribe('LOGS');
sockSub.on('message', function(topic, message) {

	if (topic == "LOGS@INFO") {
		log.infoStore(message.toString());
    log.infoMessaging(message.toString());
	}else if (topic == "LOGS@FATAL") {
		log.fatalStore(message.toString());
    log.fatalMessaging(message.toString());
	}else if( topic == "LOGS@ERROR" ){
		log.errorStore(message.toString());
    log.errorMessaging(message.toString());
	}else if (topic == "LOGS@TRACE") {
		log.trace(message.toString());
	};
});


