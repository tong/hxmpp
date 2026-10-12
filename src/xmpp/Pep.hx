package xmpp;

import xmpp.IQ;

/**
	[XEP-0107: User Mood](https://xmpp.org/extensions/xep-0107.html)
**/
@xep(107)
enum abstract Mood(String) from String to String {
	var afraid;
	var amazed;
	var angry;
	var annoyed;
	var anxious;
	var aroused;
	var ashamed;
	var bored;
	var brave;
	var calm;
	var cold;
	var confused;
	var contented;
	var cranky;
	var curious;
	var depressed;
	var disappointed;
	var disgusted;
	var distracted;
	var embarrassed;
	var excited;
	var flirtatious;
	var frustrated;
	var grumpy;
	var guilty;
	var happy;
	var hot;
	var humbled;
	var humiliated;
	var hungry;
	var hurt;
	var impressed;
	var in_awe;
	var in_love;
	var indignant;
	var interested;
	var intoxicated;
	var invincible;
	var jealous;
	var lonely;
	var mean;
	var moody;
	var nervous;
	var neutral;
	var offended;
	var playful;
	var proud;
	var relieved;
	var remorseful;
	var restless;
	var sad;
	var sarcastic;
	var serious;
	var shocked;
	var shy;
	var sick;
	var sleepy;
	var stressed;
	var surprised;
	var thirsty;
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
