/* Copyright (c) 2009 Maxim Kachurovskiy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

package com.cgpClient.net
{
import com.adobe.crypto.HMAC;
import com.hurlant.util.Base64;

import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Timer;

import mx.utils.StringUtil;

/**
 *  @private
 */
public class HTTPBinding extends Channel
{
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	private var connectingLoader:URLLoader;
	
	private var urlLoader:URLLoader;
	
	private var urlLoaderQueue:Array = [];
	
	private var urlLoaderWorking:Boolean = false;
	
	private var asyncLoader:URLLoader;
	
	private var asyncLoaderRequest:URLRequest;
	
	private var ackSeq:int;
	
	private var asyncBase:String;
	
	private var loginId:String;
	
	private var loggingIn:Boolean = false;
	private var loginUserName:String;
	private var password:String;
	private var sessionId:String;
	
	private var bying:Boolean = false;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function HTTPBinding(host:String, port:int)
	{
		super(host, port);
		
		asyncLoaderRequest = new URLRequest();
		asyncLoaderRequest.method = URLRequestMethod.GET;
		asyncLoader = new URLLoader();
		asyncLoader.addEventListener(Event.COMPLETE, 
			asyncLoader_completeHandler);
		asyncLoader.addEventListener(IOErrorEvent.IO_ERROR, 
			asyncLoader_errorHandler);
		asyncLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
			asyncLoader_errorHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------
	
	override public function connect():void
	{
		status = ChannelStatus.CONNECTING;
		
		if (!connectingLoader)
		{
			connectingLoader = new URLLoader();
			connectingLoader.addEventListener(Event.COMPLETE, 
				connectingLoader_completeHandler);
			connectingLoader.addEventListener(IOErrorEvent.IO_ERROR, 
				connectingLoader_errorHandler);
			connectingLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
				connectingLoader_errorHandler);
		} 
		else
		{
			try
			{
				connectingLoader.close();
			}
			catch (error:Error) {}
		}
		try
		{
			var urlRequest:URLRequest = getURLRequest("<listFeatures id='connecting'/>"); 
			trace("C: connectingLoader: " + urlRequest.url + " | " + urlRequest.data);
			connectingLoader.load(urlRequest);
		}
		catch (error:Error)
		{
			connectingLoader_errorHandler(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message));
		}
	}
	
	override public function login(loginUserName:String, password:String):void
	{
		if (status == ChannelStatus.LOGGED_IN || status == ChannelStatus.LOGGING_IN)
			throw new Error("Status: " + status);
		
		sessionId = null;
		loginData = [];
		this.loginUserName = loginUserName;
		this.password = password;
		if (_status == ChannelStatus.CONNECTED)
			startLogin();
	}
	
	override public function send(xml:XML):void
	{
		if (xml)
			urlLoaderQueue.push(xml);
		if (urlLoaderWorking)
			return;

		urlLoaderWorking = true;
		
		prepareLoader();
		var string:String = "";
		for each (var xmlItem:XML in urlLoaderQueue)
		{
			string += xmlItem.toXMLString();
			if (xmlItem.name() == "bye")
			{
				bying = true;
				break;
			}
		}
		urlLoaderQueue = [];
		var urlRequest:URLRequest = getURLRequest(string);
		trace("C: urlLoader: " + urlRequest.url + " | " + urlRequest.data);
		urlLoader.load(urlRequest);
	}
	
	override public function disconnect():void
	{
		status = ChannelStatus.RELAX;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private function prepareLoader():void
	{
		if (!urlLoader)
		{
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, 
				urlLoader_completeHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, 
				urlLoader_errorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, 
				urlLoader_errorHandler);
		}
		else
		{
			try
			{
				urlLoader.close();
			}
			catch (error:Error) {}
		}
	}
	
	private function startLogin():void
	{
		status = ChannelStatus.LOGGING_IN;
		
		prepareLoader();
		var url:String = "http://" + host + (port == 80 ? "" : ":" + port)  + "/ximsslogin/";
		var urlRequest:URLRequest = new URLRequest(url);
		var urlVariables:URLVariables = new URLVariables();
		
		var nonce:String = loginData[0].nonce;
		var authPart2:String = HMAC.hash(password, nonce);
		var auth:String = Base64.encode(authPart2);

		urlVariables.errorAsXML = 1;
		urlVariables.nonce = nonce;
		urlVariables.username = loginUserName;
		urlVariables.authData = auth;
		urlRequest.data = urlVariables;
		
		urlRequest.method = URLRequestMethod.POST;
		
		trace("C: " + url + " | " + urlVariables.toString());
		urlLoader.load(urlRequest);
	}
	
	private function getURLRequest(xml:String):URLRequest
	{
		var url:String = "http://" + host + (port == 80 ? "" : ":" + port);
		var urlRequest:URLRequest;
		
		if (xml.indexOf("<listFeatures") == 0)
			url += "/ximsslogin/";
		else
			url += "/Session/" + sessionId + "/sync"; 
		urlRequest = new URLRequest(url);
		urlRequest.method = URLRequestMethod.POST;
		urlRequest.data = "<XIMSS>" + xml + "</XIMSS>";
		urlRequest.requestHeaders.push(
			new URLRequestHeader("Content-Type", "text/xml"));
			
		return urlRequest;
	}
	
	private function callAsync():void
	{
		asyncLoaderRequest.url = asyncBase + ackSeq;
		trace("C: asyncLoader: " + asyncLoaderRequest.url + " | " + asyncLoaderRequest.data);
		asyncLoader.load(asyncLoaderRequest);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function connectingLoader_completeHandler(event:Event):void
	{
		trace("S: " + connectingLoader.data);
		loginData.push((new XML(connectingLoader.data)).features[0]);
		status = ChannelStatus.CONNECTED;
		if (loginUserName) // login() was called but we couldn't start that time
			startLogin();
	}
	
	private function connectingLoader_errorHandler(event:ErrorEvent):void
	{
		statusError = event.text;
		status = ChannelStatus.RELAX;
	}
	
	private function urlLoader_completeHandler(event:Event):void
	{
		trace("S: " + StringUtil.trim(urlLoader.data));

		var xml:XML = new XML(urlLoader.data);
		if (status == ChannelStatus.LOGGING_IN)
		{
			loginUserName = null;
			password = null;
			if (xml.response.length() > 0)
			{
				statusError = xml.response.@errorText;
				status = ChannelStatus.RELAX;
			}
			else if (xml.session.length() > 0)
			{
				ackSeq = 0;
				sessionId = xml.session.@urlID; 
				asyncBase = "http://" + host + (port == 80 ? "" : ":" + port) + "/Session/" + 
					sessionId + "/get?maxWait=60&ackSeq=";
				callAsync();
				loginData.push(xml.session[0]);
				
				status = ChannelStatus.LOGGED_IN;
			}
			else
			{
				throw new Error(xml);
			}
		}
		else if (status == ChannelStatus.LOGGED_IN)
		{
			for each (var node:XML in xml.children())
			{
				dispatchEvent(new ChannelEvent(ChannelEvent.DATA, node.toXMLString()));
			}
			
			urlLoaderWorking = false;
			if (bying)
			{
				status = ChannelStatus.RELAX;
				bying = false;
			}
			else if (urlLoaderQueue.length > 0)
			{
				send(null);
			}
		}
	}
	
	private function urlLoader_errorHandler(event:ErrorEvent):void
	{
		trace("S: Error: " + event.text);
		if (loggingIn)
			loggingIn = false;
		urlLoaderWorking = false;
		urlLoaderQueue = [];
		statusError = event.text;
		status = ChannelStatus.RELAX;
	}
	
	private function asyncLoader_completeHandler(event:Event):void
	{
		if (status != ChannelStatus.RELAX)
		{
			trace("S: " + asyncLoader.data);
			var xml:XML = new XML(asyncLoader.data);
			if (xml.children().length() > 0)
			{
				for each (var node:XML in xml.children())
				{
					dispatchEvent(new DataEvent(DataEvent.DATA, false, false, node.toXMLString()));
					if (node.name() == "bye")
					{
						status = ChannelStatus.RELAX;
						return;
					}
				}
				ackSeq++;
			}
			callAsync();
		}
	}
	
	private function asyncLoader_errorHandler(event:ErrorEvent):void
	{
		if (status != ChannelStatus.RELAX)
		{
			trace("S: Error: " + event.text);
			var timer:Timer = new Timer(3000, 1);
			timer.addEventListener(TimerEvent.TIMER, 
				function(... args):void { callAsync(); });
			timer.start();
		}
	}
	
}
}