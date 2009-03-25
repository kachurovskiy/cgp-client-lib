package com.cgpClient.net
{
/**
 *  Possible statuses of the XIMSS connection. 
 */
public class NetStatus
{

	/**
	 *  Connection is not established and is not being established right now.
	 *  Application usually has this status until user will enter login 
	 *  credentials and press "login".   
	 */	
	public static const RELAX:String = "relax";
	
	/**
	 *  Trying to log in.
	 */
	public static const LOGGING_IN:String = "loggingIn";

	/**
	 *  We are logged in.
	 */
	public static const LOGGED_IN:String = "loggedIn";

}
}