package event;
 
typedef TListener<T> = {
    function handleEvent( e : T ) : Void;
}
