package error;


/**
	Basic exception.
*/
class Exception {
	
	var __description : String;
	var __infos : haxe.PosInfos;
	var __calls : String;
	

	public function new( desc : String, ?info : haxe.PosInfos ) {
		
		__description = desc;
		__infos = info;
		
		#if debug
		var cs = haxe.Stack.callStack();
		__calls = haxe.Stack.toString( cs );
		#else
		__calls = "Call stack available in debug mode only";
		#end
	}
	
	
	public function getMessage() : String {
		return __description;
	}
	
	public function getSource() : String {
		var s  = "file: "+__infos.fileName+" | class: "+__infos.className+"\n";
		s += "method: "+__infos.methodName+" | line: "+__infos.lineNumber;
		return s;
	}
	
	#if debug
	
	public function getStack() : String {
		var s = "Exception stack available in debug mode only.";
		#if debug
		var es = haxe.Stack.exceptionStack();
		s = "===== STACK =====";
		s += haxe.Stack.toString( es );
		#end
		return s;
	}
	
	public function getCallStack() : String {
		return "===== CALLSTACK ====="+__calls;
	}
	
	#end
	
	public function toString() : String {
		var s = "\n\n###################################################################\n";
		s += getMessage() + "\n" + getSource();
		#if debug
		s += "\n" + getStack();
		s += "\n" + getCallStack();
		#end
		s += "\n###################################################################\n";
		return s;
	}
	
	/*
	inline function createDescription( base : String, desc : String ) {
		var d = desc;
		if( desc != null ) d += ": "+desc;
		return d;
	}
	*/
	
}
