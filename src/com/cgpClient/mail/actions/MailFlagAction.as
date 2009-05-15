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

package com.cgpClient.mail.actions
{
import com.cgpClient.mail.Mail;
import com.cgpClient.net.Net;
import com.cgpClient.net.getErrorText;

import flash.events.TimerEvent;
import flash.utils.Timer;
	
public class MailFlagAction
{
	
	private static var yesFlags:Array = 
	[
		"Seen",
		"Read",
		"Answered",
		"Flagged",
		"Draft",
		"Deleted",
		"Redirected",
		"MDNSent",
		"Hidden",
		"Service",
		"Media",
		"Junk",
		"Label1",
		"Label2",
		"Label3"
	];
	
	private static var noFlags:Array = 
	[
		"Unseen",
		"Unread",
		"Unanswered",
		"Unflagged",
		"Undraft",
		"Undeleted",
		"UnRedirected",
		"NoMDNSent",
		"NotHidden",
		"NotService",
		"NotMedia",
		"NotJunk",
		"NotLabel1",
		"NotLabel2",
		"NotLabel3"
	];
	
	private var mail:Mail;
	
	private var flagsTimer:Timer;
	
	private var inProcess:Boolean = false;
	
	private var needToRun:Boolean = false;
	
	/**
	 *  Real flags. They should be the same on the server.
	 */
	private var effectiveFlags:Array;
	
	private var justSentFlags:Array;
	
	public function MailFlagAction(mail:Mail):void
	{
		this.mail = mail;
		effectiveFlags = mail.flags.concat();
		
		flagsTimer = new Timer(100, 1);
		flagsTimer.addEventListener(TimerEvent.TIMER, flagsTimer_timerHandler);
	}
	
	public function start():void
	{
		if (!inProcess)
		{
			inProcess = true;
			flagsTimer.start();
		}
		else if (!flagsTimer.running)
		{
			needToRun = true;
		}
	}
	
	private function realStart():void
	{
		justSentFlags = mail.flags.concat();
		var xml:XML = <messageMark folder={mail.folder.name} 
			flags={difference(effectiveFlags, justSentFlags)}>
			<UID>{mail.uid}</UID>
		</messageMark>;
		Net.ximss(xml, null, reponseCallback); 
	}
	
	private function difference(flags1:Array, flags2:Array):String
	{
		var flag:String;
		var result:Array = [];
		var i:int;
		var n:int = flags1.length;
		for (i = 0; i < n; i++)
		{
			flag = flags1[i];
			// flag is removed
			if (flags2.indexOf(flag) == -1)
				result.push(noFlags[yesFlags.indexOf(flag)]);
		}
		n = flags2.length;
		for (i = 0; i < n; i++)
		{
			flag = flags2[i];
			// flag is removed
			if (flags1.indexOf(flag) == -1)
				result.push(flag);
		}
		return result.join(",");
	}
	
	private function reponseCallback(object:Object):void
	{
		if (!getErrorText(object))
			effectiveFlags = justSentFlags;

		inProcess = false;
		if (needToRun)
		{
			needToRun = false;
			start();
		}
	}
	
	private function flagsTimer_timerHandler(event:TimerEvent):void
	{
		realStart();
	}
	

}
}