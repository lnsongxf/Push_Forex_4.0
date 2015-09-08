var http = require('http');
var zmq = require('zmq'); 
var schedule = require('node-schedule');
var bunyan = require('bunyan');

var logger = bunyan.createLogger({name: 'PushForex4.0'});
var logger = bunyan.createLogger({
    name: 'PushForex4.0',
    streams: [
    	{
	        type: 'rotating-file',
	        path: '/forexLog/info/broker.log',
	        period: '1d',   // daily rotation
	        count: 30        // keep 3 back copies
	        level: "info"
    	},
    	{
	        type: 'rotating-file',
	        path: '/forexLog/warn/broker.log',
	        period: '1d',   // daily rotation
	        count: 30        // keep 3 back copies
	        level: "warn"
    	},
    	{
	        type: 'rotating-file',
	        path: '/forexLog/error/broker.log',
	        period: '1d',   // daily rotation
	        count: 30        // keep 3 back copies
	        level: "error"
    	},
    	{
	        type: 'rotating-file',
	        path: '/forexLog/fatal/broker.log',
	        period: '1d',   // daily rotation
	        count: 30        // keep 3 back copies
	        level: "fatal"
    	},
    ]
});

/*
"fatal" (60): The service/app is going to stop or become unusable now. An operator should definitely look into this soon.
"error" (50): Fatal for a particular request, but the service/app continues servicing other requests. An operator should look at this soon(ish).
"warn" (40): A note on something that should probably be looked at by an operator eventually.
"info" (30): Detail on regular operation.
*/

