var casper = require('casper').create();

var createSnapShoot = function(){
	// set the viewport size to include all our page content.
	casper.options.viewportSize = {width: 1920, height: 1080};
	//casper.test.begin("test", function(test) {
	  // step 1: open the page.
	  
	  casper.start("http://52.88.34.166:9801/#/report", function() {
	    // do an example test.
	    //test.assertTitle("snapShoot");
	  });
	  // step 2: take some screenshots.
	  casper.then(function() {
	    casper.wait(5000, function() {
	    	// capture the entire page.
	    	//casper.capture("page.png");
	    	// capture the nav element.
	    	casper.captureSelector("lastOperations.png", ".table-responsive");
		});
	    
	  });
	  // actually run the steps we defined before.
	  casper.run(function() {
	    test.done();
	  });
	//});
};
createSnapShoot();