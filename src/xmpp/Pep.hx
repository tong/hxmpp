package xmpp;

import xmpp.IQ;

/**
	[XEP-0107: User Mood](https://xmpp.org/extensions/xep-0107.html)
**/
@xep(107)
enum abstract Mood(String) from String to String {
	/** Impressed with fear or apprehension; in fear; apprehensive. **/
	var afraid;

	/** Astonished; confounded with fear, surprise or wonder. **/
	var amazed;

	/** Inclined to love; having a propensity to love, or to sexual enjoyment; loving, fond, affectionate, passionate, lustful, sexual, etc. **/
	var amorous;

	/** Displaying or feeling anger, i.e., a strong feeling of displeasure, hostility or antagonism towards someone or something, usually combined with an urge to harm. **/
	var angry;

	/** To be disturbed or irritated, especially by continued or repeated acts. **/
	var annoyed;

	/** Full of anxiety or disquietude; greatly concerned or solicitous, esp. respecting something future or unknown; being in painful suspense. **/
	var anxious;

	/** To be stimulated in one's feelings, especially to be sexually stimulated. **/
	var aroused;

	/** Feeling shame or guilt. **/
	var ashamed;

	/** Suffering from boredom; uninterested, without attention. **/
	var bored;

	/** Strong in the face of fear; courageous. **/
	var brave;

	/** Peaceful, quiet. **/
	var calm;

	/** Taking care or caution; tentative. **/
	var cautious;

	/** Feeling the sensation of coldness, especially to the point of discomfort. **/
	var cold;

	/** Feeling very sure of or positive about something, especially about one's own capabilities. **/
	var confident;

	/** Chaotic, jumbled or muddled. **/
	var confused;

	/** Feeling introspective or thoughtful. **/
	var contemplative;

	/** Pleased at the satisfaction of a want or desire; satisfied. **/
	var contented;

	/** Grouchy, irritable; easily upset. **/
	var cranky;

	/** Feeling out of control; feeling overly excited or enthusiastic. **/
	var crazy;

	/** Feeling original, expressive, or imaginative. **/
	var creative;

	/** Inquisitive; tending to ask questions, investigate, or explore. **/
	var curious;

	/** Feeling sad and dispirited. **/
	var dejected;

	/** Severely despondent and unhappy. **/
	var depressed;

	/** Defeated of expectation or hope; let down. **/
	var disappointed;

	/** Filled with disgust; irritated and out of patience. **/
	var disgusted;

	/** Feeling a sudden or complete loss of courage in the face of trouble or danger. **/
	var dismayed;

	/** Having one's attention diverted; preoccupied. **/
	var distracted;

	/** Having a feeling of shameful discomfort. **/
	var embarrassed;

	/** Feeling pain by the excellence or good fortune of another. **/
	var envious;

	/** Having great enthusiasm. **/
	var excited;

	/** In the mood for flirting. **/
	var flirtatious;

	/** Suffering from frustration; dissatisfied, agitated, or discontented because one is unable to perform an action or fulfill a desire. **/
	var frustrated;

	/** Feeling appreciation or thanks. **/
	var grateful;

	/** Feeling very sad about something, especially something lost; mournful; sorrowful. **/
	var grieving;

	/** Unhappy and irritable. **/
	var grumpy;

	/** Feeling responsible for wrongdoing; feeling blameworthy. **/
	var guilty;

	/** Experiencing the effect of favourable fortune; having the feeling arising from the consciousness of well-being or of enjoyment; enjoying good of any kind, as peace, tranquillity, comfort; contented; joyous. **/
	var happy;

	/** Having a positive feeling, belief, or expectation that something wished for can or will happen. **/
	var hopeful;

	/** Feeling the sensation of heat, especially to the point of discomfort. **/
	var hot;

	/** Having or showing a modest or low estimate of one's own importance; feeling lowered in dignity or importance. **/
	var humbled;

	/** Feeling deprived of dignity or self-respect. **/
	var humiliated;

	/** Having a physical need for food. **/
	var hungry;

	/** Wounded, injured, or pained, whether physically or emotionally. **/
	var hurt;

	/** Favourably affected by something or someone. **/
	var impressed;

	/** Feeling amazement at something or someone; or feeling a combination of fear and reverence. **/
	var in_awe;

	/** Feeling strong affection, care, liking, or attraction. **/
	var in_love;

	/** Showing anger or indignation, especially at something unjust or wrong. **/
	var indignant;

	/** Showing great attention to something or someone; having or showing interest. **/
	var interested;

