console.log("started worker");

var db;


Array.prototype.appendArr = function (old_array,other_array,source,platform) {
    /* you should include a test to check whether other_array really is an array */
    var newHistoryArr = [];
    for(var i = old_array.length-1; i>=0; i--){
    	newHistoryArr.push(old_array[i]);
    }
    for(var i=0; i<=other_array.length-1; i++){
    	var tmpQuote = other_array[i].toString().split(',');
    	var date = tmpQuote[0];
    	var time = tmpQuote[1];
    	var dateTime = tmpQuote[0]+" "+tmpQuote[1];
    	var open = tmpQuote[2];
    	var high = tmpQuote[3];
    	var low = tmpQuote[4];
    	var close = tmpQuote[5];
    	var volume = tmpQuote[6];
    	var row = {source:source, platform:platform, date:date, time:time, open:open, high:high, low:low, close:close, volume:volume};
    	newHistoryArr.push(row);
    }   
    console.log("append: "+JSON.stringify(newHistoryArr) );
    return newHistoryArr;
}
var prependArr = function (old_array,other_array,source,platform) {
    /* you should include a test to check whether other_array really is an array */
    //for(var i=other_array.length-1;i>=0;i--){
    var newHistoryArr = [];
    for(var i=0; i<=other_array.length-1; i++){
    	var tmpQuote = other_array[i].toString().split(',');
    	var date = tmpQuote[0];
    	var time = tmpQuote[1];
    	var dateTime = tmpQuote[0]+" "+tmpQuote[1];
    	var open = tmpQuote[2];
    	var high = tmpQuote[3];
    	var low = tmpQuote[4];
    	var close = tmpQuote[5];
    	var volume = tmpQuote[6];
    	var row = {source:source, platform:platform, date:date, time:time, open:open, high:high, low:low, close:close, volume:volume};
    	newHistoryArr.push(row);
    }   
    for(var i = old_array.length-1; i>=0; i--){
    	newHistoryArr.push(old_array[i]);
    }
    console.log("prepend: "+JSON.stringify(newHistoryArr) );
    return newHistoryArr;
}

Array.prototype.pushUnique = function (item){
    if(this.indexOf(item) == -1) {
    //if(jQuery.inArray(item, this) == -1) {
        this.push(item);
        return true;
    }
    return false;
};

if (!Array.prototype.last){
    Array.prototype.last = function(){
        return this[this.length - 1];
    };
};
Array.prototype.max = function() {
  return Math.max.apply(null, this);
};
Array.prototype.min = function() {
  return Math.min.apply(null, this);
};

