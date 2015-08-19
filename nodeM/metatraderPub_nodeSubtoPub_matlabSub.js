var http = require('http');
var zmq = require('zmq'); 

var QuotesModule = (function(){

	var _timeFrameQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the time-frame quotes from this specific Provider and for each cross"
	}

	var _createTimeFrameQuotesObj = function(quotes_list,providerName){

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
	}

	var _createRealTimeQuotesObj = function(quotes_list,providerName){
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

	var _updateTimeFrameQuotesObj = function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj){
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
		  								sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].toString()]);
		  							};
		  						}else{
	  								if (realTimeQuotesObj[key0] != "") {
		  								tempObj[Object.keys(tempObj)[0]].shift();
		  								tempObj[Object.keys(tempObj)[0]].push(realTimeQuotesObj[key0]);
		  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v10 
		  								var topicToSignalProvider = timeFrameQuotesObj.provider+key1+timeFrame+Object.keys(tempObj)[0];
		  								sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].toString()]);
		  							}
		  						}
		  						timeFrameQuotesObj[key1][index][timeFrame][j] = tempObj;
	  						};
	  						//uncomment this file if you want to check how are stored the quotes values
	  						console.log("timeFrameQuotesObj[key1][index][timeFrame]: ",timeFrameQuotesObj[key1][index][timeFrame]);
	  					}	
					}
				}
	  		}
		};

		return timeFrameQuotesObj;
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
// METATRADER PUB TO NODEJS TO MATLAB

var configQuotesList = require('./mt4_config_quotes');
var runningProviderTopicList = [];
var runningProviderTimeFrameObjs = {};
var runningProviderRealTimeObjs = {};

setInterval(function() {    

	if (runningProviderTopicList.length > 0) {
		for (var i = 0; i < runningProviderTopicList.length; i++) {
	    	var tmpTopicArr = runningProviderTopicList[i].toString().split("@");
	    	//TOPIC EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
	    	var tmpTimeFrameQuoteProperty = "TIMEFRAMEQUOTE$"+tmpTopicArr[0]+"$"+tmpTopicArr[1];
	    	var tmpRealTimeQuoteProperty = "REALTIMEQUOTE$"+tmpTopicArr[0]+"$"+tmpTopicArr[1];
	    	//EX Time Frame Obj Property: runningProviderTimeFrameObjs["TIMEFRAMEQUOTE$MT4$ACTIVTRADES"];
	   		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj("m1",runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty]);
	   		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
		}
	}

},5000);  // 1M
setInterval(function() {         },300000);  // 5M
setInterval(function() {         },900000);  // 15M
setInterval(function() {         },1800000);  // 30M
setInterval(function() {         },3600000);  // 60M - 1H
setInterval(function() {         },14400000);  // 240M - 4H
setInterval(function() {         },86400000);  // 1440M - 24H
setInterval(function() {         },604800000);  // 10080M - 1W

sockSubFromQuotesProvider.subscribe('NEWTOPICQUOTES');
sockSubFromQuotesProvider.on('message', function(topic, message) {
	var topicArr = topic.toString().split("@");
  	var messageArr = message.toString().split("@");

  	switch (topicArr[0]) {
  		case "NEWTOPICQUOTES":
  			//TOPIC MESSAGE EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
  			if ( runningProviderTopicList.indexOf( message.toString() ) == "-1" ) {
				runningProviderTopicList.push(message.toString());
				sockSubFromQuotesProvider.subscribe(message.toString());

				if ( messageArr[2] == "REALTIMEQUOTES" ||  messageArr[2] == "LISTQUOTES"){
					var newObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
					var newObjRealTimeQuote = "REALTIMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
					var newValuePropertyTimeFrameQuote = "TIMEFRAMEQUOTE@"+messageArr[0]+"@"+messageArr[1];
					var newValuePropertyRealTimeQuote = "REALTIMEQUOTE@"+messageArr[0]+"@"+messageArr[1];
					runningProviderTimeFrameObjs[newObjTimeFrameQuote] = QuotesModule.createTimeFrameQuotesObj(configQuotesList,newValuePropertyTimeFrameQuote);
					runningProviderRealTimeObjs[newObjRealTimeQuote] = QuotesModule.createRealTimeQuotesObj(configQuotesList,newValuePropertyRealTimeQuote);
				}
			};
  			break;

		case "DELETETOPICQUOTES":
			//TOPIC EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
			if ( runningProviderTopicList.indexOf( message.toString() ) > -1 ){
				var index = runningProviderTopicList.indexOf( message.toString() );
				runningProviderTopicList.splice(index, 1);
				sockSubFromQuotesProvider.unsubscribe(message.toString());

  				var searchObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
				var searchObjRealTimeQuote = "REALTIMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
				delete runningProviderTimeFrameObjs[searchObjTimeFrameQuote];
				delete runningProviderRealTimeObjs[searchObjRealTimeQuote];
			}
			break;

		default:
			if ( runningProviderTopicList.indexOf( topic.toString() ) > -1 ){
				//TOPIC EXAMPLE: MT4@ACTIVTRADES@REALTIMEQUOTES;
				var searchObjRealTimeQuote = "REALTIMEQUOTE$"+topicArr[0]+"$"+topicArr[1];
				var searchObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+topicArr[0]+"$"+topicArr[1];

				if (messageArr.length == 2) {
					for (var key0 in runningProviderRealTimeObjs) {
						if (key0 == searchObjRealTimeQuote) {
			  				for (var key in runningProviderRealTimeObjs[key0]) {
						  		if (runningProviderRealTimeObjs[key0].hasOwnProperty(key)) {
						  			if (key == messageArr[0]) {
						  				runningProviderRealTimeObjs[key0][key] = messageArr[1];
						  			};	
						  		}
							}
						}
					}
				}
				else if (messageArr.length > 2) {
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
						  									}else{
						  										tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].shift();
		  														tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].push(arrfirstQuotesValues[k]);
		  														tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j] = tmpObjSetValuesQuote;
						  										runningProviderTimeFrameObjs[key0][key][i] = tmpObjTimeFrameQuote;
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
				}
			}
	}
});

//----------------------------------------------------------------------------------------------------------------------------
// MATLAB PUB TO NODEJS TO METATRADER

sockSubFromSignalProvider.subscribe('OPEN$EURUSD');
sockSubFromSignalProvider.subscribe('CLOSE$EURUSD');

sockSubFromSignalProvider.on('message', function(messageSub) {
  var message = messageSub.toString().split(" ");
  console.log('received a message related to:', message[0], 'containing message:', message[1]);

  if (message[0] == "OPEN@EURUSD") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sockPub.send(message[0] + ";" +message[1]);
  };
  
  if (message[0] == "CLOSE@EURUSD") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sockPub.send(message[0] + ";" +message[1]);
  };

});




