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
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;

/**
 *  @private
 */
public class XIMSSSocket extends Channel
{
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	private var socket:Socket = new Socket();
	
	private var readBuffed:ByteArray = new ByteArray();
	
	private var loggingIn:Boolean = false;
	private var loginUserName:String;
	private var password:String;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @param port 80, 11024 or something else (custom server settings).
	 */
	public function XIMSSSocket(host:String, port:int)
	{
		super(host, port);
		
		socket.addEventListener(Event.CONNECT, connectHandler);
		socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
		socket.addEventListener(Event.CLOSE, closeHandler);
		
		socket.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overriden methods
	//
	//--------------------------------------------------------------------------

	override public function connect():void
	{
		status = ChannelStatus.CONNECTING;
		try
		{
			socket.connect(host, port);
		}
		catch (error:Error)
		{
			errorHandler(error);
		}
	}
	
	override public function login(loginUserName:String, password:String):void
	{
		if (_status == ChannelStatus.LOGGING_IN || _status == ChannelStatus.LOGGED_IN)
			throw new Error("Already " + _status);
		
		loginData = [];
		this.loginUserName = loginUserName;
		this.password = password;
		if (_status == ChannelStatus.CONNECTED)
			startLogin();
	}
	
	override public function send(xml:XML):void
	{
		if (socket.connected)
		{
			XML.prettyPrinting = false;
			var text:String = xml.toXMLString();
			XML.prettyPrinting = true;
			
			socket.writeUTFBytes(text);
			socket.writeByte(0);
			socket.flush();
			
			text = text.split("\n").join("\\n");
			text = text.split("\t").join("\\t");
			trace("C: " + text);
		}
		else
		{
			throw new Error("not connected");
		}
	}
	
	override public function disconnect():void
	{
		if (_status == ChannelStatus.CONNECTED && socket.connected)
		{
			try
			{
				socket.close();
			}
			catch (error:Error) {}
		}
		status = ChannelStatus.RELAX;
	}
	
	private function startLogin():void
	{
		status = ChannelStatus.LOGGING_IN;
		send(<login method="CRAM-MD5" id="login"/>);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	private function connectHandler(event:Event):void
	{
		status = ChannelStatus.CONNECTED;
		if (loginUserName)
			startLogin();
	}
	
	private function dataHandler(event:ProgressEvent):void
	{
		var startLength:int = readBuffed.length;
		socket.readBytes(readBuffed, readBuffed.length, socket.bytesAvailable);
		var newLength:int = readBuffed.length;
		readBuffed.position = startLength;
		var lastZero:int = 0;
		var lastByte:int;
		for (var i:int = startLength; i <= newLength; i++)
		{
			if (readBuffed.bytesAvailable == 0)
				break;
			
			lastByte = readBuffed.readByte();
			if (lastByte == 0 && lastZero + 1 == i)
			{
				lastZero++;
			}
			else if (lastByte == 0)
			{
				readBuffed.position = lastZero;
				var text:String = readBuffed.readUTFBytes(i - lastZero);

				var traceText:String = text.split("\n").join("\\n");
				traceText = traceText.split("\t").join("\\t");
				trace("S: " + traceText);

				dataParserHandler(text);
				
				readBuffed.position = i;
				lastZero = i;
			}
		}
		if (lastByte == 0)
			readBuffed = new ByteArray();
	}
	
	private function dataParserHandler(text:String):void
	{
		if (_status == ChannelStatus.LOGGING_IN)
		{
			var xml:XML = new XML(text);
			if (xml.name() == "challenge")
			{
				var challengeBase:String = xml.@value;
				var challenge:String = Base64.decode(challengeBase);
				var authPart2:String = HMAC.hash(password, challenge);
				var auth:String = Base64.encode(loginUserName + " " + authPart2);
				
				// data and response callbacks were given earlier 
				send(<auth id="login" value={auth}/>);
			}
			else if (xml.name() == "session")
			{
				loginData.push(xml);
			}
			else if (xml.name() == "response")
			{
				loginUserName = null;
				password = null;
				var errorText:String = getErrorText(xml);
				if (errorText)
				{
					statusError = errorText;
					status = ChannelStatus.RELAX;
				}
				else
				{
					status = ChannelStatus.LOGGED_IN;
				}
			}
		}
		else // regular work
		{
			dispatchEvent(new ChannelEvent(ChannelEvent.DATA, text));
		}
	}
	
	private function closeHandler(event:Event):void
	{
		status = ChannelStatus.RELAX;
	}
	
	private function errorHandler(object:Object):void
	{
		var text:String;
		if (object is Error)
			text = Error(object).message;
		else if (object is ErrorEvent)
			text = ErrorEvent(object).text;
		else
			throw new Error("What's that? Error: " + object);
		
		var previousStatus:String = status;
		statusError = text;
		status = ChannelStatus.RELAX;
	}

}
}