var QuotesModule = (function(){

	var _timeFrameQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the time-frame quotes from this specific Provider and for each cross"
	};

	var _createTimeFrameQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			console.log('quotes_list %s or providerName '+quotes_list,providerName+' null or not defined into _createTimeFrameQuotesObj');
			return null;
			
		};
		var _quotesObj = new _timeFrameQuotes(providerName);

		var arr = quotes_list.quotes;
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        _quotesObj[attrValue]=[{"m1":[]},{"m5":[]},{"m15":[]},{"m30":[]},{"h1":[]},{"h4":[]},{"d1":[]},{"w1":[]}];
				for(var j=0; j<_quotesObj[attrValue].length; j++){
					_quotesObj[attrValue][j][Object.keys(_quotesObj[attrValue][j])[0]]=[{"v1":[]},{"v5":[]},{"v10":[]},{"v20":[]},{"v40":[]},{"v100":[]}];
		        }
		    }
		}
		console.log("created new TimeFrameQuotesObj: providerName: "+providerName);  
		return _quotesObj
	};


	var _realTimeQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the last current quotes from this specific provider and for each cross"
	};

	var _createRealTimeQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			console.log('quotes_list '+quotes_list+' or providerName '+providerName+' null or not defined into _createRealTimeQuotesObj');
			return null;
		};
		var _realTimeQuotesObj = new _realTimeQuotes(providerName);

		var arr = quotes_list.quotes;
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        //_realTimeQuotesObj[attrValue]="";  17/03 changed
		        _realTimeQuotesObj[attrValue]={
		        	"m1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"m5":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"m15":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"m30":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"h1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"h4":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"d1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"w1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null}
		        }
		    }
		}

		//console.log("created new realTimeQuotesObj: "+JSON.stringify( _realTimeQuotesObj)+ " providerName: "+providerName);
		return _realTimeQuotesObj
	};

	var _updateRealTimeQuotesObj = function(platform,messageArr){
		if (platform == null || platform == undefined || messageArr == null || messageArr == undefined) {
			console.log('searchObjRealTimeQuote '+searchObjRealTimeQuote+' or messageArr '+messageArr+' null or not defined into _updateRealTimeQuotesObj');
			return null;
		};

		//messageArr: [event.data.d[j].cross,open,high,low,close,volume];
		
		var realOpen = messageArr[1];
		var realMax = messageArr[2];
		var realMin = messageArr[3];
		var realClose = messageArr[4];
		var realVolume = messageArr[5];
		var cross = messageArr[0];
		var dateTime = messageArr[6];

		if (runningProviderRealTimeObjs[platform] == null || runningProviderRealTimeObjs[platform] == undefined) {
			console.log("Unable to find platform " + platform);
			return null;
		}
		
		if (runningProviderRealTimeObjs[platform][cross] == null || runningProviderRealTimeObjs[platform][cross] == undefined) {
			console.log("Unable to find cross " + cross + " in platform " + platform);
			return null;
		}		
			  				
		for( timeFrame in runningProviderRealTimeObjs[platform][cross] ){
		    if (realMax > runningProviderRealTimeObjs[platform][cross][timeFrame]['max'] || runningProviderRealTimeObjs[platform][cross][timeFrame]['max'] == null){
			    runningProviderRealTimeObjs[platform][cross][timeFrame]['max'] = realMax;
			}
			if (realMin < runningProviderRealTimeObjs[platform][cross][timeFrame]['min'] || runningProviderRealTimeObjs[platform][cross][timeFrame]['min'] == null){
			    runningProviderRealTimeObjs[platform][cross][timeFrame]['min'] = realMin;
			}
			if( runningProviderRealTimeObjs[platform][cross][timeFrame]['open']  == null){
				runningProviderRealTimeObjs[platform][cross][timeFrame]['open'] = realOpen;
			}
			runningProviderRealTimeObjs[platform][cross][timeFrame]['close'] = realClose;
			runningProviderRealTimeObjs[platform][cross][timeFrame]['dateTime'] = dateTime;
			if (timeFrame == 'm1') {
				runningProviderRealTimeObjs[platform][cross][timeFrame]['volume'] = parseInt(realVolume);
			}
							
			if (cross == 'EURUSD' && timeFrame == 'm1') {
				//console.log("messageArr: "+JSON.stringify(messageArr) );
				//console.log("runningProviderRealTimeObjs[platform][cross][timeFrame]: "+JSON.stringify(runningProviderRealTimeObjs[platform]['EURUSD']['m1']) );
			};
		}
		return true;
	};

	var _createNewQuote = function(tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty,cross,timeFrame){
			
		//tmpRealTimeQuoteProperty is the first "search key" used in the global runningProviderRealTimeObjs (es: REALTIMEQUOTE$MT4$ACTIVTRADES)
		//timeframe is the value used to specify the type of timeframe (ex: m1,m5,m15,..). Its used also like 

		//ex: single quote == 11313,11315,11313,11316,30,03/18/2016 01:24  -->   apertura,massimo,minimo,chiusura,volume,time

		var open = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['open'];
		var max = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['max'];
		var min = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['min'];
		var close = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['close'] ;
		var volume = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['volume'];  //needed only for m1
		//var currentdate = new Date(); 
		//var datetime = currentdate.getDate()+"/"+(currentdate.getMonth()+1)+"/"+currentdate.getFullYear()+" "+currentdate.getHours()+":"+currentdate.getMinutes(); 
		var datetime = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['dateTime']; 

		if (timeFrame != 'm1') {

			var prevTimeFrame = "";  // this variable is used to store the previous timeframe (es: i want to update m5 array i have to consider m1 array. In this case prevTimeFrame = m1 )
			var index = "";
			numValues = "";
			switch (timeFrame){
	    		case "m5":
	    			prevTimeFrame = 'm1';
	    			index = 0;
	    			numValues = 5;  // m1 x 5 = m5
	    			break;
	    		case "m15":
	    			prevTimeFrame = 'm5';
	    			index = 1;
	    			numValues = 3;   // m5 x 3 = m15
	    			break;
	    		case "m30":
	    			prevTimeFrame = 'm15';
	    			index = 2;
	    			numValues = 2;   // m15 x 2 = m30
	    			break;
	    		case "h1":
	    			prevTimeFrame = 'm30';
	    			index = 3;
	    			numValues = 2;  // m30 x 2 = h1
	    			break;
	    		case "h4":
	    			prevTimeFrame = 'h1';
	    			index = 4;
	    			numValues = 4;  // h1 x 4 = h4
	    			break;
				case "d1":
	    			prevTimeFrame = 'h4';
	    			index = 5;
	    			numValues = 6;  // h4 x 6 = d1
	    			break;
				case "w1":
	    			prevTimeFrame = 'd1';
	    			index = 6;
	    			numValues = 5;  // d1 x 7 = w1
	    			break;
			}

			var tmpArrPreviousTimeFrameQuotesV10 = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][cross][index][prevTimeFrame][2]['v10']; //we are going to get the previous timeframe array(es: if timeframe is m5 we get m1)
			if( tmpArrPreviousTimeFrameQuotesV10.length >= numValues ){
				volume = 0;
				
				for(var i = numValues-1; i >= 0; i--){  //We iterate on each value of the previuos timeframe array (es: id m5, previous array is m1. In this case we iterate on the previous 5 values)
					var tmpArrSingleQuote = tmpArrPreviousTimeFrameQuotesV10[tmpArrPreviousTimeFrameQuotesV10.length-1-i].split(',');
					volume = volume + parseInt(tmpArrSingleQuote[4]);
				}
			}else{
				if (cross == 'EURUSD') {
					//console.log('Error on timeframe '+timeFrame+', cross '+ cross+' tmpArrPreviousTimeFrameQuotesV10 :'+JSON.stringify(tmpArrPreviousTimeFrameQuotesV10) );
				}
			}

		}

		//11313,11315,11313,11316,30,03/18/2016 01:24  -->   apertura,massimo,minimo,chiusura,volume,time
		var newQuote =  open+','+max+','+min+','+close+','+volume+','+datetime;

		if (timeFrame == 'm1' || timeFrame == 'm30' || timeFrame == 'm15'){ 
			if( cross == 'EURUSD' ) {
				//console.log('Creating new quote - Cross:'+cross+' timeframe:'+timeFrame+' newQuote:'+newQuote);
				//console.log('Resetting values for cross '+cross+' timeframe '+timeFrame+' : '+JSON.stringify(runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]) );
			}
		};

		//Resetting runningProviderRealTimeObjs[tmpRealTimeQuoteProperty] for the this specific cross
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['open'] = null
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['max'] = null;
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['min'] = null;
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['close'] = null;
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['volume'] = 0;

		return newQuote;
	};

	

	var _updateTimeFrameQuotesObj = function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj,tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty){
                                   //(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		if (timeFrame == null || timeFrame == undefined || timeFrameQuotesObj == null || timeFrameQuotesObj == undefined || realTimeQuotesObj == null || realTimeQuotesObj == undefined ) {
			console.log('In _updateTimeFrameQuotesObj timeframe or timeFrameQuotesObj or realTimeQuotesObj is notDefined/null');
			return null;
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
			if (realTimeQuotesObj[key0] != ""){
		  		if (realTimeQuotesObj.hasOwnProperty(key0)) {
		  			for (var key1 in timeFrameQuotesObj) {
		  				if (realTimeQuotesObj.hasOwnProperty(key1)) {
		  					if (key0 == key1 && key0 != "provider" && key0 != "description") {

		  						//console.log("TIMEFRAME TO UPDATE: "+timeFrame);
								
	  							//AND WE CLEAN THE REAL TIME ARRAY OBJ. THIS RRAY STORE THE LAST REALTIME VALUES INTO ON1 MINUTE
			  						var newQuote = _createNewQuote(tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty,key0,timeFrame);

			  						var tmpNewQuote = newQuote.split(',');
			  						if ( tmpNewQuote[0] != null && tmpNewQuote[1] != null && tmpNewQuote[2] != null && tmpNewQuote[3] != null && tmpNewQuote[0] != 'null' && tmpNewQuote[1] != 'null' && tmpNewQuote[2] != 'null' && tmpNewQuote[3] != 'null') {
				  						//for (var j = 0; j <= timeFrameQuotesObj[key1][index][timeFrame].length - 1; j++) {
				  							tempObj = timeFrameQuotesObj[key1][index][timeFrame][0];

					  						if (tempObj[Object.keys(tempObj)[0]].length < Object.keys(tempObj)[0].split("v")[1] ){
		
					  							if (realTimeQuotesObj[key0] != "" && realTimeQuotesObj[key0] != null && realTimeQuotesObj[key0] != undefined ) {
					  								//key0 is the cross (es: EURUSD) and its used like second "search key" in the global runningProviderRealTimeObjs
					  								//realTimeQuotesObj[key0] is the array with the last 60 seconds realtime quotes
					  								//tmpRealTimeQuoteProperty is the first "search key" used in the global runningProviderRealTimeObjs (es: REALTIMEQUOTE$MT4$ACTIVTRADES)
					  								//tmpTimeFrameQuoteProperty is the first "search key" used in the global runningProviderTimeFrameObjs (es: TIMEFRAMEQUOTE$MT4$ACTIVTRADES)
					  								//timeframe is the value used to specify the type of timeframe (ex: m1,m5,m15,..). Its used also like 
					  								
					  								//Example of research in runningProviderTimeFrameObjs: runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][key0][index0][timeFrame][index1]	--> return one array of values
					  								//Example of research in runningProviderRealTimeObjs: runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][key0] --> return one array of values	
					  								
					  								tempObj[Object.keys(tempObj)[0]].push( newQuote );	

					  								/*
					  								//console.log.trace('Updated timeFrameQuotesObj(operation:adding) : ' + tempObj[Object.keys(tempObj)[0]].toString() + ' for TimeFrame: '+timeFrame+ ' for number of values: '+Object.keys(tempObj)[0]+' on Cross: '+key1 );
					  								var topic = key1;
					  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					  								var topicToSignalProvider = timeFrameQuotesObj.provider+"@"+key1+"@"+timeFrame+"@"+Object.keys(tempObj)[0];
					  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
														console.log.error('timeFrameQuotesObjProvider: ' +JSON.stringify(timeFrameQuotesObj.provider) + ' key1: ' + key1 + ' timeFrame: ' +timeFrame + ' totValues: ' + JSON.stringify( Object.keys(tempObj)[0] ) + ' In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
													}else if (tempObj[Object.keys(tempObj)[0]].toString() == null || tempObj[Object.keys(tempObj)[0]].toString() == undefined ) {
														console.log.error('objWithMessageToSend: '+ JSON.stringify(tempObj) + ' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
													}else{
					  									sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									testSockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									if (timeFrame == 'm5' && Object.keys(tempObj)[0].split("v")[1] == '1') {
															console.log.info('Sent new timeFrame value message (ex: logs only for m5 and v1): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}else if (timeFrame == 'm30' && Object.keys(tempObj)[0].split("v")[1] == '5') {
															console.log.info('Sent new timeFrame value message (ex: logs only for m30 and v5): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}
					  								}*/
					  							}else{
					  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
													//	console.log.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
													//};
					  							}
					  						}else{
		
				  								if (realTimeQuotesObj[key0] != "" && realTimeQuotesObj[key0] != null && realTimeQuotesObj[key0] != undefined) {
		
					  								//tempObj[Object.keys(tempObj)[0]].shift();
					  								
					  								tempObj[Object.keys(tempObj)[0]].push(newQuote);

					  								/*
					  								//console.log.trace('Updated timeFrameQuotesObj(operation:shifting) : ' + tempObj[Object.keys(tempObj)[0]].toString() + 'for TimeFrame: '+timeFrame+ ' for number of values: '+Object.keys(tempObj)[0]+' for Cross: '+key1 );
					  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v10 
					  								var topicToSignalProvider = timeFrameQuotesObj.provider+"@"+key1+"@"+timeFrame+"@"+Object.keys(tempObj)[0];
					  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
														console.log.error('timeFrameQuotesObjProvider: '+ JSON.stringify(timeFrameQuotesObj.provider) + ' key1: ' + key1 + ' timeFrame: '+ timeFrame + 'totValues: ' + JSON.stringify(Object.keys(tempObj)[0]) +' In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
													}else if (tempObj[Object.keys(tempObj)[0]].toString() == null || tempObj[Object.keys(tempObj)[0]].toString() == undefined ) {
														console.log.error('objWithMessageToSend: ' + JSON.stringify(tempObj) + ' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
													}else{
					  									sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									testSockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									if (timeFrame == 'm5' && Object.keys(tempObj)[0].split("v")[1] == '1') {
					  										console.log.info('Sent new timeFrame value message (logs only for m5 and v1): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}else if (timeFrame == 'm30' && Object.keys(tempObj)[0].split("v")[1] == '5') {
															console.log.info('Sent new timeFrame value message (ex: logs only for m30 and v5): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}
					  								}*/
					  							}else{
					  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
													//	console.log.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
													//};
					  							}
					  						}
					  						timeFrameQuotesObj[key1][index][timeFrame][0] = tempObj;
				  						//}
				  					}
			  					
		  						//uncomment this file if you want to check how are stored the quotes values
		  						//console.log.trace('Updated timeFrameQuotesObj[key1][index][timeFrame]: ' + JSON.stringify(timeFrameQuotesObj[key1][index][timeFrame] ) +  ' TimeFrame Obj Updated');
		  						//console.log("timeFrameQuotesObj[key1][index][timeFrame]: ",timeFrameQuotesObj[key1][index][timeFrame]);
		  					}	
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
    	createOneMinuteOpenObj: function(quotes_list,providerName){ 
    		return _createOneMinuteOpenObj(quotes_list,providerName)
    	},
    	createRealTimeQuotesObj:  function(quotes_list,providerName){ 
      		return _createRealTimeQuotesObj(quotes_list,providerName);  
    	},
    	updateTimeFrameQuotesObj: function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj,tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty){
    		return _updateTimeFrameQuotesObj(timeFrame,timeFrameQuotesObj,realTimeQuotesObj,tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
    	},
    	updateRealTimeQuotesObj: function(searchObjRealTimeQuote,messageArr){
    		return _updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);
    	},
    	importHistoryTimeFrameQuotesObj: function(searchObjTimeFrameQuote,messageArr){
    		return _importHistoryTimeFrameQuotesObj(searchObjTimeFrameQuote,messageArr);
    	}
    }
    
})();

// TO CHANGE

var configQuotesList = {
    "quotes":[
    	{"value":"AUDNZD"},{"value":"AUDCAD"},{"value":"AUDCHF"},{"value":"AUDJPY"},{"value":"AUDUSD"},{"value":"CADJPY"},{"value":"CADCHF"},{"value":"CHFJPY"},{"value":"EURUSD"},{"value":"EURGBP"},{"value":"EURAUD"},{"value":"EURCHF"},{"value":"EURJPY"},{"value":"EURNZD"},{"value":"EURCAD"},{"value":"GBPUSD"},{"value":"GBPCHF"},{"value":"GBPJPY"},{"value":"GBPAUD"},{"value":"GBPCAD"},{"value":"NZDJPY"},{"value":"NZDUSD"},{"value":"USDCHF"},{"value":"USDCAD"},{"value":"USDJPY"},{"value":"USDCHF"}
    ]
}




/*   EURGBP_2016-01-21_2016-05-17
52.33.13.29   trader abc123
2016.01.21,13:47,0.77152,0.77166,0.77142,0.77166,254
time open high lowclose volume
*/

var CSVToArray = function( strData, strDelimiter ){
	// This will parse a delimited string into an array of
    // arrays. The default delimiter is the comma, but this
    // can be overriden in the second argument.

    // Check to see if the delimiter is defined. If not,
    // then default to comma.
    strDelimiter = (strDelimiter || ",");
    // Create a regular expression to parse the CSV values.
    var objPattern = new RegExp(
        (
            // Delimiters.
            "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +
            // Quoted fields.
            "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +
            // Standard fields.
            "([^\"\\" + strDelimiter + "\\r\\n]*))"
        ),
        "gi"
        );
    // Create an array to hold our data. Give the array
    // a default empty first row.
    var arrData = [[]];
    // Create an array to hold our individual pattern
    // matching groups.
    var arrMatches = null;
    // Keep looping over the regular expression matches
    // until we can no longer find a match.
    while (arrMatches = objPattern.exec( strData )){
        // Get the delimiter that was found.
        var strMatchedDelimiter = arrMatches[ 1 ];
        // Check to see if the given delimiter has a length
        // (is not the start of string) and if it matches
        // field delimiter. If id does not, then we know
        // that this delimiter is a row delimiter.
        if (
            strMatchedDelimiter.length &&
            (strMatchedDelimiter != strDelimiter)
            ){
            // Since we have reached a new row of data,
            // add an empty row to our data array.
            arrData.push( [] );
        }
        // Now that we have our delimiter out of the way,
        // let's check to see which kind of value we
        // captured (quoted or unquoted).
        if (arrMatches[ 2 ]){
            // We found a quoted value. When we capture
            // this value, unescape any double quotes.
            var strMatchedValue = arrMatches[ 2 ].replace(
                new RegExp( "\"\"", "g" ),
                "\""
                );
        } else {
            // We found a non-quoted value.
            var strMatchedValue = arrMatches[ 3 ];
        }
        // Now that we have our value string, let's add
        // it to the data array.
        arrData[ arrData.length - 1 ].push( strMatchedValue );
    }
    // Return the parsed data.
    return( arrData );
}

var startToSendQuote = true;
var newObjTimeFrameQuote = "";
var newObjRealTimeQuote = "";
var newValuePropertyTimeFrameQuote = "";
var newValuePropertyRealTimeQuote = ""; 
var tmpTimeFrameQuoteProperty = "";
var tmpRealTimeQuoteProperty = "";
var searchObjRealTimeQuote = ""; 

var runningProviderTimeFrameObjs = {};
var runningProviderRealTimeObjs = {};

var platform = "";
var brokerName = "";
//EX Setting: {cross:'EURUSD','dataLenght':'v1'},{cross:'EURGBP','dataLenght':'v10'}
var setting = [];
var indexQuote = 1;


var updateTimeFrameObjLocal = function(messageArr,i){

	//console.log("updateRealTimeQuotesObj messageArr: ",messageArr);
	var result = QuotesModule.updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);

	var timeFrameToUpdate = 'm1';   //m1,m5,m15,m30,h1,h4,d1,w1
	var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
	runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;

	//console.log("iteration: "+i);
	if ( (i%5) == 0 ) {
		//console.log("iteration in 5: "+i);
		timeFrameToUpdate = 'm5';   //m1,m5,m15,m30,h1,h4,d1,w1
		new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	if ( (i%15) == 0 ) {
		timeFrameToUpdate = 'm15';   //m1,m5,m15,m30,h1,h4,d1,w1
		new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	if ( (i%30) == 0 ) {
		timeFrameToUpdate = 'm30';   //m1,m5,m15,m30,h1,h4,d1,w1
		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	if ( (i%60) == 0) { 
		timeFrameToUpdate = 'h1';   //m1,m5,m15,m30,h1,h4,d1,w1
		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	if ( (i%240) == 0 ) {
		timeFrameToUpdate = 'h4';   //m1,m5,m15,m30,h1,h4,d1,w1
		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	if ( (i%1440) == 0 ) {
		timeFrameToUpdate = 'd1';   //m1,m5,m15,m30,h1,h4,d1,w1
		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	if ( (i%7200) == 0 ) {
		timeFrameToUpdate = 'w1';   //m1,m5,m15,m30,h1,h4,d1,w1
		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
	};
	return true;
}

var searchHistoryQuoteInDb = function(platform,source,cross,fromBacktest,toBacktest){

	console.log('platform,source,cross,from,to: '+platform+' '+source+' '+cross+''+fromBacktest+' '+fromBacktest);

	var iteration = 0;
	var messageArr = [];
	var fromNumber = new Date(fromBacktest);
	var toNumber = new Date(toBacktest);
	var currentDate = '';
	var messageArr = [];
	var propQuote = cross+'_m1';
	var transaction = db.transaction([propQuote], "readonly");
	var objectStore = transaction.objectStore(propQuote);
	var request = objectStore.openCursor();
	 
	request.onsuccess = function(e) {
	    var cursor = e.target.result;
	    if(cursor) {
	    	if (request.result.value != undefined) {
		    	//console.log("e.target: ",e.target);
		        //console.log("Key", cursor.key);
		        //console.dir("Data", cursor.value);
		        //console.log("request.result.value: ",request.result.value);

		        //var row = {source:source, platform:platform, date:date, time:time, open:open, high:high, low:low, close:close, volume:volume};

		        currentDate = new Date(request.result.value.date+' '+request.result.value.time);
		        //console.log("currentDate: ",currentDate+" fromNumber: "+fromNumber+" "+" toNumber: "+toNumber);
		        if ( request.result.value.source == source && request.result.value.platform == platform && currentDate >= fromNumber && currentDate <= toNumber ) {
		        	console.log("request.result.value.date: "+request.result.value.date);
		        	iteration++;
		        	dateTime = request.result.value.date+' '+request.result.value.time;
		        	messageArr = [cross,request.result.value.open,request.result.value.high,request.result.value.low,request.result.value.close,request.result.value.volume,dateTime];
		        	var res = updateTimeFrameObjLocal(messageArr,iteration);
		        	
		        }
			}
			cursor.continue();
	    }else{
			console.log("end cursor");
			console.log("runningProviderTimeFrameObjs: ",runningProviderTimeFrameObjs);
		}
	}
}


var sortArr = function(cardsArr) {
    //Sorted cards are sorted by suit: Clubs, Spades, Hearts, Diamonds; then by value: Ace is high.
    if( cardsArr.length > 1 ){
      return cardsArr.sort(_orderByProperty('date', 'time'));
    }else{
      return cardsArr;
    }
  }; 

var orderByProperty = function(prop) {
	var args = Array.prototype.slice.call(arguments, 1);
	return function (a, b) {
	  var equality = b[prop] - a[prop];
	  if (equality === 0 && arguments.length > 1) {
	    return _orderByProperty.apply(null, args)(a, b);
	  }
	  return equality;
	};
};



self.addEventListener('message',  function(event){
	console.log("message: ",event);
	//EX: {cross:cross_list[i].cross,history_quotes:store_history_in_memory,from:from,to:to,dataLenght:cross_list[i].dataLenght}

	if (event.data.type == 'initialAlgoSetting') {

		platform = event.data.platform;
		brokerName = event.data.brokerName;

		newObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+platform+"$"+brokerName;
		newObjRealTimeQuote = "REALTIMEQUOTE$"+platform+"$"+brokerName;
		newValuePropertyTimeFrameQuote = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName;
		newValuePropertyRealTimeQuote = "REALTIMEQUOTE@"+platform+"@"+brokerName;  
		runningProviderTimeFrameObjs[newObjTimeFrameQuote] = QuotesModule.createTimeFrameQuotesObj(configQuotesList,newValuePropertyTimeFrameQuote);
		runningProviderRealTimeObjs[newObjRealTimeQuote] = QuotesModule.createRealTimeQuotesObj(configQuotesList,newValuePropertyRealTimeQuote);
		tmpTimeFrameQuoteProperty = "TIMEFRAMEQUOTE$"+platform+"$"+brokerName;
		tmpRealTimeQuoteProperty = "REALTIMEQUOTE$"+platform+"$"+brokerName;
		searchObjRealTimeQuote = "REALTIMEQUOTE$"+platform+"$"+brokerName;

	}else if (event.data.type == 'initialHistoryQuotes') {


		var uploadDB = function(newHistoryArr,platform,source,cross,from,to,fromBacktest,toBacktest){

			console.log("newHistoryArr: ",newHistoryArr);

			var propQuote = cross+'_m1';
			var objectStore = db.transaction([propQuote], "readwrite").objectStore(propQuote);
            
            console.log("newHistoryArr.length: ",newHistoryArr.length);
            var rowUploaded = 0;
            var rowIndexDb = 0;
            
            var addRowInDb = function(row){
            	if ( row != undefined ) {
            		console.log("newHistoryArr[i]: "+row.date);
	                var request = objectStore.put(  row, rowIndexDb );
	                
	                request.onsuccess = function(event) {
	                	rowUploaded++;
	                	//console.log("data uploaded in db");
	                	newHistoryArr.shift();
	                	rowIndexDb++;
	                	if ( newHistoryArr.length == 0 ) {
	                		console.log("finished to upload data in db");
	                		//console.log("newHistoryArr.length: ",newHistoryArr.length);
	                		searchHistoryQuoteInDb(platform,source,cross,fromBacktest,toBacktest);
	                	}else{
	                		addRowInDb( newHistoryArr[0] );
	                	}
	                }
	            }
            }

            addRowInDb(newHistoryArr[0]);

            /*for(var i=newHistoryArr.length-1 ;i>=0; i--){
            //for(var i=0; i<=newHistoryArr.length-1; i++){
            	//console.log("newHistoryArr[i].date: "+newHistoryArr[i].date);
            	if ( newHistoryArr[i] != undefined ) {
            		console.log("newHistoryArr[i]: "+newHistoryArr[i].date);
	                var request = objectStore.put(  newHistoryArr[i], rowIndexDb );
	                rowIndexDb++;
	                request.onsuccess = function(event) {
	                	rowUploaded++;
	                	console.log("data uploaded in db");
	                	if ( rowUploaded == newHistoryArr.length ) {
	                		console.log("finished to upload data in db");
	                		//console.log("newHistoryArr.length: ",newHistoryArr.length);
	                		searchHistoryQuoteInDb(platform,source,cross,fromBacktest,toBacktest);
	                	}
	                }
	            }
            }*/
		}



		var createTimeFrameFx = function(platform,source,cross,fromBacktest,toBacktest){

			console.log("fromBacktest : ",fromBacktest);
			console.log("toBacktest : ",toBacktest);

			var matchArrValues = [];
			var history_quote_arr = '';
			var crossName = '';
			var converted = '';

			var propCSV = cross+'_csv';
			var objectStore = db.transaction([propCSV], "readwrite").objectStore(propCSV);
			var request = objectStore.openCursor();
			request.onsuccess = function(event) {

				console.log("event: ",event);
				var cursor = event.target.result;

				if (cursor) {
					console.log("matchArrValues: "+JSON.stringify(request.result.value) );
					console.log("source: "+source);
					console.log("platform: "+platform);
					console.log("sourcedb: "+request.result.value.source);
					console.log("platformdb: "+request.result.value.platform);
					if (request.result.value.source == source && request.result.value.platform == platform ) {

		  				console.log("source name is " , event.target.source.name);
		  				console.log("platform name is " , event.target.result.value.platform);
					
						crossName = event.target.source.name.split("_")[0];

						source = event.target.result.value.source;
						platform = event.target.result.value.platform;
						var from = event.target.result.value.from;
						var to = event.target.result.value.to

						console.log("event.target.result.value.converted: ",event.target.result.value.converted);
						if ( event.target.result.value.converted == 0) {




							var propCSV = cross+'_csv';
							var objectStoreUpdate = db.transaction([propCSV], "readwrite").objectStore(propCSV);
							var requestUpdate = objectStore.openCursor();
							requestUpdate.onsuccess = function(ev) {

								console.log("ev: ",ev);
								var cursorUpdate = ev.target.result;

								if (cursorUpdate) {

									resultDb = cursorUpdate.value;
		                            var cursorUpdate2 = ev.target.result;

		                            resultDb.csv = '';
		                            resultDb.converted = 1;
		                            resultDb.from = ev.target.result.value.from;
		                            resultDb.to = ev.target.result.value.to;
		                            var requestUpdate = cursorUpdate2.update(resultDb);

		                            requestUpdate.onsuccess = function(ev) {
		                                console.log("Updated converted value = 1 on DB");
		                                resultDb = null;
		                            }

		                        }
		                    }

                            //PARSE CSV AND CREATE TIMEFRAME BJ 
							history_quote_arr = CSVToArray(event.target.result.value.csv,';');
							console.log("history_quote_arr 2: ",history_quote_arr);
		            		var propCSV = cross+'_m1';
		            		var transaction = db.transaction([propCSV],"readwrite");
							var store = transaction.objectStore(propCSV);
							var index = store;//.index('source','platform');
							// Select only those records where prop1=value1 and prop2=value2
							console.log("source: ",source);
							console.log("platform: ",platform);
							var request1 = index.openCursor();
		            		
		            		var direction = '';
		        			request1.onsuccess = function(event) {
		        				//console.log("event: ",event.target);
		        				//console.log("request1.result: ",request1.result);
		        				var cursor1 = event.target.result;
		        				if (cursor1) {
		        					console.log("matchArrValues: "+request1.result.value.date);
		        					if (request1.result.value != undefined) {
			        					
			        					//console.log("request1: ",request1);
			        					if (request1.result.value.source == source && request1.result.value.platform == platform ) {
			        						//order here before push in array
			        						matchArrValues.push(request1.result.value);	
			        					};
			        				}
							    	cursor1.delete();
							    	cursor1.continue();
							    }else{
							    	console.log("end cursor1, finished to get data from db");
							    	console.log("matchArrValues: ",matchArrValues);

							    	if (matchArrValues.length > 0) {

										var startDateHistory = history_quote_arr[0].toString().split(',')[0];
								    	var startTimeHistory = history_quote_arr[0].toString().split(',')[1];
								    	var endDateHistory = history_quote_arr[history_quote_arr.length-1].toString().split(',')[0];
								    	var endTimeHistory = history_quote_arr[history_quote_arr.length-1].toString().split(',')[1];
								    	var newEndDateTimeHistory = endDateHistory+' '+endTimeHistory;
								    	var newStartDateTimeHistory = startDateHistory+' '+startTimeHistory;
								    	
										var data1 = matchArrValues[0].date+' '+matchArrValues[0].time;
										////////chnage  with new Date
										if ( new Date(data1) > new Date(newEndDateTimeHistory) ) {
											direction = 'prepend';
										}else if ( new Date(data1) < new Date(newStartDateTimeHistory) ) {
											direction = 'append';
										};
										
										if (direction == 'append') {
											////////////////////////////////////////////////////
											console.log("matchArrValues append: "+JSON.stringify(matchArrValues) );
											console.log("history_quote_arr append: "+JSON.stringify(history_quote_arr) );
											var newHistoryArr = appendArr(matchArrValues,history_quote_arr,source,platform);
											matchArrValues = null;
											history_quote_arr = null;
											uploadDB(newHistoryArr,platform,source,cross,from,to,fromBacktest,toBacktest);
											newHistoryArr = null;
											//append data
										}else{
											///////////////////////////////////////////////////
											console.log("matchArrValues append: "+JSON.stringify(matchArrValues) );
											console.log("history_quote_arr append: "+JSON.stringify(history_quote_arr) );
											var newHistoryArr = prependArr(matchArrValues,history_quote_arr,source,platform);
											matchArrValues = null;
											history_quote_arr = null;
											uploadDB(newHistoryArr,platform,source,cross,from,to,fromBacktest,toBacktest);
											newHistoryArr = null;
											//prepend
										}
									}else{
										console.log("matchArrValues: "+JSON.stringify(matchArrValues) );
										console.log("history_quote_arr: "+JSON.stringify(history_quote_arr) );

										var newHistoryArr = appendArr(matchArrValues,history_quote_arr,source,platform);
										//matchArrValues.appendArr(history_quote_arr,source,platform);
										matchArrValues = null;
										history_quote_arr = null;
										uploadDB(newHistoryArr,platform,source,cross,from,to,fromBacktest,toBacktest);
										newHistoryArr = null;
									}
									
							    }
							}


                            

						}else{
							console.log("search in db");
							searchHistoryQuoteInDb(platform,source,cross,fromBacktest,toBacktest);
							//GET FROM DB THE ARRAY QUOTES 'FROM' AND 'TO'
						}
					}else{
						console.log("no right platform and source");
						cursor.continue();
					}
				}else{
					console.log("end cursor");
				}
			};
		}


		//var objectStore = db.createObjectStore('EURUSD_11_01_2015_30_3_2016', {keyPath: "id"});
        //console.log("objectStore: ",objectStore);


        var req = indexedDB.open('forecDatabase', 1);

		req.onsuccess = function (e) {
			db = req.result;
			console.log('successfully opened db');


			console.log("initialHistoryQuotes");
			for(var j=0; j<=event.data.d.length-1; j++){
				//console.log("event.data.d[j].cross: ",event.data.d[j].cross);
				//console.log("dataLenght: ",event.data.d[j].dataLenght);
				setting.push( {'platform':event.data.d[j].platform,'source':event.data.d[j].source,'cross':event.data.d[j].cross,'timeFrame':event.data.d[j].timeFrame,'from':event.data.from,'to':event.data.to,'dataLenght':event.data.d[j].dataLenght} );
				console.log("setting: ",setting);
				console.log("event.data.d[j] plAT: "+event.data.d[j].platform );
				console.log("event.data.d[j] source: "+event.data.d[j].source );
				console.log("event.data.from: ",event.data.d[j].from);
				createTimeFrameFx(event.data.d[j].platform,event.data.d[j].source,event.data.d[j].cross,event.data.d[j].from,event.data.d[j].to);
			}
		  	//self.postMessage('successfully opened db');    
		};
		req.onerror = function(e) {
			console.log('error opened db');
		  	//self.postMessage('error');    
		}
		req.onupgradeneeded = function(event) {
		    console.log("db onupgradeneeded");
		    db = event.target.result;   
		}



		
		console.log('runningProviderTimeFrameObjs["TIMEFRAMEQUOTE$platform$broker"]: ',runningProviderTimeFrameObjs );
	}else if (event.data.type == 'messageFromSignalProvider') {

		console.log('Message from signal provider: ' + event.data.d);
		var data = [];
		Array.prototype.slice.call( event.data.d ).forEach(function(arg) {
	        data.push(arg.toString());
	    });
	  	var topic = data[0];
	  	var message = data[1];
	  	console.log('Received message from Signal Provider: '+message+ 'on topic: '+topic);

	  	switch (topic) {
	  		case "NEWTOPICFROMSIGNALPROVIDER":

	  			if (startToSendQuote == true) {
	  				console.log("START TO SEND QUOTES TO CLIENT..");
	  				startToSendQuote = false;
	  				setTimeout(function(){
	  					console.log("START TO SEND QUOTES TO CLIENT....");
	  					sendNewDataToSignalProvider(1);	
	  				},8000);
	  			};

	  			var newTopic = message.split('@');
	  			if (newTopic[0] == 'OPERATIONS') {
	  				//EX: OPERATIONS@ACTIVTRADES@EURUSD
	  				self.postMessage({'d':message,'type':'subscribe'});
					//sockSubFromSignalProvider.subscribe(message);
	  			}else if (newTopic[0] == 'STATUS'){
	  				//EX: STATUS@EURUSD@111		
	  				self.postMessage({'d':message,'type':'subscribe'});
					//sockSubFromSignalProvider.subscribe(message);
	  			}else if (newTopic[0] == 'SKIP') {
	  				//SKIP@ACTIVTRADES@EURUSD@1002
	  				self.postMessage({'d':message,'type':'subscribe'});
	  			}else{
	  				console.log("error message: ",newTopic)
	  			}
	  			console.log("START TO SEND QUOTES TO CLIENT");
				break;

			case "DELETETOPICQUOTES":
				//EX: OPERATIONS@ACTIVTRADES@EURUSD STATUS@EURUSD@111	
				var deleteTopic = message.split('@');
	  			if (deleteTopic[0] == 'OPERATIONS') {
	  				self.postMessage({'d':message,'type':'unsubscribe'});
					//sockSubFromSignalProvider.unsubscribe( message );
				}else if (deleteTopic[0] == 'STATUS'){
					self.postMessage({'d':message,'type':'unsubscribe'});
					//sockSubFromSignalProvider.unsubscribe( message );
	  			}else{
	  				console.log("error message: ",newTopic[0]);
	  			}
				break;

			default:

			 	//EX: OPERATIONS@ACTIVTRADES@EURUSD@1002
				var topicType = topic.split('@');
	  			if (topicType[0] == 'OPERATIONS') {
	  				console.log('New Operation: '+message+ 'from (on topic): '+topic);
	  				//open    price=11295,lots=1,slippage=1.5,sl=1220,tp=1220,magic=1002,op=-1
	  				//close   price=11279,lots=1,slippage=0.2,ticket=103510387,op=0
	  				var operation = message.split(",");
	  				var cross = topicType[2];

	  				if ( operation[6] != undefined && operation[6] != null && operation[6].split('=')[0]=='op'   ) {
	  					console.log("in open operation");
	  					//open    price=11295,lots=1,slippage=1.5,sl=1220,tp=1220,magic=1002,op=-1

	  					var price_rv = parseFloat(operation[0].split('=')[1]);
		  				var lots_rv = parseFloat(operation[1].split('=')[1]);
		  				var slippage_rv = parseFloat(operation[2].split('=')[1]);
		  				var sl_rv = parseFloat(operation[3].split('=')[1]);
		  				var tp_rv = parseFloat(operation[4].split('=')[1]);
		  				var magic_rv = operation[5].split('=')[1];
		  				var op_rv = parseFloat(operation[6].split('=')[1]);

						var op_id = operation_unique_id;  //generate unique id
						operation_unique_id++;
						var price = price_rv;
						var sl = sl_rv;
						var tp = tp_rv;
						var magic = magic_rv;
						operations.push( {'open':price,'id':op_id,'op':op_rv,'close':'','sl':sl,'tp':tp,'magic':magic} );
						var status_mess = "1,open,"+price+","+op_id;
						var status_topic = "STATUS@"+cross+"@"+magic;
						
						var topicToSend = "STATUS@"+cross+"@"+magic;
						var messageToSend = "1,open,"+price+","+op_id;

						//1,open,11295,103510387 on topic: STATUS@EURUSD@1002
						console.log("sendStatusToSignalProvider topic: ",topicToSend);
						console.log("sendStatusToSignalProvider message: ",messageToSend);
						self.postMessage({'d':[topicToSend, messageToSend],'type':'sendStatusToSignalProvider'});
						//sockPub.send([topic, message]);


					}else if ( operation[4].split('=')[0]=='op' ) {
						console.log("in close operation");
						//close   price=11279,lots=1,slippage=0.2,ticket=103510387,op=0

						var price_rv = parseFloat(operation[0].split('=')[1]);
		  				var lots_rv = parseFloat(operation[1].split('=')[1]);
		  				var slippage_rv = parseFloat(operation[2].split('=')[1]);
		  				var ticket_rv = operation[3].split('=')[1];
		  				var op_rv = parseFloat(operation[4].split('=')[1]);

						var price = price_rv;
						var ticket = ticket_rv;
						for(var i=0; i<=operations.length-1; i++){
							if (operations[i].id == ticket) {

								console.log('OPERATION operations[i].open: ',operations[i].open);
								console.log('OPERATION price: ',price);
								console.log('OPERATION  operations[i].op: ',operations[i].op);

								var operation_result1 = ((operations[i].open - price) * operations[i].op) / 10;
								console.log('OPERATION operation_result1: ',operation_result1);
								var operation_result2 = operation_result1.toFixed(5) * operations[i].op;
								console.log('OPERATION operation_result2: ',operation_result2);
								var operation_result3 = operation_result2 / 10; //IF WE HAVE 5 NUMBERS, IN ORDER TO CALCULATE THE TOTAL OF PIPS WE HAVE Divide FOR 10
								var operation_result = parseFloat((operation_result3 * 1000000));
								operation_result = operation_result.toFixed(0);
								console.log('OPERATION result: ',operation_result);
								var last_operation = parseFloat(tot_backtest_all_operations[tot_backtest_all_operations.length-1]);
								console.log('OPERATION last_operation: ',last_operation);
								if ( tot_backtest_comulative.length > 0) {
									tot_backtest_comulative.push( parseFloat(tot_backtest_comulative[tot_backtest_comulative.length-1]) + parseFloat(operation_result) );  //IF WE HAVE 5 NUMBERS, IN ORDER TO CALCULATE THE TOTAL OF PIPS WE HAVE Divide FOR 10 
								}else{
									tot_backtest_comulative.push( parseFloat(operation_result) );
								}
								console.log('OPERATION tot_backtest_comulative: ',tot_backtest_comulative);
								tot_backtest_all_operations.push( operation_result );

								// TOTAL PROFIT
								total_profit = tot_backtest_comulative[tot_backtest_comulative.length-1];

								// AVERAGE PIPS TRADE
								average_pips_trade = (parseFloat(tot_backtest_comulative[tot_backtest_comulative.length-1]) / tot_backtest_comulative.length).toFixed(0);
								console.log('OPERATION average_pips_trade: ',average_pips_trade);
								// PROFIT&LOSS_PIPS   and   PROFIT&LOSS_TRADES   and   CONSECUTIVE_PROFIT&LOSS_TRADES  and  BEST&WORST_TRADE
								if (parseFloat(operation_result) > 0) {
									profit_trades++;
									console.log('OPERATION profit_trades: ',profit_trades);
									profit = parseFloat(profit) + parseFloat(operation_result);
									console.log('OPERATION profit: ',profit);
									if (parseFloat(last_operation) > 0 || last_operation == undefined) {
										consecutive_profit_trades_arr.push(1);
									}else if (parseFloat(last_operation) < 0 || last_operation == undefined) {
										if (consecutive_profit_trades < consecutive_profit_trades_arr.length) {
											consecutive_profit_trades = consecutive_profit_trades_arr.length;
										}
										consecutive_profit_trades_arr.push(1);
									};
									console.log("OPERATION  operation_result: ", operation_result);
									console.log("OPERATION  best trade: ", best_trade);
									if ( best_trade != null && best_trade != 'null') {
										console.log("OPERATION  best trade != null ");
										if (parseFloat(best_trade) < parseFloat(operation_result)) {
											best_trade = parseFloat(operation_result);
											console.log("OPERATION  best trade: ", best_trade);
										};
									}else{
										best_trade = parseFloat(operation_result);
										console.log("OPERATION  best trade: ", best_trade);
									}
								}else if (parseFloat(operation_result) <= 0) {
									loss_trades++;
									console.log('OPERATION loss_trades: ',loss_trades);
									loss = parseFloat(loss) + parseFloat(operation_result);
									console.log('OPERATION loss: ',loss);
									if (parseFloat(last_operation) < 0 || last_operation == undefined) {
										consecutive_loss_trades_arr.push(1);
									}else if (parseFloat(last_operation) > 0) {
										if (parseFloat(consecutive_loss_trades) < consecutive_loss_trades_arr.length) {
											consecutive_loss_trades = consecutive_loss_trades_arr.length;
										}
										consecutive_loss_trades_arr.push(1);
									};
									if ( worst_trade != null && worst_trade != 'null') {
										if (parseFloat(worst_trade) > parseFloat(operation_result)) {
											worst_trade = parseFloat(operation_result);
										};
									}else{
										worst_trade = parseFloat(operation_result);
									}

								};

								// LONG(BUY) AND SHORT(SELL)
								if (operations[i].op == '1') {
									long_trades++;
									console.log('OPERATION long_trades: ',long_trades);
								}else if (operations[i].op == '-1') {
									short_trades++;
									console.log('OPERATION short_trades: ',short_trades);
								};

								// MAX DRAWDOWN 
								if ( max_drawdown_arr[max_drawdown_arr.length-1] == undefined && max_drawdown_arr[max_drawdown_arr.length-1] == null ){
									max_drawdown_arr.push( 0 );
								}
									
								console.log("OPERATION max_drawdown_arr[0]: ",max_drawdown_arr[0]);
								var first_max_drawdown_arr_value = parseFloat(max_drawdown_arr[0]);
								
								console.log("OPERATION tot_backtest_comulative[tot_backtest_comulative.length-1]: ",tot_backtest_comulative[tot_backtest_comulative.length-1]);
								var current_max_drawdown_arr_value = parseFloat(tot_backtest_comulative[tot_backtest_comulative.length-1]);
								
								console.log("OPERATION first_max_drawdown_arr_value: ",first_max_drawdown_arr_value);
								console.log("OPERATION current_max_drawdown_arr_value: ",current_max_drawdown_arr_value);

								if ( parseFloat(first_max_drawdown_arr_value) >= parseFloat(current_max_drawdown_arr_value)) {
									max_drawdown_arr.push( current_max_drawdown_arr_value );
									console.log("max_drawdown_arr: ",max_drawdown_arr);
									var new_drawdown = parseFloat(max_drawdown_arr.min()) - parseFloat(max_drawdown_arr[0]) ;

									//var new_drawdown_percent = new_drawdown / parseFloat(max_drawdown_arr[0]) * 100;

									console.log("OPERATION max drawdown: ",max_drawdown);
									console.log("OPERATION new drawdown: ",new_drawdown);
									if ( parseFloat(new_drawdown) < parseFloat(max_drawdown) ) {
										console.log("OPERATION new drawdown: ",new_drawdown);
										max_drawdown = new_drawdown;
										max_drawdown_from_zero = parseFloat(max_drawdown_arr.min());
									}

								}else if ( parseFloat(first_max_drawdown_arr_value) < parseFloat(current_max_drawdown_arr_value) ) {
									max_drawdown_arr = [ parseFloat(tot_backtest_comulative[tot_backtest_comulative.length-1]) ];
								};
								

								operations[i].close = price;
								var status_message = "1,close,"+price+","+operations[i].id;
								var status_topic = "STATUS@"+cross+"@"+operations[i].magic;
								
								//1,close,11280,103510387 on topic: STATUS@EURUSD@1002
								self.postMessage({'d':[status_topic, status_message],'type':'sendStatusToSignalProvider'});
								//sockPub.send([status_topic, status_mess]);
							};
						}
						
					};
					//sendNewDataToSignalProvider(indexQuote);
				}else if (topicType[0] == 'SKIP') {
					//EX: SKIP@ACTIVTRADES@EURUSD@1002
					console.log("SKIP message: ",topicType[0] );
					sendNewDataToSignalProvider(indexQuote);
				}
				break;
			

		};
	};
});



// SEND VALUES AT 1 MIN, 5 MIN, ETC.... 

//FOR && .shift();

//[{"v1":[]},{"v5":[]},{"v10":[]},{"v20":[]},{"v40":[]},{"v100":[]}];
var getIndexValuesNumberToSend = function(type){
	switch (type){
		case 'v1':
    		index = 1;
    		break;
		case 'v5':
			index = 6;
			break;
		case 'v10':
			index = 11;
			break;
		case 'v20':
			index = 21;
			break;
		case 'v40':
			index = 41;
			break;
		case 'v100':
			index = 101;
			break;
	}
	return index;	
}

// indexQuote start with 1
var countFinishBackTest = [];
var sendNewDataToSignalProvider = function(indexQuoteInt){
	console.log("indexQuoteInt: "+indexQuoteInt);
	//EX Setting: {cross:'EURUSD','dataLenght':'v1'},{cross:'EURGBP','dataLenght':'v10'}
	var checkM1 = (indexQuoteInt/1).toString().split('.')[1];
	var checkM5 = (indexQuoteInt/5).toString().split('.')[1];
	var checkM15 = (indexQuoteInt/15).toString().split('.')[1];
	var checkM30 = (indexQuoteInt/30).toString().split('.')[1];
	var checkH1 = (indexQuoteInt/60).toString().split('.')[1];
	var checkH4 = (indexQuoteInt/240).toString().split('.')[1];
	var checkD1 = (indexQuoteInt/1440).toString().split('.')[1];
	var checkW1 = (indexQuoteInt/7200).toString().split('.')[1];

	indexQuote++;

	console.log("checkM1: "+ checkM1 );
	//{'cross':event.data.d[j].cross,'dataLenght':event.data.d[j].dataLenght}

	timeFrameArr = [];
	for(var i=0; i<=setting.length-1; i++){
		timeFrameArr.pushUnique(setting[i].cross);
		switch (undefined){
			case checkM1:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'm1') {
						console.log("checkM1..: "+ checkM1 );
			    		var timeFrame = 'm1';
			    		var indexTimeFrame = 0;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght );
			    		console.log("indexDataLenght: ",indexDataLenght);
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined && quote.length >= indexDataLenght) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							console.log("topicToSignalProvider: ",topicToSignalProvider);
							console.log("quotesToSignalProvider: ",quote.join(";") );
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
	    		
			case checkM5:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'm5') {
						var timeFrame = 'm5';
						var indexTimeFrame = 1;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined && quote.length >= indexDataLenght) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
			case checkM15:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'm15') {
						var timeFrame = 'm15';
						var indexTimeFrame = 2;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined && quote.length >= indexDataLenght) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
			case checkM30:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'm30') {
						var timeFrame = 'm30';
						var indexTimeFrame = 3;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined && quote.length >= indexDataLenght) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
			case checkH1:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'h1') {
						var timeFrame = 'h1';
						var indexTimeFrame = 4;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined && quote.length >= indexDataLenght) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
			case checkH4:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'h4') {
						var timeFrame = 'h4';
						var indexTimeFrame = 5;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined && quote.length >= indexDataLenght) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
			case checkD1:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'd1') {
						var timeFrame = 'd1';
						var indexTimeFrame = 6;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
			case checkW1:
				var stringKey = setting[i].cross+setting[i].timeFrame+setting[i].dataLenght;
				if ( countFinishBackTest.indexOf(stringKey) == -1) {
					if (setting[i].timeFrame == 'w1') {
						var timeFrame = 'w1';
						var indexTimeFrame = 7;
			    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
			    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][0]['v1'].slice(0,  indexDataLenght);
						if (quote != null && quote != undefined) {
							//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
							//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
							var topicToSignalProvider = "TIMEFRAMEQUOTE@"+platform+"@"+brokerName+"@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
							self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
							//sockPub.send([topicToSignalProvider, quote.join(";")]);
						}else{
							countFinishBackTest.push(setting[i].cross+setting[i].timeFrame+setting[i].dataLenght);
						}
					}
				}
				
		};	
	};
	if( countFinishBackTest.length == setting.length){
		self.postMessage(
			{'d': 
				{
					'operations':operations, 
					'tot_backtest_comulative': tot_backtest_comulative,
					'tot_backtest_all_operations' : tot_backtest_all_operations,
					'profit' : profit,
					'loss' : loss,
					'profit_trades' : profit_trades,
					'loss_trades' : loss_trades,
					'total_profit' : total_profit,
					'average_pips_trade' : average_pips_trade,
					'consecutive_profit_trades_arr': consecutive_profit_trades_arr,
					'consecutive_loss_trades_arr' : consecutive_loss_trades_arr,
					'consecutive_profit_trades' : consecutive_profit_trades,
					'consecutive_loss_trades' : consecutive_loss_trades,
					'worst_trade': worst_trade,
					'best_trade' : best_trade,
					'long_trades' : long_trades,
					'short_trades' : short_trades,
					'max_drawdown_arr' : max_drawdown_arr,
					'max_drawdown' : max_drawdown,
					'max_drawdown_from_zero' : max_drawdown_from_zero,
					'min_drawdown' : min_drawdown,
					'operation_unique_id' : operation_unique_id 
				},
			'type':'backtestFinished'
			}
		);
	}
	timeFrameArr.forEach(function(el,indexArr){
		var cross = el;
		var timeFrame = ['m1','m5','m15','m30','h1','h4','d1','w1'];
	    timeFrame.forEach(function(el,ind){
	    	runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ cross ][ ind ][ el ][0]['v1'].splice(0, 1);
	    });
	});
}