var QuotesModule = (function(){

	var _timeFrameQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the time-frame quotes from this specific Provider and for each cross"
	};

	var _createTimeFrameQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			logger.error('quotes_list %s or providerName %s null or not defined into _createTimeFrameQuotesObj',quotes_list,providerName);
		};
		var _quotesObj = new _timeFrameQuotes(providerName);

		var arr = quotes_list.quotes;
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        //console.log("attrName: "+attrName+" attrValue: "+attrValue);
		        _quotesObj[attrValue]=[{"m1":[]},{"m5":[]},{"m15":[]},{"m30":[]},{"h1":[]},{"h4":[]},{"d1":[]},{"w1":[]}];
				for(var j=0; j<_quotesObj[attrValue].length; j++){
					_quotesObj[attrValue][j][Object.keys(_quotesObj[attrValue][j])[0]]=[{"v1":[]},{"v5":[]},{"v10":[]},{"v20":[]},{"v40":[]},{"v80":[]}];
		        }
		    }
		}
		return _quotesObj
	};

	var _realTimeQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the last current quotes from this specific provider and for each cross"
	};

	var _createRealTimeQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			logger.error('quotes_list %s or providerName %s null or not defined into _createRealTimeQuotesObj',quotes_list,providerName);
		};
		var _realTimeQuotesObj = new _realTimeQuotes(providerName);

		var arr = quotes_list.quotes;
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        _realTimeQuotesObj[attrValue]="";
		    }
		}
		return _realTimeQuotesObj
	};

	var _updateRealTimeQuotesObj = function(searchObjRealTimeQuote,messageArr){
		for (var key0 in runningProviderRealTimeObjs) {
			if (key0 == searchObjRealTimeQuote) {
  				for (var key in runningProviderRealTimeObjs[key0]) {
			  		if (runningProviderRealTimeObjs[key0].hasOwnProperty(key)) {
			  			if (key == messageArr[0]) {
			  				runningProviderRealTimeObjs[key0][key] = messageArr[1];
			  				return true;
			  			};	
			  		}
				}
			}
		}
	};

	var _updateTimeFrameQuotesObj = function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj){

		if (timeFrame == null || timeFrame == undefined || timeFrameQuotesObj == null || timeFrameQuotesObj == undefined || realTimeQuotesObj == null || realTimeQuotesObj == undefined ) {
			logger.error('In _updateTimeFrameQuotesObj timeframe or timeFrameQuotesObj or realTimeQuotesObj is notDefined/null');
		};

		var index = "";
		switch (timeFrame){
			case "m1":
        		index = 0;
        		break;
    		case "m5":
    			index = 1;
    			break;
    		case "m15":
    			index = 2;
    			break;
    		case "m30":
    			index = 3;
    			break;
    		case "h1":
    			index = 4;
    			break;
    		case "h4":
    			index = 5;
    			break;
			case "d1":
    			index = 6;
    			break;
			case "w1":
    			index = 7;
    			break;
		}

		var tempObj = "";
		for (var key0 in realTimeQuotesObj) {
	  		if (realTimeQuotesObj.hasOwnProperty(key0)) {
	  			for (var key1 in timeFrameQuotesObj) {
	  				if (realTimeQuotesObj.hasOwnProperty(key1)) {
	  					if (key0 == key1 && key0 != "provider" && key0 != "description") {
	  						for (var j = timeFrameQuotesObj[key1][index][timeFrame].length - 1; j >= 0; j--) {
	  							tempObj = timeFrameQuotesObj[key1][index][timeFrame][j];
	  							//console.log(tempObj);
		  						if (tempObj[Object.keys(tempObj)[0]].length < Object.keys(tempObj)[0].split("v")[1] ){
		  							if (realTimeQuotesObj[key0] != "") {
		  								tempObj[Object.keys(tempObj)[0]].push(realTimeQuotesObj[key0]);	
		  								var topic = key1;
		  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
		  								var topicToSignalProvider = timeFrameQuotesObj.provider+key1+timeFrame+Object.keys(tempObj)[0];
		  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
											logger.error({'timeFrameQuotesObjProvider':timeFrameQuotesObj.provider},{'key1':key1},{'timeFrame':timeFrame},{'totValues':Object.keys(tempObj)[0] },'In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
										};
										if (tempObj[Object.keys(tempObj)[0]].toString()] == null || tempObj[Object.keys(tempObj)[0]].toString()] == undefined ) {
											logger.error({'objWithMessageToSend':tempObj},' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
										};
		  								sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].toString()]);
		  							}else{
		  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
										//	logger.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
										//};
		  							}
		  						}else{
	  								if (realTimeQuotesObj[key0] != "") {
		  								tempObj[Object.keys(tempObj)[0]].shift();
		  								tempObj[Object.keys(tempObj)[0]].push(realTimeQuotesObj[key0]);
		  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v10 
		  								var topicToSignalProvider = timeFrameQuotesObj.provider+key1+timeFrame+Object.keys(tempObj)[0];
		  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
											logger.error({'timeFrameQuotesObjProvider':timeFrameQuotesObj.provider},{'key1':key1},{'timeFrame':timeFrame},{'totValues':Object.keys(tempObj)[0] },'In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
										};
										if (tempObj[Object.keys(tempObj)[0]].toString()] == null || tempObj[Object.keys(tempObj)[0]].toString()] == undefined ) {
											logger.error({'objWithMessageToSend':tempObj},' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
										};
		  								sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].toString()]);
		  							}else{
		  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
										//	logger.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
										//};
		  							}
		  						}
		  						timeFrameQuotesObj[key1][index][timeFrame][j] = tempObj;
	  						};
	  						//uncomment this file if you want to check how are stored the quotes values
	  						log.info({'timeFrameQuotesObj[key1][index][timeFrame]': timeFrameQuotesObj[key1][index][timeFrame] }, 'TimeFrame Obj Updated');
	  						//console.log("timeFrameQuotesObj[key1][index][timeFrame]: ",timeFrameQuotesObj[key1][index][timeFrame]);
	  					}	
					}
				}
	  		}
		};

		return timeFrameQuotesObj;
	};

	var _importHistoryTimeFrameQuotesObj = function(searchObjRealTimeQuote,messageArr){
		for (var key0 in runningProviderTimeFrameObjs) {
			if (key0 == searchObjTimeFrameQuote) {
				for (var key in runningProviderTimeFrameObjs[key0]) {
					if (runningProviderTimeFrameObjs[key0].hasOwnProperty(key)) {
			  			if (key == messageArr[0]) {
			  				for(var i=0;i<runningProviderTimeFrameObjs[key0][key].length;i++){
			  					for (var key1 in runningProviderTimeFrameObjs[key0][key][i]) {
			  						var tmpObjTimeFrameQuote = runningProviderTimeFrameObjs[key0][key][i];
			  						if ( Object.keys(tmpObjTimeFrameQuote)[0] == messageArr[1] ) {
			  							var arrfirstQuotesValues = messageArr[2].split("$");
			  							for(var k=0;k<arrfirstQuotesValues.length;k++){
			  								for(var j=0;j<tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]].length;j++){
			  									var tmpObjSetValuesQuote = tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j];
			  									if (tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].length < Object.keys(tmpObjSetValuesQuote)[0].split("v")[1] ){
			  										tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].push(arrfirstQuotesValues[k]);
			  										tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j] = tmpObjSetValuesQuote;
			  										runningProviderTimeFrameObjs[key0][key][i] = tmpObjTimeFrameQuote;
			  										return true;
			  									}else{
			  										tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].shift();
													tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].push(arrfirstQuotesValues[k]);
													tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j] = tmpObjSetValuesQuote;
			  										runningProviderTimeFrameObjs[key0][key][i] = tmpObjTimeFrameQuote;
			  										return true;
			  									}
			  								}
			  							}	
			  						}			
			  					}
			  				}
						}
					}
				}
			}
		}
	};

	return{
    	createTimeFrameQuotesObj: function(quotes_list,providerName){ 
      		return _createTimeFrameQuotesObj(quotes_list,providerName);  
    	},
    	createRealTimeQuotesObj:  function(quotes_list,providerName){ 
      		return _createRealTimeQuotesObj(quotes_list,providerName);  
    	},
    	updateTimeFrameQuotesObj: function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj){
    		return _updateTimeFrameQuotesObj(timeFrame,timeFrameQuotesObj,realTimeQuotesObj);
    	},
    	updateRealTimeQuotesObj: function(searchObjRealTimeQuote,messageArr){
    		return _updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);
    	},
    	importHistoryTimeFrameQuotesObj: function(searchObjTimeFrameQuote,messageArr){
    		return _importHistoryTimeFrameQuotesObj(searchObjTimeFrameQuote,messageArr);
    	}
    }

})();

