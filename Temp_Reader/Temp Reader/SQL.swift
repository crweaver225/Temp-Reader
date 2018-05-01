//
//  SQL.swift
//  Temp Reader
//
//  Created by Christopher Weaver on 12/9/17.
//  Copyright © 2017 Christopher Weaver. All rights reserved.
//

import Foundation

class SQL {
    
    func generateTablesForFirstTime() {
        let query = "CREATE TABLE temperature_log (key_id TEXT PRIMARY KEY , temperature TEXT, time TEXT )"
        
        updateDatabase(query)
        
        let secondQuery = "CREATE TABLE limit_values (key_id TEXT PRIMARY KEY, highLimit INTEGER, lowLimit INTEGER )"
        
        updateDatabase(secondQuery)
        
        let newKeyIdInt = arc4random_uniform(1000)
        let newKeyId = "Chris\(newKeyIdInt)"
        let notifyTempQuery = "insert into limit_values (key_id, lowLimit, highLimit) values ('\(newKeyId)', 0, 100)"
        updateDatabase(notifyTempQuery)
    }
    
    var paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    //MARK:  Open Database
    
    func openDatabase(pathComponent: String?) -> OpaquePointer {
        
        let DBURL : URL
        
        DBURL = paths[0].appendingPathComponent("sqlite")
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(DBURL.absoluteString, &db) == SQLITE_OK {
            //do nothing
        } else {
            
           
            print("Unable to open database. ")
        }
        return db!
    }
    
    //MARK:  Update Database
    
    func updateDatabase(_ dbCommand: String)
    {
        var updateStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                //do nothing
            } else {
                print("Could not updateDatabase")
            }
        } else {
            print("updateDatabase dbCommand could not be prepared")
        }
        
        sqlite3_finalize(updateStatement)
        
        sqlite3_close(db)
        
    }
    
    //MARK:  Get DBValue
    
    func dbValue(_ dbCommand: String) -> String
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        
        var value: String? = nil
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                
                let getResultCol = sqlite3_column_text(getStatement, 0)
                // value = String(cString: UnsafePointer<CChar>(getResultCol!))
                value = String(cString:getResultCol!)
                
            }
            
        } else {
            print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        if (value == nil)
        {
            value = ""
        }
        
        return value!
    }
    
    //MARK: Get Next ID
    
    func nextID(_ tableName: String!) -> Int
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        
        let dbCommand = String(format: "select ID from %@ order by ID desc limit 1", tableName)
        
        var value: Int32? = 0
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                
                value = sqlite3_column_int(getStatement, 0)
            }
            
        } else {
            print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        var id: Int = 1
        if (value != nil)
        {
            id = Int(value!) + 1
        }
        
        return id
    }
    
    //MARK: Get DB Int
    
    func dbInt(_ dbCommand: String!) -> Int
    {
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: nil)
        
        var value: Int32? = 0
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            if sqlite3_step(getStatement) == SQLITE_ROW {
                
                value = sqlite3_column_int(getStatement, 0)
            }
            
        } else {
            //  print("dbValue statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        var int: Int = 1
        if (value != nil)
        {
            int = Int(value!)
        }
        
        return int
    }
    
    //MARK:  Get Rows
    
    func getRows(_ dbCommand: String, directory: String?) -> [[String : AnyObject]] {
        
        var outputArray = [[String : AnyObject]]()
        
        var getStatement: OpaquePointer? = nil
        
        let db: OpaquePointer = openDatabase(pathComponent: directory)
        
        if sqlite3_prepare_v2(db, dbCommand, -1, &getStatement, nil) == SQLITE_OK {
            
            while sqlite3_step(getStatement) == SQLITE_ROW {
                
                var rowDictionary: [String : AnyObject] = [:]
                
                let columnCount = sqlite3_column_count(getStatement)
                
                for i in 0..<columnCount {
                    
                    let val = sqlite3_column_text(getStatement, Int32(i))
                    
                    let key = sqlite3_column_name(getStatement, Int32(i))
                    
                    if let val = val, let key = key {
                        
                        let valStr = String(cString: val)
                        
                        let row = String(cString: key)
                        
                        rowDictionary[row] = valStr as AnyObject?
                    }
                }
                
                outputArray.append(rowDictionary)
            }
            
        } else {
            print("getRows statement could not be prepared")
        }
        
        sqlite3_finalize(getStatement)
        
        sqlite3_close(db)
        
        return outputArray
    }
}

