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
	 *  Status of the connection before status change. 
	 *  For possible values see <code>NetStatus</code>.
	 */
	public var oldStatus:String;
	
	/**
	 *  Current status of the connection.
	 *  For possible values see <code>NetStatus</code>.
	 */
	public var newStatus:String;
	
	/**
	 *  If status change was caused by some error, it is given here.
	 */ 
	public var error:Error;
	
	public function NetEvent(type:String, oldStatus:String, newStatus:String, error:Error)
	{
		this.oldStatus = oldStatus;
		this.newStatus = newStatus;
		this.error = error;
		
		super(type);
	}
	
}
}