	/** Under the influence of alcohol; drunk. **/
	var intoxicated;

	/** Feeling as if one cannot be defeated, overcome or denied. **/
	var invincible;

	/** Fearful of being replaced in position or affection. **/
	var jealous;

	/** Feeling isolated, empty, or abandoned. **/
	var lonely;

	/** Unable to find one's way, either physically or emotionally. **/
	var lost;

	/** Feeling as if one will be favored by luck. **/
	var lucky;

	/** Causing or intending to cause intentional harm; bearing ill will towards another; cruel; malicious. **/
	var mean;

	/** Given to sudden or frequent changes of mind or feeling; temperamental. **/
	var moody;

	/** Easily agitated or alarmed; apprehensive or anxious. **/
	var nervous;

	/** Not having a strong mood or emotional state. **/
	var neutral;

	/** Feeling emotionally hurt, displeased, or insulted. **/
	var offended;

	/** Feeling resentful anger caused by an extremely violent or vicious attack, or by an offensive, immoral, or indecent act. **/
	var outraged;

	/** Interested in play; fun, recreational, unserious, lighthearted; joking, silly. **/
	var playful;

	/** Feeling a sense of one's own worth or accomplishment. **/
	var proud;

	/** Having an easy-going mood; not stressed; calm. **/
	var relaxed;

	/** Feeling uplifted because of the removal of stress or discomfort. **/
	var relieved;

	/** Feeling regret or sadness for doing something wrong. **/
	var remorseful;

	/** Without rest; unable to be still or quiet; uneasy; continually moving. **/
	var restless;

	/** Feeling sorrow; sorrowful, mournful. **/
	var sad;

	/** Mocking and ironical. **/
	var sarcastic;

	/** Pleased at the fulfillment of a need or desire. **/
	var satisfied;

	/** Without humor or expression of happiness; grave in manner or disposition; earnest; thoughtful; solemn. **/
	var serious;

	/** Surprised, startled, confused, or taken aback. **/
	var shocked;

	/** Feeling easily frightened or scared; timid; reserved or coy. **/
	var shy;

	/** Feeling in poor health; ill. **/
	var sick;

	/** Feeling the need for sleep. **/
	var sleepy;

	/** Acting without planning; natural; impulsive. **/
	var spontaneous;

	/** Suffering emotional pressure. **/
	var stressed;

	/** Capable of producing great physical force; or, emotionally forceful, able, determined, unyielding. **/
	var strong;

	/** Experiencing a feeling caused by something unexpected. **/
	var surprised;

	/** Showing appreciation or gratitude. **/
	var thankful;

	/** Feeling the need to drink. **/
	var thirsty;

	/** In need of rest or sleep. **/
	var tired;

	/** [Feeling any emotion not defined here.] **/
	var undefined;

	/** Lacking in force or ability, either physical or emotional. **/
	var weak;

	/** Thinking about unpleasant things that have happened or that might happen; feeling afraid and unhappy. **/
	var worried;
}

/**
	[XEP-0108: User Activity](https://xmpp.org/extensions/xep-0108.html)
**/
@xep(108)
enum abstract Activity(String) from String to String {
	var doing_chores = "doing-chores";
	var drinking;
	var eating;
	var exercising;
	var grooming;
	var having_appointment = "having-appointment";
	var inactive;
	var relaxing;
	var talking;
	var traveling;
	var undefined;
	var working;
}

/**
	Information about the music the user is listening to; all fields are optional.

	[XEP-0118: User Tune](https://xmpp.org/extensions/xep-0118.html)
**/
@xep(118)
typedef Tune = {
	/** The artist or performer of the song or piece **/
	var ?artist:String;

	/** The composer of the song or piece **/
	var ?composer:String;

	/** The date of the song or piece **/
	var ?date:String;

	/** The genre of the song or piece **/
	var ?genre:String;

	/** The language of the song or piece **/
	var ?language:String;

	/** The duration of the song or piece in seconds **/
	var ?length:Int;

	/** The lyricist of the song or piece **/
	var ?lyricist:String;

	/** The performer of the song or piece **/
	var ?performer:String;

	/** The user's rating of the song or piece, from 1 (lowest) to 10 (highest) **/
	var ?rating:Int;

	/** The collection (e.g., album) or other source **/
	var ?source:String;

	/** The title of the song or piece **/
	var ?title:String;

	/** A unique identifier for the tune, e.g. the track number within a collection **/
	var ?track:String;

	/** A URI or URL pointing to information about the song, collection, or artist **/
	var ?uri:String;
}

