package com.cgpClient.net
{
import flash.events.Event;

/**
 *  Event for asynchronous XIMSS messages. Event type is constucted using 
 *  XML tag name like "ximss-readIM".
 */
public class XIMSSAsyncEvent extends Event
{
	
	/**
	 *  Incoming data.
	 */
	public var xml:XML;
	
	public function XIMSSAsyncEvent(type:String, xml:XML)
	{
		super(type);
		
		this.xml = xml;
	}
	
}
}