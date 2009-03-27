package com.cgpClient.net
{
import flash.events.Event;

/**
 *  @private
 */
public class ChannelEvent extends Event
{
	
	public static const STATUS:String = "status";
	
	public static const DATA:String = "data";
	
	public var oldStatus:String;
	
	public var newStatus:String;
	
	public var text:String;
	
	public function ChannelEvent(type:String, text:String, oldStatus:String = null,
		newStatus:String = null)
	{
		super(type);
		
		this.text = text;
		this.oldStatus = oldStatus;
		this.newStatus = newStatus;
	}
	
}
}