/**
	Geographical location of the user; all fields are optional.

	[XEP-0080: User Location](https://xmpp.org/extensions/xep-0080.html)
**/
@xep(80)
typedef Location = {
	/** Horizontal GPS error in meters **/
	var ?accuracy:Float;

	/** Altitude in meters above or below sea level **/
	var ?alt:Float;

	/** Vertical GPS error in meters **/
	var ?altaccuracy:Float;

	/** A named area such as a campus or neighborhood **/
	var ?area:String;

	/** GPS bearing in decimal degrees relative to true north **/
	var ?bearing:Float;

	/** A specific building on a street or in an area **/
	var ?building:String;

	/** The nation where the user is located **/
	var ?country:String;

	/** The ISO 3166 two-letter country code **/
	var ?countrycode:String;

	/** GPS datum **/
	var ?datum:String;

	/** A natural-language name for or description of the location **/
	var ?description:String;

	/** A particular floor in a building **/
	var ?floor:String;

	/** Latitude in decimal degrees North **/
	var ?lat:Float;

	/** A locality within the administrative region, such as a town or city **/
	var ?locality:String;

	/** Longitude in decimal degrees East **/
	var ?lon:Float;

	/** A code used for postal delivery **/
	var ?postalcode:String;

	/** An administrative region of the nation, such as a state or province **/
	var ?region:String;

	/** An ISO 3166 code for the region **/
	var ?regioncode:String;

	/** A particular room in a building **/
	var ?room:String;

	/** The speed at which the entity is moving, in meters per second **/
	var ?speed:Float;

	/** A thoroughfare within the locality, or a crossing of two thoroughfares **/
	var ?street:String;

	/** A catch-all element that captures any other information about the location **/
	var ?text:String;

	/** UTC timestamp of the moment the reading was taken ([XEP-0082](https://xmpp.org/extensions/xep-0082.html)) **/
	var ?timestamp:String;

	/** The time zone offset from UTC for the location (e.g. `+02:00`) **/
	var ?tzo:String;

	/** A URI or URL pointing to information about the location **/
	var ?uri:String;
}

typedef MoodData = {
	/** The mood, `null` if the user stopped publishing moods **/
	var ?mood:Mood;

	var ?text:String;
}

typedef ActivityData = {
	/** The general activity, `null` if the user stopped publishing activities **/
	var ?activity:Activity;

	/** The specific activity, e.g. `partying` for `relaxing` **/
	var ?specific:String;

	var ?text:String;
}

/**
	Use the publish-subscribe protocol to broadcast state change events associated with an instant messaging and presence account.

	Publish the user mood, activity, tune and location, and parse received ones
	(e.g. from `PubSub.getEvent` items: `Pep.parseTune(item.firstElement)`).
	Publishing `null` tells contacts that the user stopped publishing the information.

	Note: the user's server only sends notifications of contacts' PEP nodes to clients advertising
	`<namespace>+notify` features via entity capabilities ([XEP-0115](https://xmpp.org/extensions/xep-0115.html)).

	[XEP-0163: Personal Eventing Protocol](https://xmpp.org/extensions/xep-0163.html)
**/
@xep(163)
class Pep {
	public static inline var XMLNS_ACTIVITY = "http://jabber.org/protocol/activity";
	public static inline var XMLNS_MOOD = "http://jabber.org/protocol/mood";
	public static inline var XMLNS_TUNE = "http://jabber.org/protocol/tune";
	public static inline var XMLNS_GEOLOC = "http://jabber.org/protocol/geoloc";

	static final TUNE_FIELDS = [
		"artist",
		"composer",
		"date",
		"genre",
		"language",
		"length",
		"lyricist",
		"performer",
		"rating",
		"source",
		"title",
		"track",
		"uri"
	];

	static final LOCATION_FIELDS = [
		"accuracy",
		"alt",
		"altaccuracy",
		"area",
		"bearing",
		"building",
		"country",
		"countrycode",
		"datum",
		"description",
		"floor",
		"lat",
		"locality",
		"lon",
		"postalcode",
		"region",
		"regioncode",
		"room",
		"speed",
		"street",
		"text",
		"timestamp",
		"tzo",
		"uri"
	];

	static final LOCATION_DECIMALS = ["accuracy", "alt", "altaccuracy", "bearing", "lat", "lon", "speed"];

