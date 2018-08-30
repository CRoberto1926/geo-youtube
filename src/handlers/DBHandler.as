package handlers
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	public final class DBHandler
	{
		private var _dbFile:File;
		
		public function DBHandler(dbFileName:String)
		{
			_dbFile = File.applicationStorageDirectory.resolvePath(dbFileName);
		}
		
		public function dbFileExists():Boolean
		{
			return _dbFile.exists;
		}
		
		public function executeQuery(queryString:String):SQLResult
		{
			return _executeQuery(queryString);
		}
		
		public function executeQueries(queriesArray:Array):Array
		{
			var arraySQLResults:Array = new Array();
			
			for each(var queryString:String in queriesArray)
			{
				arraySQLResults.push(_executeQuery(queryString));
			}
			
			return arraySQLResults;
		}
		
		private function _executeQuery(queryString:String):SQLResult
		{
			var dbConnection:SQLConnection = new SQLConnection();
			
			try
			{
				dbConnection.open(_dbFile);
			}
			catch(e:Error)
			{
				Alert.show("Something went wrong: " + e.message + " - " + e.name);
				return null;
			}
			
			var querySQL:SQLStatement = new SQLStatement();
			querySQL.sqlConnection = dbConnection;
			
			querySQL.text = queryString;
			
			try{
				querySQL.execute();
				dbConnection.close();
			}
			catch(e:Error)
			{
				Alert.show("Something went wrong: " + e.message + " - " + e.name);
				return null;
			}
			
			return querySQL.getResult();
		}
	}
}