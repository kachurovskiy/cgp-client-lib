# What CGP Client Library is for

CGPClient Library is a tiny ActionScript 3.0 library that lets you create  simple **CommuniGate Pro** Flash/Flex/AIR client in 5 minutes. 

Pass login credentials, and a few moments later you can work with server  over simple XML-based XIMSS protocol that allows to read/send mail, IM and much more. For example sending IM looks in code like 

    Net.ximss(<sendIM peer="friend@server.com">Hi there!</sendIM>, null, responseCallBack);

CGPClient library source is available here and can be freely modified and [included in proprietary software](http://www.opensource.org/licenses/mit-license.php). 

# Library-Based Projects

* [Pronto!](http://communigate.com/pronto)

# Examples

## Login

```
Net.dispatcher.addEventListener(NetEvent.STATUS, statusHandler);
Net.login(hostInput.text, loginInput.text, passwordInput.text);

function statusHandler(event:NetEvent):void
{
    if (event.status == NetStatus.LOGGED_IN)
    {
        // we're in
    }
    else if (event.status == NetStatus.RELAX && event.error)
    {
        // login failed - ex. password is incorrect or server is not available
    }
}
```

## XIMSS Synchronous Requests

```
Net.ximss(<folderRead folder={Model.instance.folder.name} 
    uid={mail.uid} totalSizeLimit={10 * 1024 * 1024}/>, dataCallBack, responseCallBack);
    
private function dataCallBack(xml:XML):void
{
    mail.update(xml);
}
  
private function responseCallBack(object:Object):void
{
    var text:String = getErrorText(object); 
    if (text)
    {
        mail.status = Mail.PREVIEW;
        mail.errors.addItem(new Error(text));
    }
    else
    {
        mail.status = Mail.VIEW;
    }
}
```

## XIMSS Asynchronous Requests

```
Net.dispatcher.addEventListener("ximss-readIM", readIMHandler);
  
function readIMHandler(event:XIMSSAsyncEvent):void
{
    trace("Incoming IM: " + event.xml.toXMLString());
}
```

## Connection status

```
trace(Net.status); // relax, loggingIn or loggedIn

Net.dispatcher.addEventListener(NetEvent.STATUS, statusHandler);

function statusHandler(event:NetEvent):void
{
    if (event.status == NetStatus.LOGGED_IN)
    {
        // we're in, ximss() can be used
    }
    else if (event.status == NetStatus.RELAX)
    {
        if (event.error) 
            // connection has broke or login failed
        else
            // normal connection close
    }
}
```

# Full documentation for CGP Client Library

CGP Client Library provides a set of classes that allows to log into CommuniGate Pro server, send requests, receive responses and log out.

# Logging in

## `Net.login():void`

Starts log in process. Parameters:

  * `host:String`
  * `user:String` 
  * `password:String` 
  * `failoverScheme:String = "socket 80, socket 11024, binding 80, binding 8100, sbinding 443"` Optional. Specification of channels that should be used.

When log in process succeeds or fails, `NetEvent.STATUS` event is dispatched via `Net.dispatcher`.

Throws error if already logging in or logged in.

Example:

```
Net.dispatcher.addEventListener(NetEvent.STATUS, statusHandler);
Net.login(hostInput.text, loginInput.text, passwordInput.text);

function statusHandler(event:NetEvent):void
{
    if (event.status == NetStatus.LOGGED_IN)
    {
        // we're in
    }
    else if (event.status == NetStatus.RELAX && event.error)
    {
        // login failed - ex. password is incorrect or server is not available
    }
}
```

## `Net.dispatcher:IEventDispatcher`

`dispatcher` is a static property of `Net` class. It dispatches `NetEvent.STATUS` event with the following properties:

  * `newStatus:String` - current status of the connection.
  * `oldStatus:String` - status of the connection before status change. 
  * `error:Error` - if status change was caused by some error, it is provided here

Possible values of `newStatus` and `oldStatus` are specified in `NetStatus` class static constants:

  * `RELAX:String = "relax"`
  * `LOGGING_IN:String = "loggingIn"`
  * `LOGGED_IN:String = "loggedIn"`

## `Net.status:String`

Current connection status. Possible values are specified in `NetStatus` class.

## `Net.loginData:Array`

Array of `XML`-s that were received during login process. Can be used for example to determine session id.

# Working with synchronous XIMSS requests

## Net.ximss():void

Sends XML to the server. Parameters:

  * `xml:XML` - request XML without `id` attribute
  * `dataCallback:Function` - is called each time server returns data response for this request. Function signature is `function(xml:XML)`.
  * `responseCallback:Function` - is called when server returns `<response id="..."/>` reponse or when we have failed to make request. Function signature is `function(object:Object)` because both `XML` and `Error` objects can be passed.

Example:
```
Net.ximss(<sendIM peer="maxim@communigate.com">Hello, how are you?</sendIM>, null, sendIM_responseCallback);

private function sendIM_responseCallback(object:Object):void
{
    // getErrorText() is a function in the library
    var errorText:String = getErrorText(object);
    if (errorText)
        trace("Failed to send instant message: " + errorText);
}
```

# Working with asynchronous XIMSS messages

## `Net.dispatcher:IEventDispatcher`

When asynchronous message arrived it is dispatched by `dispatcher` as an event with name `ximss-asyncMessageName` with properties:

  * `xml:XML` - message body

Example:
```
Net.dispatcher.addEventListener("ximss-readIM", readIMHandler);

private function readIMHandler(xml:XML):void
{
    trace("New incoming message: " + xml);
}
```

# Logging out

Send `<bye/>` synchronous request to log out.