	/**
		Publish the user mood, `null` to stop publishing moods.
	**/
	public static function publishMood(stream:Stream, mood:Null<Mood>, ?text:String, handler:Response<XML>->Void):IQ {
		final xml = XML.create("mood").set("xmlns", XMLNS_MOOD);
		if (mood != null) {
			xml.append(XML.create(mood));
			if (text != null)
				xml.append(XML.create("text", text));
		}
		return publish(stream, XMLNS_MOOD, xml, handler);
	}

	/**
		Publish the user activity with optional `specific` activity, `null` to stop publishing activities.
	**/
	public static function publishActivity(stream:Stream, activity:Null<Activity>, ?specific:String, ?text:String, handler:Response<XML>->Void):IQ {
		final xml = XML.create("activity").set("xmlns", XMLNS_ACTIVITY);
		if (activity != null) {
			final general = XML.create(activity);
			if (specific != null)
				general.append(XML.create(specific));
			xml.append(general);
			if (text != null)
				xml.append(XML.create("text", text));
		}
		return publish(stream, XMLNS_ACTIVITY, xml, handler);
	}

	/**
		Publish the tune the user is listening to, `null` to stop publishing tunes.
	**/
	public static function publishTune(stream:Stream, tune:Null<Tune>, handler:Response<XML>->Void):IQ {
		final xml = XML.create("tune").set("xmlns", XMLNS_TUNE);
		if (tune != null)
			appendFields(xml, tune, TUNE_FIELDS);
		return publish(stream, XMLNS_TUNE, xml, handler);
	}

	/**
		Publish the user location, `null` to stop publishing the location.
	**/
	public static function publishLocation(stream:Stream, location:Null<Location>, handler:Response<XML>->Void):IQ {
		final xml = XML.create("geoloc").set("xmlns", XMLNS_GEOLOC);
		if (location != null)
			appendFields(xml, location, LOCATION_FIELDS);
		return publish(stream, XMLNS_GEOLOC, xml, handler);
	}

	/**
		Parses a `<mood/>` element; `mood` is `null` if the user stopped publishing moods.
	**/
	@:noUsing
	public static function parseMood(xml:XML):MoodData {
		final r:MoodData = {};
		for (e in xml.elements)
			if (e.name == "text")
				r.text = e.text;
			else if (r.mood == null)
				r.mood = e.name;
		return r;
	}

	/**
		Parses an `<activity/>` element; `activity` is `null` if the user stopped publishing activities.
	**/
	@:noUsing
	public static function parseActivity(xml:XML):ActivityData {
		final r:ActivityData = {};
		for (e in xml.elements)
			if (e.name == "text")
				r.text = e.text;
			else if (r.activity == null) {
				r.activity = e.name;
				final specific = e.firstElement;
				if (specific != null)
					r.specific = specific.name;
			}
		return r;
	}

	/**
		Parses a `<tune/>` element; an empty tune means the user stopped publishing tunes.
	**/
	@:noUsing
	public static function parseTune(xml:XML):Tune {
		final tune:Tune = {};
		for (e in xml.elements) {
			final text:String = e.text;
			if (text == null)
				continue;
			switch e.name {
				case "length":
					tune.length = Std.parseInt(text);
				case "rating":
					tune.rating = Std.parseInt(text);
				case name if (TUNE_FIELDS.contains(name)):
					Reflect.setField(tune, name, text);
				case _:
			}
		}
		return tune;
	}

	/**
		Parses a `<geoloc/>` element; an empty location means the user stopped publishing the location.
	**/
	@:noUsing
	public static function parseLocation(xml:XML):Location {
		final location:Location = {};
		for (e in xml.elements) {
			final text:String = e.text;
			if (text == null || !LOCATION_FIELDS.contains(e.name))
				continue;
			if (LOCATION_DECIMALS.contains(e.name)) {
				final v = Std.parseFloat(text);
				if (!Math.isNaN(v))
					Reflect.setField(location, e.name, v);
			} else
				Reflect.setField(location, e.name, text);
		}
		return location;
	}

	static function appendFields(xml:XML, data:Dynamic, fields:Array<String>) {
		for (f in fields) {
			final v = Reflect.field(data, f);
			if (v != null)
				xml.append(XML.create(f, Std.string(v)));
		}
	}

	static function publish(stream:Stream, node:String, payload:XML, handler:Response<XML>->Void):IQ {
		return stream.set(Payload.create(PubSub.XMLNS, "pubsub").append(XML.create("publish").set("node", node).append(XML.create("item").append(payload))),
			handler);
	}
}
