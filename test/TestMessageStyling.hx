import utest.Assert.*;
import xmpp.Message;
import xmpp.MessageStyling;

using xmpp.MessageStyling;

class TestMessageStyling extends utest.Test {
	function test_spans() {
		same([Plain("plain")], MessageStyling.parseLine("plain"));
		same([Strong([Plain("strong")])], MessageStyling.parseLine("*strong*"));
		same([Emphasis([Plain("emphasis")])], MessageStyling.parseLine("_emphasis_"));
		same([Strike([Plain("strike")])], MessageStyling.parseLine("~strike~"));
		same([Code("code")], MessageStyling.parseLine("`code`"));
		same([Plain("a "), Strong([Plain("b c")]), Plain(" d")], MessageStyling.parseLine("a *b c* d"));
		same([], MessageStyling.parseLine(""));
	}

	function test_nested() {
		same([Strong([Emphasis([Plain("both")])])], MessageStyling.parseLine("*_both_*"));
		same([Strong([Plain("a "), Emphasis([Plain("b")]), Plain(" c")])], MessageStyling.parseLine("*a _b_ c*"));
		// not within code
		same([Code("*not strong*")], MessageStyling.parseLine("`*not strong*`"));
	}

	function test_not_styled() {
		// https://xmpp.org/extensions/xep-0393.html#rules
		same([Plain("**")], MessageStyling.parseLine("**")); // empty
		same([Plain("* not *")], MessageStyling.parseLine("* not *")); // whitespace after the opening
		same([Plain("*not *")], MessageStyling.parseLine("*not *")); // whitespace before the closing
		same([Plain("2*3*4")], MessageStyling.parseLine("2*3*4")); // not at a word start
		same([Plain("snake_case_names")], MessageStyling.parseLine("snake_case_names"));
		same([Plain("https://example.com/a_b_c")], MessageStyling.parseLine("https://example.com/a_b_c"));
		same([Plain("*unclosed")], MessageStyling.parseLine("*unclosed"));
		// the first closing directive
		same([Strong([Plain("a")]), Plain(" b*")], MessageStyling.parseLine("*a* b*"));
	}

	function test_blocks() {
		same([Line([Plain("a")]), Line([Strong([Plain("b")])])], MessageStyling.parse("a\n*b*"));
		// spans don't span lines
		same([Line([Plain("*a")]), Line([Plain("b*")])], MessageStyling.parse("*a\nb*"));
		same([Line([]), Line([Plain("a")])], MessageStyling.parse("\na"));
	}

	function test_pre() {
		same([Pre("*a*\n> b"), Line([Plain("c")])], MessageStyling.parse("```hint\n*a*\n> b\n```\nc"));
		// to the end of the body
		same([Line([Plain("a")]), Pre("b\nc")], MessageStyling.parse("a\n```\nb\nc"));
		same([Pre("")], MessageStyling.parse("```\n```"));
	}

	function test_quote() {
		same([Quote([Line([Plain("a")]), Line([Strong([Plain("b")])])]), Line([Plain("c")])], MessageStyling.parse("> a\n>*b*\nc"));
		same([Quote([Line([Plain("a")]), Quote([Line([Plain("b")])])])], MessageStyling.parse("> a\n>> b"));
		// a preformatted block ends with the quote
		same([Quote([Pre("a")]), Line([Plain("b")])], MessageStyling.parse("> ```\n> a\nb"));
	}

	function test_plain_text() {
		equals("a b c", MessageStyling.parseLine("*a* _b_ `c`").toPlainText());
	}

	function test_unstyled() {
		final m = new Message("romeo@example.net", "*not strong*");
		isFalse(m.isUnstyled());
		m.unstyled().unstyled();
		equals(1, m.toXML().elements.named("unstyled").length);
		isTrue((m.toString() : Message).isUnstyled());
	}
}
