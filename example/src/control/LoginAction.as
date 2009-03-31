package control
{
import com.cgpClient.net.Net;
import com.cgpClient.net.NetEvent;
import com.cgpClient.net.NetStatus;

import model.Model;
	
public class LoginAction
{
	
	public function start(host:String, userName:String, password:String):void
	{
		Model.instance.loginUserName = userName;
		Model.instance.host = host;
		Net.login(host, userName, password);
		
		Net.dispatcher.addEventListener(NetEvent.STATUS, statusHandler);
	}

	private function statusHandler(event:NetEvent):void
	{
		if (event.newStatus == NetStatus.LOGGED_IN)
		{
			var loginCompleteAction:LoginCompleteAction = new LoginCompleteAction();
			loginCompleteAction.start();
		}
	}
	
}
}