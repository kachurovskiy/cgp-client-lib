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
		Net.ximss(<folderRead folder={mail.folder.name} 
			uid={mail.uid} totalSizeLimit={10 * 1000 * 1000}/>, dataCallBack, responseCallBack);
	}
	
	private function dataCallBack(xml:XML):void
	{
		mail.update(xml);
	}
	
	private function responseCallBack(object:Object):void
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