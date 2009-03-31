package model
{
import control.fileStorage.FileStorage;
	
[Bindable]
public class Model
{
	
	//--------------------------------------------------------------------------
	//
	//  Static properties
	//
	//--------------------------------------------------------------------------

	private static var _instance:Model;
	
	public static function get instance():Model
	{
		if (!_instance)
			_instance = new Model();
		
		return _instance;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	public var loginUserName:String;

	public var host:String;

	public var fileStorage:FileStorage;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function Model()
	{
		if (_instance)
			throw new Error("Singleton exception");
		
		setDefaultValues();
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  Called on logout.
	 */
	public function setDefaultValues():void
	{
		loginUserName = null;
		host = null;
		fileStorage = null;
	}
	
}
}