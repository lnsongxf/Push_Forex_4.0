var bunyan = require('bunyan');
var zmq = require('zmq'); 
var BunyanSlack = require('bunyan-slack');
//var log;



var sockSub = zmq.socket('sub');
sockSub.connect('tcp://localhost:50028');


var logStore = bunyan.createLogger({
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
    	count: 5       // keep 3 back copies
    },
    {
      level: 'fatal',
      path: '../../NodeLogs/4casterLogApp-fatal.log',  // log INFO and above to a file
      period: '1d',   // daily rotation
      count: 5        // keep 3 back copies
    }
  ]
});


var logMessaging = bunyan.createLogger({
  name: '4casterLogApp',
  streams: [
    {
      level: 'error',
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
      level: 'info',
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
		logStore.info(message.toString());
    logMessaging.info(message.toString());
	}else if (topic == "LOGS@FATAL") {
		logStore.fatal(message.toString());
    logMessaging.fatal(message.toString());
	}else if( topic == "LOGS@ERROR" ){
		logStore.error(message.toString());
    logMessaging.error(message.toString());
	}else if (topic == "LOGS@TRACE") {
		logStore.trace(message.toString());
	};
});


