chrome.app.runtime.onLaunched.addListener(function(data){
	chrome.app.window.create('app.html',{
		width : 260, height : 400,
		minWidth: 100, minHeight: 100,
		transparentBackground : false,
		frame : 'chrome'
	});
});