var sockPub = zmq.socket('pub');
var sockSubFromQuotesProvider = zmq.socket('sub');
var sockSubFromSignalProvider = zmq.socket('sub');

sockSubFromQuotesProvider.bindSync('tcp://127.0.0.1:50025');
sockSubFromSignalProvider.bindSync('tcp://127.0.0.1:50026');    
sockPub.bindSync('tcp://127.0.0.1:50027');  

//-------------------------------------------------------------------------------------------------------------------------------
// QUOTES PROVIDER PUB TO NODEJS TO SIGNAL PROVIDER

var configQuotesList = require('./config_quotes');
if (configQuotesList == null || configQuotesList == undefined){
	logger.fatal('The file confing_quotes.json is not in the path or is empty ');
}
if (configQuotesList.quotes.length < 0){
	logger.fatal('The quotes list in the file config_quotes.json is empty');	
}
//REMEMBER THAT THE MONTH IN THE SERVER SETTING JSON START FROM 0 TO 11
//Month: Integer value representing the month, beginning with 0 for January to 11 for December
var serverSetting = require('./server_setting');
var runningProviderTopicList = [];
var runningProviderTimeFrameObjs = {};
var runningProviderRealTimeObjs = {};


// THE CODE BELOW SET THE SUBTASK TO UPDATED THE TIMEFRAME DATA EACH 1M,5M,15M ETC.. 
var startSchedule = serverSetting.serverSettingList[0].startScheduleTime.split(",");
if (startSchedule == null || startSchedule == undefined){
	logger.fatal('The start date in the Server is not defined or is null, check the server_setting.json file');
}else if ( startSchedule != null || startSchedule != undefined ) {
	logger.info({'startSchedule': startSchedule}, 'Server Start Date');
};
var date_start_schedule = new Date(startSchedule[0],startSchedule[1],startSchedule[2],startSchedule[3],startSchedule[4],startSchedule[5]);
var minutesList=[{'m1':60000},{'m5':300000},{'m15':900000},{'m30':1800000},{'h1':3600000},{'h4':14400000},{'d1':86400000},{'w1':604800000}];
var startTask0 = schedule.scheduleJob(date_start_schedule, function(){
    //console.log('Start Scheduling! Scheduled Time:'+startSchedule+'   Current Time: '+Date());
    for (var i = minutesList.length - 1; i >= 0; i--) {
    	//console.log("subtasks: ",minutesList[i][Object.keys(minutesList[i])[0]]," ",Object.keys(minutesList[i])[0]);
    	
    	logger.info({'setIntervalTask': minutesList[i][Object.keys(minutesList[i])[0]] }, 'Setting task every %s to update the timeframe Objs',minutesList[i][Object.keys(minutesList[i])[0]] );

    	setInterval(function() {  
	    	//console.log('Start Scheduling 1M! Current Time: '+Date());  

			if (runningProviderTopicList.length > 0) {
				logger.info({'startTaskUpdateTimeFrame': minutesList[i][Object.keys(minutesList[i])[0]] }, {'currentRunningProviderTopicList':runningProviderTopicList}, 'Start Task , updating TimeFrame %s',minutesList[i][Object.keys(minutesList[i])[0]] );
				for (var i = 0; i < runningProviderTopicList.length; i++) {
			    	var tmpTopicArr = runningProviderTopicList[i].toString().split("@");
			    	//TOPIC EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
			    	var tmpTimeFrameQuoteProperty = "TIMEFRAMEQUOTE$"+tmpTopicArr[0]+"$"+tmpTopicArr[1];
			    	var tmpRealTimeQuoteProperty = "REALTIMEQUOTE$"+tmpTopicArr[0]+"$"+tmpTopicArr[1];
			    	//EX Time Frame Obj Property: runningProviderTimeFrameObjs["TIMEFRAMEQUOTE$MT4$ACTIVTRADES"];
			   		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(Object.keys(minutesList[i])[0],runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty]);
			   		if ( new_timeFrameQuotesObj == null || new_timeFrameQuotesObj == undefined) {
			   			logger.error({ 'timeFrameObjToUpdate:': runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] },{ 'CurrentRealTimeObj:': runningProviderRealTimeObjs[tmpRealTimeQuoteProperty] },'new_timeFrameQuotesObj is null or undefined. TimeFrame %s is not updated',minutesList[i][Object.keys(minutesList[i])[0]]
			   		};
			   		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				}
			}
		},minutesList[i][Object.keys(minutesList[i])[0]]);  // 1M 5M etc..
    };
});

