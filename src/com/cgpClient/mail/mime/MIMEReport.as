package com.cgpClient.mail.mime
{
public class MIMEReport
{
	
	public var text:String;
	
	public function MIMEReport(xml:XML)
	{
		update(xml);
	}
	
	public function toString():String
	{
		return "MIMEReport: " + (text ? text : "empty");
	}
	
	private function update(xml:XML):void
	{
		text = xml.toString();
	}

}
}