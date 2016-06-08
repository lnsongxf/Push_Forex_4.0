module.exports = function (app) {

    var Q = require('q');
    var request = require('request');
    var http = require('http');

    // api ---------------------------------------------------------------------
    // get all todos
    app.get('/api/todos', function (req, res) {
        // use mongoose to get all todos in the database
        //getTodos(res);
    });

    // create todo and send back all todos after creation
    app.post('/api/todos', function (req, res) {

        // create a todo, information comes from AJAX request from Angular
        //req.body.text,

    });




    app.post('/proxy', function(req, res) {  
        console.log("in ajax call: ",req.body);
        console.log("in ajax call: ",req.headers);

        RestApiNodeToBE.proxy(req.body.urlData,req.body.method).then(function (dataInit){
            console.log("data Init: ",dataInit);
            res.statusCode = 200;
            res.setHeader("Content-Type", "application/json");
            res.end(JSON.stringify({data:dataInit}));
        });

    });


    var RestApiNodeToBE = (function(){

        var _proxy = function(urlData,param){
            var deferred = Q.defer();
            console.log("in proxy");

            var options = {
                host: "52.88.34.166",
                port: "9091",
                path: "/history/csv",
                method: "GET"
            };
            http.request(options, function(res) {
                console.log('STATUS 2: ' + res.statusCode);
                console.log('HEADERS 2: ' + JSON.stringify(res.headers));
                res.setEncoding('utf8');
            if (res.statusCode == 200) {
                var result = "";
                res.on('data', function (chunk) {
                    console.log('BODY: ' + chunk);
                    result += chunk; 
                });
                res.on('end', function() {
                    console.log('No more data in response.');
                    deferred.resolve( { status:res.statusCode,cookie:"",data:result } );
                });
            }else{
                deferred.resolve( { status:res.statusCode,cookie:"",data:"" } );
            }
        }).end();
            return deferred.promise;
        }


      return{
        proxy: function(urlData,param){
          return _proxy(urlData,param);
        }
      };

    })();




    // application -------------------------------------------------------------
    app.get('*', function (req, res) {
        res.sendFile(__dirname + '/public/index.html'); // load the single view file (angular will handle the page changes on the front-end)
    });
};