sockSubFromQuotesProvider.subscribe('NEWTOPICQUOTES');
sockSubFromQuotesProvider.subscribe('DELETETOPICQUOTES');
//sockSubFromQuotesProvider.subscribe('');
sockSubFromQuotesProvider.on('message', function(topic, message) {
	var topicArr = topic.toString().split("@");
  	var messageArr = message.toString().split("@");

  	switch (topicArr[0]) {
  		case "NEWTOPICQUOTES":
  			//TOPIC MESSAGE EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
  			if ( runningProviderTopicList.indexOf( message.toString() ) == "-1" ) {
				//CREATE AND ADD NEW TOPICS (EX: MT4@ACTIVTRADES@REALTIMEQUOTES) IN THE ARRAY LIST
				if ( messageArr[2] == "REALTIMEQUOTES" ||  messageArr[2] == "LISTQUOTES"){
					runningProviderTopicList.push(message.toString());
					sockSubFromQuotesProvider.subscribe(message.toString());
					logger.info({'topic': topicArr[0]}, 'Added new topic: %s ',message.toString() );
					var newObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
					var newObjRealTimeQuote = "REALTIMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
					var newValuePropertyTimeFrameQuote = "TIMEFRAMEQUOTE@"+messageArr[0]+"@"+messageArr[1];
					var newValuePropertyRealTimeQuote = "REALTIMEQUOTE@"+messageArr[0]+"@"+messageArr[1];
					runningProviderTimeFrameObjs[newObjTimeFrameQuote] = QuotesModule.createTimeFrameQuotesObj(configQuotesList,newValuePropertyTimeFrameQuote);
					if (runningProviderTimeFrameObjs[newObjTimeFrameQuote] == null || runningProviderTimeFrameObjs[newObjTimeFrameQuote] == undefined) {
						logger.error( {'topic': topicArr[0]}, {'message': message.toString() }, {'runningProviderTimeFrameObjs[newObjTimeFrameQuote]': runningProviderTimeFrameObjs[newObjTimeFrameQuote] }, 'TimeFrame Obj is not created for topic: %s !',message.toString() );
					};
					runningProviderRealTimeObjs[newObjRealTimeQuote] = QuotesModule.createRealTimeQuotesObj(configQuotesList,newValuePropertyRealTimeQuote);
					if (runningProviderRealTimeObjs[newObjRealTimeQuote] == null || runningProviderRealTimeObjs[newObjRealTimeQuote] == undefined) {
						logger.error( {'topic': topicArr[0]}, {'message': message.toString() }, {'runningProviderTimeFrameObjs[newObjTimeFrameQuote]': runningProviderRealTimeObjs[newObjRealTimeQuote] }, 'RealTime Obj is not created for topic: %s !',message.toString() );
					};
				}else{
					logger.error({'topic': topicArr[0]}, 'New topic: %s wrong format. The new Topic form Quotes Provider should ending with LISTQUOTES or REALTIMEQUOTES',message.toString() );
				}
			}else{
				logger.error({'topic': topicArr[0]}, 'Its not possible to add this topic name %s because the topic already exist',message.toString() );
			}
  			break;

		case "DELETETOPICQUOTES":
			//TOPIC EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
			if ( runningProviderTopicList.indexOf( message.toString() ) > -1 ){
				//REMOVE TOPICS (EX: MT4@ACTIVTRADES@REALTIMEQUOTES) IN THE ARRAY LIST
				var index = runningProviderTopicList.indexOf( message.toString() );
				runningProviderTopicList.splice(index, 1);
				sockSubFromQuotesProvider.unsubscribe(message.toString());
				logger.info({'topic': topicArr[0]}, 'Deleted topic: %s ',message.toString() );
  				var searchObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
				var searchObjRealTimeQuote = "REALTIMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
				if (runningProviderTimeFrameObjs[searchObjTimeFrameQuote] != null && runningProviderTimeFrameObjs[searchObjTimeFrameQuote] != undefined && runningProviderRealTimeObjs[searchObjRealTimeQuote] != null && runningProviderRealTimeObjs[searchObjRealTimeQuote] != undefined) {
					delete runningProviderTimeFrameObjs[searchObjTimeFrameQuote];
					delete runningProviderRealTimeObjs[searchObjRealTimeQuote];
				}else{
					logger.error({'topic': topicArr[0]},{'TimeFrameObj':runningProviderTimeFrameObjs[searchObjTimeFrameQuote]},{'RealTimeObj':runningProviderRealTimeObjs[searchObjRealTimeQuote];} 'Its not possible to delete the TimeFrameObj and RealTimeObj for the topic %s',message.toString() );
				}
				
			}else{
				logger.error({'topic': topicArr[0]}, 'Its not possible to delete this topic %s because this topic doesnt exist',message.toString() );
			}
			break;

		default:
			if ( runningProviderTopicList.indexOf( topic.toString() ) > -1 ){
				//TOPIC EXAMPLE: MT4@ACTIVTRADES@REALTIMEQUOTES;
				var searchObjRealTimeQuote = "REALTIMEQUOTE$"+topicArr[0]+"$"+topicArr[1];
				var searchObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+topicArr[0]+"$"+topicArr[1];

				if (messageArr.length == 2) {
					if (messageArr[2] == "REALTIMEQUOTES" ) {
						var result = QuotesModule.updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);
						if (result) {}else{console.log("error update real time Obj")};
					}else if (messageArr[2] == "OPERATIONSTATUS") {
						//SEND OPERATION MESSAGE ON OPERATION TOPIC
					}else{
						logger.error({'topic': topicArr[0]},{'message' : message.toString()}, 'Error type of message %s form Quotes Provider', message.toString() );
					}
				}
				else if (messageArr.length > 2) {
					var result = QuotesModule.importHistoryTimeFrameQuotesObj(searchObjTimeFrameQuote,messageArr);
					if (result == null || result == undefined) {
						logger.error({'topic': topicArr[0]},{'message' : message.toString()},'Error to import HistoryData for message: %s', message.toString() );
					}else{
						logger.error( {'topic': topicArr[0]},{'message' : message.toString()},{'updatedHistoryQuotes':result} );
					}
				}else{
					logger.error({'topic': topicArr[0]},{'message' : message.toString()}, 'Error in message received from Quotes provider. Message %s length is not right',message.toString() );
				}
			}
	}
});

