package com.cgpClient
{
/**
 *  Collection of utilitary methods.
 */
public class CGPUtils
{
	
	/**
	 *  Parses date from "20090404T015200" or "20090403T215200Z" to 
	 *  <code>Date</code>
	 */
	public static function dateFromString(string:String):Date
	{
		var length:int = string.length;
		if ((length != 15 && length != 16) || string.charAt(8) != "T")
			return null;
		
		var date:Date = new Date();
		var year:int = int(string.substring(0, 4));
		var month:int = int(string.substring(4, 6));
		var day:int = int(string.substring(6, 8));
		var hour:int = int(string.substring(9, 11));
		var minute:int = int(string.substring(11, 13));
		var second:int = int(string.substring(13, 15));
		if (length == 16 && string.charAt(15) == "Z")
		{
			date.setUTCFullYear(year, month, day);
			date.setUTCHours(hour, minute, second);
		}
		else
		{
			date.setFullYear(year, month, day);
			date.setHours(hour, minute, second);
		}
		return date; 
	}

	public static function htmlToFlash(htmlText:String):String
	{
		// remove \n linebreaks that do not mean real linebreaks
		htmlText = htmlText.replace(/\r/g, ""); 
		htmlText = htmlText.replace(/\n/g, "");
		
		htmlText = htmlText.replace(/<(\s)*\/?(\s)*br[^>](\s)*\/?(\s)*>/gi, "\n");
		// TODO: replace <p>, <div> and other block elements with line breaks
		
		htmlText = htmlText.replace(/<\/?[^>]*>/g, ""); // remove markup
		
		return htmlText;
	}
	
	public static function plainToFlash(plainText:String):String
	{
		plainText = plainText.replace(/\r\n/g, "\r"); // flash treats this line break as 2 breaks 
		
		return plainText;
	}

}
}