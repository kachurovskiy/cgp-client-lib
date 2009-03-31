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