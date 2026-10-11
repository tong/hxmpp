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
    [XEP-0118: User Tune](https://xmpp.org/extensions/xep-0118.html)
**/
@xep(118)
typedef Tune = {
	/** The artist or performer of the song or piece */
	var ?artist : String;
    /** **/
	var ?composer : String;
    /** **/
	var ?date : String;
    /** **/
	var ?genre : String;
	var ?language : String;
	var ?length : String;
	var ?lyricist : String;
	var ?performer : String;
	var ?rating : String;
	/** The duration of the song or piece in seconds */
	// var ?length : Int;
	// /** The user's rating of the song or piece, from 1 (lowest) to 10 (highest). */
	// var ?rating(default,set) : Int;
	// /** The collection (e.g., album) or other source (e.g., a band website that hosts streams or audio files) */
	// var ?source : String;
	// /** The title of the song or piece */
	// var ?title : String;
	// /** A unique identifier for the tune; e.g., the track number within a collection or the specific URI for the object (e.g., a stream or audio file) */
	// var ?track : String;
	// /** A URI or URL pointing to information about the song, collection, or artist */
	// var ?uri : String;
}

/**
    [XEP-0080: User Location](https://xmpp.org/extensions/xep-0080.html)
**/
@xep(80)
typedef Location = {
	/** Horizontal GPS error in meters; this element obsoletes the <error/> element */
	var accuracy : Int;
	/** Altitude in meters above or below sea level */
	var alt : Int;
	/** A named area such as a campus or neighborhood */
	var area : String;
	/** GPS bearing (direction in which the entity is heading to reach its next waypoint), measured in decimal degrees relative to true north */
	var bearing : Int;
	/** A specific building on a street or in an area */
	var building : String;
	/** The nation where the user is located */
	var country : String;
	/** GPS datum */
	var datum : String;
	/** A natural-language name for or description of the location */
	var description : String;
	/** Horizontal GPS error in arc minutes; this element is deprecated in favor of <accuracy/> */
	var error : Int;
	/** A particular floor in a building */
	var floor : String;
	/** Latitude in decimal degrees North */
	var lat : Float;
	/** A locality within the administrative region, such as a town or city */
	var locality : String;
	/** Longitude in decimal degrees East */
	var lon : Float;
	/** A code used for postal delivery */
	var postalcode : String;
	/** An administrative region of the nation, such as a state or province */
	var region : String;
	/** A particular room in a building */
	var room : String;
	/** The speed at which the entity is moving, in meters per second */
	var speed : Float;
	/** A thoroughfare within the locality, or a crossing of two thoroughfares */
	var street : String;
	/** A catch-all element that captures any other information about the location */
	var text : String;
	/** UTC timestamp specifying the moment when the reading was taken */
	var timestamp : String;
	/** A URI or URL pointing to information about the location */
	var uri : String;
}

/**
    Use the publish-subscribe protocol to broadcast state change events associated with an instant messaging and presence account.

    [XEP-0163: Personal Eventing Protocol](https://xmpp.org/extensions/xep-0163.html)
**/
@xep(163)
class Pep {

	public static inline var XMLNS_ACTIVITY = "http://jabber.org/protocol/activity";
	public static inline var XMLNS_MOOD     = "http://jabber.org/protocol/mood";
	public static inline var XMLNS_TUNE     = "http://jabber.org/protocol/tune";

    public static inline function publishActivity(stream: Stream, activity: Activity, handler:Response<XML>->Void) : IQ {
        return publish(stream, XMLNS_ACTIVITY,
            XML.create("activity").set("xmlns", XMLNS_ACTIVITY)
                .append(XML.create(activity)), handler);
    }
/*
    public static inline function publishMood(stream: Stream, mood:Mood, text:String, handler:Response<XML>->Void) : IQ
        return stream.set(payload()
            .append(XML.create("publish").set("xmlns", XMLNS_MOOD)
                .append(XML.create("item")
                    .append(XML.create("mood").set("xmlns", XMLNS_MOOD)
                        .append(XML.create(mood))
                        .append(XML.create("text", text))))), handler);

    public static inline function publishTune(stream: Stream, tune:Tune, handler:Response<XML>->Void) : IQ {
        final e = XML.create("tune").set("xmlns", XMLNS_TUNE);
        for(f in Reflect.fields(tune))
            e.append(XML.create(f, Reflect.field(tune, f)));
        return stream.set(payload()
            .append(XML.create("publish").set("xmlns", XMLNS_TUNE)
                .append(XML.create("item")
                    .append(e))), handler);
    }
    */

    static inline function publish(stream: Stream, xmlns: String, item:XML, handler:Response<XML>->Void) : IQ {
        return stream.set(Payload.create(PubSub.XMLNS,"pubsub")
            .append(XML.create("publish").set("node", xmlns)
                .append(XML.create("item")
                    .append(item))), handler);
    }

    // static inline function payload() : XML {
    //     return Payload.create(PubSub.XMLNS, "pubsub");
    // }
}

