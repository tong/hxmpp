package jabber.error;

class Error {
	
	#if (neko||php||cpp||nodejs||rhino)
	public static var color = 31;
	#end
	
	var __desc : String;
	var __infos : haxe.PosInfos;
	var __calls : String;

	public function new( desc : String, ?info : haxe.PosInfos ) {
		__desc = desc;
		__infos = info;
		#if debug
		var cs = haxe.Stack.callStack();
		__calls = haxe.Stack.toString( cs );
		#else
		__calls = "Call stack available in debug mode only";
		#end
	}
	
	public inline function getMessage() : String {
		return __desc;
	}
	
	public function getSource() : String {
		var s  = "class: "+__infos.className+" | file: "+__infos.fileName+"\n";
		s += "method: "+__infos.methodName+" | line: "+__infos.lineNumber;
		return s;
	}
	
	#if debug

	public function getStack() : String {
		var s = "Exception stack available in debug mode only.";
		#if debug
		var es = haxe.Stack.exceptionStack();
		if( es.length > 0 ) {
			s = "========== STACK ==========";
			s += haxe.Stack.toString( es );
		}
		#end
		return s;
	}
	
	public function getCallStack() : String {
		return "========== CALLSTACK =========="+__calls;
	}
	
	#end
	
	public function toString() : String {
		var s = "\n\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n";
		s += getMessage()+"\n"+getSource();
		#if debug
		s += "\n"+getStack();
		s += "\n"+getCallStack();
		#end
		s += "\n";
		#if (neko||php||cpp||nodejs||rhino)
		s = "\033["+color+"m"+s+"\033[m";
		#end
		return s;
	}
	
}
