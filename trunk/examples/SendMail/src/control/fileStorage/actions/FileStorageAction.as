package control.fileStorage.actions
{
import control.fileStorage.FileStorage;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

[Event(name="complete", type="flash.events.Event")]
[Event(name="cancel", type="flash.events.Event")]
[Event(name="error", type="flash.events.ErrorEvent")]
public class FileStorageAction extends EventDispatcher
{
	
	/**
	 *  Each child action class should set this property. 
	 */
	protected var fileStorage:FileStorage;
	
	protected var _running:Boolean = false;
	
	[Bindable("runningChange")]
	public function get running():Boolean
	{
		return _running;
	}
	
	protected var _label:String;
	
	[Bindable("labelChange")]
	/**
	 *  Description of the action, that can be shown to the user.
	 */
	public function get label():String
	{
		return _label;
	}
	
	protected function startRunning():void
	{
		_running = true;
		dispatchEvent(new Event("runningChange"));
		
		var actions:ArrayCollection = fileStorage.actions;
		actions.addItem(this);
	}
	
	protected function stopRunning():void
	{
		var actions:ArrayCollection = fileStorage.actions;
		var index:int = actions.getItemIndex(this);
		if (index >= 0)
			actions.removeItemAt(index);
		else
			throw new Error("Action " + this + " was not found in " + actions); 
		
		_running = false;
		dispatchEvent(new Event("runningChange"));
	}
	
	protected function setLabel(value:String):void
	{
		_label = value;
		dispatchEvent(new Event("labelChange"));
	}
	
	protected function complete():void
	{
		stopRunning();
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	protected function cancel():void
	{
		stopRunning();
		dispatchEvent(new Event(Event.CANCEL));
	}
	
	protected function error(text:String):void
	{
		stopRunning();
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, text));
	}
	
}
}