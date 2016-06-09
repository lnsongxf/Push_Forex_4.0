// set up ======================================================================
var express = require('express');
var app = express(); 						// create our app w/ express
var port = process.env.PORT || 9801; 				// set the port
var morgan = require('morgan');
var bodyParser = require('body-parser');
var methodOverride = require('method-override');
var later = require('later');
var token = "xoxp-26578680480-26574282375-49569305856-fe6ce7c82d";
var fs = require('fs');
var WebClient = require('@slack/client').WebClient;
var web = new WebClient(token);


app.use(express.static(__dirname + '/public')); 		// set the static files location /public/img will be /img for users
app.use(morgan('dev')); // log every request to the console
app.use(bodyParser.urlencoded({'extended': 'true'})); // parse application/x-www-form-urlencoded
app.use(bodyParser.json()); // parse application/json
app.use(bodyParser.json({type: 'application/vnd.api+json'})); // parse application/vnd.api+json as json
app.use(methodOverride('X-HTTP-Method-Override')); // override with the X-HTTP-Method-Override header in the request

// routes ======================================================================
require('./app/routes.js')(app);


// fires every day at 09am and 09:02
var sched_d1 = later.parse.recur().on('09:00:00').time();
var sched_d2 = later.parse.recur().on('09:02:00').time();
later.setInterval(function() { 
	var exec = require('child_process').exec;
	var cmd = 'casperjs reportsScript.js';
	exec(cmd, function(error, stdout, stderr) { 
		// command output is in stdout
	});
}, sched_d1);
later.setInterval(function() { 
	if (fs.existsSync('lastOperations.png')) {
	    console.log('Found file');
	    var filePath = 'lastOperations.png';
		var fileName = 'lastOperations.png';
		// File upload via file param
		var streamOpts = {
		  file: fs.createReadStream(filePath),
		  filetype: 'png',
		  title: 'Last Operations',
		  initialComment: '',
		  channels: '#general'
		};
		web.files.upload(fileName, streamOpts, function handleStreamFileUpload(err, res) {
		  console.log('err: ',err);
		  console.log(res);
		});
	}
}, sched_d2);

// listen (start app with node server.js) ======================================
app.listen(port);
console.log("App listening on port " + port);
