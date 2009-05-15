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

public class MailLoadAction
{
	private var mail:Mail;
	
	public function start(mail:Mail):void
	{
		if (mail.status != Mail.PREVIEW)
			return;
		
		this.mail = mail;
		var xml:XML = <folderRead folder={mail.folder.name} 
			uid={mail.uid} totalSizeLimit={10 * 1000 * 1000}/>;
		if (mail.partId)
			xml.@partID = mail.partId;
		Net.ximss(xml, null, responseCallback);
	}
	
	private function responseCallback(object:Object):void
	{
		var text:String = getErrorText(object);	
		if (text)
		{
			mail.status = Mail.PREVIEW;
			mail.errors.addItem(new Error(text));
		}
		else
		{
			mail.status = Mail.VIEW;
		}
	}

}
}