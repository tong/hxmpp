function main() {
	final r = new utest.Runner();
	r.addCase(new TestXML());
	// r.addCase(new TestXMLSchema());
	r.addCase(new TestJid());
	r.addCase(new TestStanza());
	r.addCase(new TestMessage());
	r.addCase(new TestPresence());
	r.addCase(new TestIQ());
	r.addCase(new TestDataForm());
	r.addCase(new TestResponse());
	r.addCase(new TestStream());
	// r.addCase(new TestURI());
	var report = utest.ui.Report.create(r);
	/*
		var success = true;
		r.onProgress.add(e -> {
			for (a in e.result.assertations) {
			trace(a);
				switch a {
					case Success(pos):
					case Warning(msg):
					case Ignore(reason):
					case _: success = false;
				}
			}
			#if js
			if (js.Browser.supported && e.totals == e.done) {
				untyped js.Browser.window.success = success;
			};
			#end
		});
		//r.onTestStart.add(test -> Sys.println('$test...'));
	 */
	r.run();
}