//----------------------------------------------------------------------------------------------------------------------------
// SIGNAL PROVIDE PUB TO NODEJS TO QUOTES PROVIDER

var runningSignalProviderTopicOperationList = [];
var runningSignalProviderTopicStatusList = [];
var TopicAlgosOperationListLabel = 'ALGOSOPERATIONLIST'; 
var TopicAlgosStatusListLabel = 'ALGOSSTATUSLIST'; 


setInterval(function(){
	if ( runningSignalProviderTopicOperationList.length > 0 ){
		var runningSignalProviderTopicOperationListString = JSON.stringify(runningSignalProviderTopicOperationList);
		sockPub.send([TopicAlgosOperationListLabel, runningSignalProviderTopicOperationListString]);
	}else{
		//log arr empty
	}

	if ( runningSignalProviderTopicStatusList.length > 0 ) {
		var runningSignalProviderTopicStatusListString = JSON.stringify(runningSignalProviderTopicStatusList);
		sockPub.send([TopicAlgosStatusListLabel, runningSignalProviderTopicStatusListString]);
	}else{
		//log arr empty
	}
},10000);

sockSubFromSignalProvider.subscribe('NEWTOPICFROMSIGNALPROVIDER');
sockSubFromSignalProvider.on('message', function(messageSub) {
  
	var data = messageSub.toString().split(" ");
  	console.log('received a message related to:', data[0], 'containing message:', data[1]);
  	var topic = data[0];
  	var message = data[1];

  	switch (topic) {
  		case "NEWTOPICFROMSIGNALPROVIDER":

  			var newTopic = message.split('@');
  			if (newTopic[3] == 'OPERATIONS') {
  				if ( runningSignalProviderTopicOperationList.indexOf( message ) == "-1" ) {
					//CREATE AND ADD NEW TOPICS (EX: MATLAB@111@EURUSD@OPERATIONS) IN THE ARRAY LIST
					runningSignalProviderTopicOperationList.push(message); 
					sockSubFromSignalProvider.subscribe(message);
					var runningSignalProviderTopicOperationListString = JSON.stringify(runningSignalProviderTopicOperationList);
					sockPub.send([TopicAlgosOperationListLabel, runningSignalProviderTopicOperationListString]);
				}
  			}
  			else if (newTopic[3] == 'STATUS'){
  				if ( runningSignalProviderTopicStatusList.indexOf( message ) == "-1" ) {
					//CREATE AND ADD NEW TOPICS (EX: MATLAB@111@EURUSD@STATUS) IN THE ARRAY LIST
					runningSignalProviderTopicStatusList.push(message); 
					sockSubFromSignalProvider.subscribe(message);
					var runningSignalProviderTopicStatusListString = JSON.stringify(runningSignalProviderTopicStatusList);
					sockPub.send([TopicAlgosStatusListLabel, runningSignalProviderTopicStatusListString]);
				}
  			}
			break;

		case "DELETETOPICQUOTES":
			//EX TOPIC: MATLAB@111@EURUSD@OPERATIONS, MATLAB@111@EURUSD@STATUS
			var deleteTopic = message.split('@');
  			if (deleteTopic[3] == 'OPERATIONS') {
				if ( runningSignalProviderTopicOperationList.indexOf( message ) > -1 ){
					//REMOVE TOPICS (EX: MATLAB@111@EURUSD@OPERATIONS) IN THE ARRAY LIST
					var index = runningSignalProviderTopicOperationList.indexOf( message );
					runningSignalProviderTopicOperationList.splice(index, 1);
					sockSubFromSignalProvider.unsubscribe( message );
				}
			}
			else if (deleteTopic[3] == 'STATUS'){
  				if ( runningSignalProviderTopicStatusList.indexOf( message ) == "-1" ) {
  					//REMOVE TOPICS (EX:MATLAB@111@EURUSD@STATUS) IN THE ARRAY LIST

  					var index = runningSignalProviderTopicStatusList.indexOf( message );
					runningSignalProviderTopicStatusList.splice(index, 1);
					sockSubFromSignalProvider.unsubscribe( message );
  				}
  			}
			break;

		default:
		 	//EX: MATLAB@111@EURUSD@OPERATIONS, MATLAB@111@EURUSD@STATUS
			var topicType = topic.split('@');
  			if (topicType[3] == 'OPERATIONS') {
  				if ( runningSignalProviderTopicOperationList.indexOf( topic ) > -1 ) {
					sockPub.send([topic, message]);
				}
			}
			else if (topic[3] == 'STATUS'){
  				if ( runningSignalProviderTopicStatusList.indexOf( topic ) > -1 ) {
  					sockPub.send([topic, message]);	
  				}
  			}
			break;
	}

});





