package com.cgpClient.net
{

import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 *  <code>Net</code> class connects to CommuniGate Pro
 *  server using socket or HTTP Binding, establishes XIMSS session (login), 
 *  sends XIMSS requests and receives data from server.
 * 
 *  <p>Use <code>login()</code> method to establish connection.</p>
 * 
 *  <p>Login process can be monitored by subscribing to <code>NetEvent.STATUS</code>
 *  event that is dispatched by <code>dispatcher</code>.</p>
 * 
 *  <p>After successful logging in you can send synchronous XIMSS requests 
 *  to server using <code>ximss()</code> method and receive asynchronous
 *  messages by subscribing to <code>dispatcher</code> events.</p>
 * 
 *  <p>To close XIMSS session send <code>&lt;bye/&gt;</code> to the server and
 *  connection will be closed.</p>
 * 
 *  @see #login()
 *  @see #ximss()
 *  @see #dispatcher
 *  @see #status
 */
public class Net
{

	//--------------------------------------------------------------------------
	//
	//  Static properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  status
	//--------------------------------------

	private static var _status:String = NetStatus.RELAX;
	private static var statusError:Error;

	/**
	 *  Connection status. Possible values are <code>NetStatus.RELAX</code>,
	 *  <code>NetStatus.LOGGING_IN</code> and <code>NetStatus.LOGGED_IN</code>.
	 * 
	 *  <p>Status can be monitored by listening <code>NetEvent.STATUS</code>
	 *  event from <code>dispatcher</code>.</p>
	 * 
	 *  @default NetStatus.RELAX
	 */
	public static function get status():String
	{
		return _status;
	}
	
	private static function setStatus(value:String):void
	{
		if (_status == value)
			return;
		
		var object:Object;
		var i:int;
		var n:int;
		if (_status == NetStatus.LOGGED_IN) // report error on all XIMSS calls
		{
			dataCallBacks = {};
			
			var error:Error = new Error("Connection was lost");
			var noCallBackError:Error = Error("Request " + p + " does not have response " + 
				" callback to handle error: " + error.message);
			for (var p:String in responseCallBacks)
			{
				var callBack:Function = responseCallBacks[p];
				delete responseCallBacks[p];
				if (callBack == null)
					throw noCallBackError;
				callBack(error);
			}
			responseCallBacks = {};
			ximssId = 0;
			
			n = cachedXIMSS.length;
			for (i = 0; i < n; i++)
			{
				object = cachedXIMSS[i];
				if (object.responseCallBack)
					object.responseCallBack(error);
				else
					throw noCallBackError; 
			}
			cachedXIMSS = [];
		}
		
		_status = value;

		if (_status == NetStatus.LOGGED_IN) // send all cached requests
		{
			n = cachedXIMSS.length;
			for (i = 0; i < n; i++)
			{
				object = cachedXIMSS[i];
				ximss(object.xml, object.dataCallBack, object.responseCallBack);
			}
			cachedXIMSS = [];
		}
		
		dispatcher.dispatchEvent(new NetEvent(NetEvent.STATUS, _status, statusError));
		statusError = null;
	}

	//--------------------------------------
	//  channel
	//--------------------------------------
	
	private static var _channel:Channel;
	
	private static function get channel():Channel
	{
		return _channel;
	}

	private static function set channel(value:Channel):void
	{
		if (_channel)
		{
			_channel.removeEventListener("statusChange", channel_statusChangeHandler);
			_channel.removeEventListener(DataEvent.DATA, channel_dataHandler);
			_channel.removeEventListener(ErrorEvent.ERROR, channel_errorHandler);
		}
		
		_channel = value;
		
		if (_channel)
		{
			_channel.addEventListener("statusChange", channel_statusChangeHandler);
			_channel.addEventListener(DataEvent.DATA, channel_dataHandler);
			_channel.addEventListener(ErrorEvent.ERROR, channel_errorHandler);
		}
	}

	//--------------------------------------
	//  loginData
	//--------------------------------------

	/**
	 *  Array of <code>XML</code> elements, that were received during last login.
	 */
	public static function get loginData():Array
	{
		return channel.loginData;
	}
	
	//--------------------------------------
	//  dispatcher
	//--------------------------------------

	private static var _dispatcher:EventDispatcher = new EventDispatcher();
	
	/**
	 *  Dispatched for <code>XIMSSAsyncEvent</code> and <code>NetEvent</code>
	 *  events.
	 * 
	 *  <p><strong>Example: listening to asynchronous XIMSS event</strong>
	 *  <listing>
	 *  Net.dispatcher.addEventListener("ximss-readIM", readIMHandler);
	 * 
	 *  function readIMHandler(event:XIMSSAsyncEvent):void
	 *  {
	 *      trace("Incoming IM: " + event.xml.toXMLString());
	 *  }
	 *  </listing></p>
	 * 
	 *  <p><strong>Example: monitoring login process</strong>
	 *  <listing>
	 *  Net.dispatcher.addEventListener(NetEvent.STATUS, statusHandler);
	 *  Net.login("myserver.com", "user1", "password1", "socket 11024, binding 80");
	 *  
	 *  function statusHandler(event:NetEvent):void
	 *  {
	 *      if (event.status == NetStatus.RELAX)
	 *      {
	 *          if (event.error)
	 *          {
	 *              // login failed, show user the problem
	 *              textField.text = event.error.toString();
	 *          }
	 *          else
	 *          {
	 *              // session has ended without error
	 *              // ex. server has shutdown or user logged out
	 *          }
	 *      }
	 *      else if (event.status == NetStatus.LOGGED_IN)
	 *      {
	 *          // we are logged in, ximss() works
	 *      }
	 *  }
	 *  </listing></p>
	 */
	public static function get dispatcher():EventDispatcher
	{
		return _dispatcher;
	}
	
	private static var ximssId:int = 0;
	private static var dataCallBacks:Object;
	private static var responseCallBacks:Object;
	private static var cachedXIMSS:Array = []; /* of Object with props xml, 
		dataCallBack, responseCallBack */
	
	private static var host:String;
	private static var loginUserName:String;
	private static var password:String;
	private static var failoverScheme:Array;
	private static var failoverIndex:int;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function Net()
	{
		throw new Error("Do not instantiate Net, use static class methods");
	}

	//--------------------------------------------------------------------------
	//
	//  Static methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Create XIMSS session with CommuniGate Pro server. To monitor the login
	 *  process use <code>status</code> property and 
	 *  <code>dispatcher</code> <code>NetEvent.STATUS</code> event.
	 * 
	 *  @param theHost Remote host, for example <code>mail.myserver.com</code>
	 *  @param theLoginUserName User login user name. Can be <code>alex</code>
	 *  or <code>mary&#64;myserver.com</code>
	 *  @param thePassword Password in plain text
	 *  @param theFailoverScheme Channels that should be used to establish 
	 *  connection. Available channels are "socket" and "binding". <p>
	 *  <strong>Note:</strong> only AIR applications can connect to ports less than 1024.</p>
	 */
	public static function login(theHost:String, theLoginUserName:String, 
		thePassword:String, theFailoverScheme:String = 
		"socket 80, socket 11024, binding 80, binding 8100"):void
	{
		if (status != NetStatus.RELAX)
			throw new Error("login() can be called with status == " + 
				"NetStatus.RELAX (status is " + status + ")");
	
		host = theHost;
		loginUserName = theLoginUserName;
		password = thePassword;
		failoverScheme = theFailoverScheme.toLowerCase().split(",");
		failoverIndex = 0;
		
		if (!_channel)
			setNextChannel();
		
		dataCallBacks = {};
		responseCallBacks = {};
		
		setStatus(NetStatus.LOGGING_IN);
		
		channel.login(loginUserName, password);
	}

	/**
	 *  If XIMSS session is established, sends synchronous XIMSS request.
	 *  In other cases requests are cached until <code>status</code> will become
	 *  <code>NetStatus.LOGGED_IN</code> or <code>NetStatus.RELAX</code>.
	 * 
	 *  <p><strong>Example: sending IM</strong>
	 *  <listing>
	 *  Net.ximss(&lt;sendIM peer="maxim&#64;communigate.com"&gt;Hey, your lib really works!&lt;/sendIM&gt;,
	 * 	    null, responseCallBack);
	 * 
	 *  function responseCallBack(object:Object):void
	 *  {
	 *      var text:String = getErrorText(object);
	 *      if (text) // IM was not sent, show error 
	 *          historyArea.text += "Error: " + text + "\n\n";
	 *  }
	 *  </listing>
	 * 
	 *  <p><strong>Example: reading mail body</strong>
	 *  <listing>
	 *  Net.ximss(&lt;folderRead folder={Model.instance.folder.name} 
	 *      uid={mail.uid} totalSizeLimit={10485760}/&gt;, dataCallBack, responseCallBack);
	 *   
	 *  private function dataCallBack(xml:XML):void
	 *  {
	 *      mail.update(xml);
	 *  }
	 * 
	 *  private function responseCallBack(object:Object):void
	 *  {
	 *      var text:String = getErrorText(object);	
	 *      if (text)
	 *      {
	 *          mail.status = Mail.PREVIEW;
	 *          mail.errors.addItem(new Error(text));
	 *      }
	 *      else
	 *      {
	 *          mail.status = Mail.VIEW;
	 *      }
	 *  }
	 *  </listing>
	 * 
	 *  @param xml Synchronous request XML.
	 *  @param dataCallBack Data callback.
	 *  @param responseCallBack Response or error callback.
	 */
	public static function ximss(xml:XML, dataCallBack:Function, responseCallBack:Function):void
	{
		if (_status == NetStatus.LOGGED_IN)
		{
			var name:String = xml.name(); 
			dataCallBacks[ximssId] = dataCallBack;
			responseCallBacks[ximssId] = responseCallBack;
			xml.@id = ximssId;
			ximssId++;
			_channel.send(xml);
		}
		else if (_channel.status == ChannelStatus.LOGGING_IN)
		{
			cachedXIMSS.push(
				{
					xml: xml, 
					dataCallBack: dataCallBack, 
					responseCallBack: responseCallBack 
				});
		}
		else
		{
			throw new Error("Can not send dat to channel " + _channel + 
				" with status: " + _channel.status);
		}
	}
	
	private static function setNextChannel():void
	{
		if (failoverIndex == failoverScheme.length)
		{
			channel = null;
			return;
		}
		else
		{
			var description:String = failoverScheme[failoverIndex];
			var split:Array = description.split(" ");
			for (var i:int = description.length - 1; i >= 0; i--)
			{
				if (split[i] == "")
					split.splice(i, 1);
			}
			var error:Error = new Error("Can not parse channel description: " + description + 
				". Exaple of failoverScheme: \"socket 80, binding 11024\"");
			if (split.length != 2)
				throw error;
			var type:String = split[0];
			var port:int = int(split[1]);
			if (!(port >= 0 && port <= 65535))
				throw error;
			if (type == "socket")
				channel = new XIMSSSocket(host, port);
			else if (type == "binding")
				channel = new HTTPBinding(host, port);
			else
				throw error;
			failoverIndex++;
			
			_channel.connect();
			_channel.login(loginUserName, password);
		}
	}
	
	private static function channel_statusChangeHandler(event:Event):void
	{
		if (channel.status == ChannelStatus.LOGGED_IN)
		{
			setStatus(NetStatus.LOGGED_IN); 
		}
		else if (channel.status == ChannelStatus.LOGGING_IN)
		{
			setStatus(NetStatus.LOGGING_IN); 
		}
		else if (channel.status == ChannelStatus.RELAX)
		{
			// do not eat this status - ex. when we try socket on port1, then
			// socket on port2, then binding - app status shouldn't change
			// loggingIn - relax - loggingIn - relax - loggingIn - loggedIn.
			// It should just do loggingIn - loggedIn.
		}
	}
	
	private static function channel_dataHandler(event:DataEvent):void
	{
		var xml:XML = new XML(event.data);
		var name:String = xml.name().toString();
		if (xml.hasOwnProperty("@id")) // sync
		{
			var id:String = xml.@id;
			if (name != "response")
			{
				var dataCallBack:Function = dataCallBacks[id];
				if (dataCallBack != null)
					dataCallBack(xml);
			}
			else
			{
				var responseCallBack:Function = responseCallBacks[id];
				
				if (dataCallBacks.hasOwnProperty(id))
					delete dataCallBacks[id];
				if (responseCallBacks.hasOwnProperty(id))
					delete responseCallBacks[id];

				if (responseCallBack != null)
					responseCallBack(xml);
			}
		}
		else // asyns message
		{
			var ximssEvent:XIMSSAsyncEvent = new XIMSSAsyncEvent("ximss-" + name, xml);
			dispatcher.dispatchEvent(ximssEvent);
		}
	}
	
	private static function channel_errorHandler(event:ErrorEvent):void
	{
		// socket connection can be disabled by firewall of smth,
		// jump to HTTP Binding.
		if (_channel.status == ChannelStatus.CONNECTING || 
			_channel.status == ChannelStatus.RELAX)
		{
			setNextChannel();
			if (!_channel)
			{
				statusError = new Error(event.text);
				setStatus(NetStatus.RELAX);
			}
		}
	}
	
}
}