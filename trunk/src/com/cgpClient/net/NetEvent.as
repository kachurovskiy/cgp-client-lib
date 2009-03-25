package com.cgpClient.net
{
import flash.events.Event;

/**
 *  Describes some events that correspond to <code>Net</code> class. Event 
 *  instances are dispatched via <code>Net.dispatcher</code>.
 */
public class NetEvent extends Event
{
	
	public static const STATUS:String = "status";
	
	/**
	 *  For possible values see <code>NetStatus</code>.
	 */
	public var status:String;
	
	/**
	 *  If status change was caused by some error, it is given here.
	 */ 
	public var error:Error;
	
	public function NetEvent(type:String, status:String, error:Error)
	{
		this.status = status;
		this.error = error;
		
		super(type);
	}
	
}
}