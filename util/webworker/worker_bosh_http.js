onmessage = function(e){
	var d = JSON.parse(e.data);
	var r = new XMLHttpRequest();
	r.open("POST",d.url,true);
	r.onreadystatechange=function(){
		if(r.readyState!=4)
			return;
		var s=r.status;
		if(s!=null&&s>=200&&s<400)
			postMessage(r.responseText);
		else
			postMessage("Http Error #"+r.status);
	}
	r.send(d.data);
};