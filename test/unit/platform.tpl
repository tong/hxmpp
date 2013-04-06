<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8">
<style>
* {
	margin:0; padding:0;
}
html, body {
	width: 100%;
	height:100%;
}
body {
	font-family : sans;
	font-size: 9px;
}
header {
	padding: 2px 5px 2px 2px;
	background: ::color::;
	color: black;
}
#platform {
	text-transform: uppercase;
}
#time {
	margin-left: 3px;
}
#result {
	padding: 0px 5px 5px 2px;
	background: ::color::;
}
</style>

</head>
<body>
<div id="haxe:trace"></div>
<header>
	<strong id="platform">::platform::</strong><span id="time">::time::ms</span>
</header>
<div id="result">::result::</div>
::if js::<script src="test.js"></script>::end::
</body>
</html>
