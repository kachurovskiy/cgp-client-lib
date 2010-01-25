/* Copyright (c) 2010 Maxim Kachurovskiy

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
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;

[Event(name="data", type="com.cgpClient.net.ChannelEvent")]
[Event(name="error", type="flash.events.ErrorEvent")]
[Event(name="status", type="com.cgpClient.net.ChannelEvent")]
/**
 *  @private
 */
public class Channel extends EventDispatcher
{
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//--------------------------------------
	//  status
	//--------------------------------------

	protected var _status:String = ChannelStatus.RELAX;
	protected var statusError:String;
	
	[Bindable("statusChange")]
	/**
	 *  Current channel status, see <code>ChannelStatus</code> for possible
	 *  values.
	 */
	public function get status():String
	{
		return _status;
	}
	
	public function set status(value:String):void
	{
		if (_status == value && !statusError)
			return;
		
		var oldStatus:String = _status;
		_status = value;
		dispatchEvent(new ChannelEvent(ChannelEvent.STATUS, statusError, oldStatus, _status));
		statusError = null;
	}
	
	//--------------------------------------
	//  host
	//--------------------------------------

	protected var _host:String;
	
	public function get host():String
	{
		return _host;
	}
	
	public function set host(value:String):void
	{
		if (_status == ChannelStatus.RELAX)
			_host = value;
		else
			throw new Error("Not the best time to set host " + _host + " to " + 
				value +  ", status: " + _status);
	}
	
	//--------------------------------------
	//  port
	//--------------------------------------

	protected var _port:int;
	
	public function get port():int
	{
		return _port;
	}
	
	public function set port(value:int):void
	{
		if (_status == ChannelStatus.RELAX)
			_port = value;
		else
			throw new Error("Not the best time to set port " + _port + " to " + 
				value +  ", status: " + _status);
	}
	
	/**
	 *  Channel will save here all XMLs and other data, recieved during login.
	 */
	public var loginData:Array = [];

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function Channel(host:String, port:int)
	{
		this.host = host;
		this.port = port;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	public function connect():void
	{
		throw new Error("override this");
	}
	
	public function login(loginUserName:String, password:String):void
	{
		throw new Error("override this");
	} 
	
	public function send(xml:XML):void
	{
		throw new Error("override this");
	}
	
	public function disconnect():void
	{
		throw new Error("override this");
	}
	
	override public function toString():String
	{
		return "[" + getQualifiedClassName(this) + " " + [host, port] + "]";
	}
	
}
}