//STATUS  2016.04.22 07:54:00.246	Subscriber EURUSD,M30: Alert: Message sent: 1,close,11280,103510387 on topic: STATUS@EURUSD@1002
//CLOSE   2016.04.22 07:54:00.051	Subscriber EURUSD,M30: Alert: Message received: price=11279,lots=1,slippage=0.2,ticket=103510387,op=0

//STATUS  2016.04.22 00:30:03.105	Subscriber EURUSD,M30: Alert: Message sent: 1,open,11295,103510387 on topic: STATUS@EURUSD@1002
//OPEN    2016.04.22 00:30:02.894	Subscriber EURUSD,M30: Alert: Message received: price=11295,lots=1,slippage=1.5,sl=1220,tp=1220,magic=1002,op=-1
//Topic: STATUS@EURUSD@1002message: "1,open,11403,105634693\n"

var operations = [];
var tot_backtest_comulative = [];
var tot_backtest_all_operations = [];
var profit = 0;
var loss = 0;
var profit_trades = 0;
var loss_trades = 0;
var total_profit = 0;
var average_pips_trade = null;
var consecutive_profit_trades_arr = [];
var consecutive_loss_trades_arr = [];
var consecutive_profit_trades = 0;
var consecutive_loss_trades = 0;
var worst_trade = null;
var best_trade = null;
var long_trades = 0;
var short_trades = 0;
var max_drawdown_arr = [];
var max_drawdown = 0;
var max_drawdown_from_zero = 0;
var min_drawdown = 0;
var operation_unique_id = 1;










//from 53200 to 53300







