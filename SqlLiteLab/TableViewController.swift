//
//  TableViewController.swift
//  SqlLiteLab
//
//  Created by Salma on 5/31/19.
//  Copyright © 2019 Salma. All rights reserved.
//

import UIKit
import Foundation
import SQLite3

class TableViewController: UITableViewController {
    var friendsList = [Int : String]()
    let fileName = "‎⁨Friends.sqlite"
    var myPath : String?
    var createTableString : String?
    var insertStatementString : String?
    var queryStatementString :String?
    var deleteStatementStirng :String?
    var db : OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
      
       
        //to get the file of db in mobile
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileURL =
            documentsURL.appendingPathComponent(fileName)
        
        myPath = fileURL.path
        
        //delete it to avoid creating multiple ones
        destroyDatabase()
        db = openDatabase()
        
        //to create table
        createTableString = "CREATE TABLE Friends (Id INT PRIMARY KEY NOT NULL,Name CHAR(255));"
        createTable()
        
        //to insert friends
        
        insertStatementString = "INSERT INTO Friends (Id, Name) VALUES (?, ?);"

        insert(id: 0,name: "salma")
        insert(id: 1,name: "sahar")
        insert(id: 2,name: "nouran")
        insert(id: 3,name: "esraa")
        insert(id: 4,name: "radya")
        insert(id: 5,name: "menna")
        
        
        //to get all friends
        queryStatementString = "SELECT * FROM Friends;"
        query()
        self.tableView.reloadData()
        print(friendsList)
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       
        cell.textLabel?.text = friendsList[indexPath.row]
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            deleteStatementStirng = "DELETE FROM Friends WHERE Id = \(indexPath.row);"
            delete()
            friendsList.removeValue(forKey: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func destroyDatabase(){
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: myPath!))
            print ("deleted")
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
    
    func openDatabase() -> OpaquePointer? {
        
        //opaque pointer da 3lshan l swift mfehash pointers w sqllite mktoba c w feha pointers f ana 3ayza a5le l swift yfhmha
        
        var db: OpaquePointer? = nil
        if sqlite3_open(myPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(myPath ?? " ")")
            return db
        } else {
            print("Unable to open database. Verify that you created the directory described " +
                "in the Getting Started section.")
            return nil
        }
        
    }
    
    func createTable() {
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK { //-1 unlimited length, nil means i willnot truncate query , after compilateion,byte code is returned in &createTableStatement if syntax is right

            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Friends table created.")
            } else {
                print("Friends table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }

        sqlite3_finalize(createTableStatement)
        //You must always call sqlite3_finalize() on your compiled statement to delete it and avoid resource leaks. Once a statement has been finalized, you should never use it again.
    }
    
    func insert(id:Int32,name:NSString) {
        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {

            sqlite3_bind_int(insertStatement, 1, id)

            sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
            
            // the fifth arg is destructor used to dispose of the BLOB or string after SQLite has finished with it.
            
            // -1 means unlimited length of query
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        // 5
        sqlite3_finalize(insertStatement)
    }
    
    
    func query() {
        var queryStatement: OpaquePointer? = nil
 
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {

            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                
                let name = String(cString: queryResultCol1!)
                
                friendsList.updateValue(name, forKey: id)
                //print("Query Result:")
                //print("\(id) | \(name)")
                
            }

        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
    }

    func delete() {
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared") // Handling Errors // Try to change the table name :)
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print(errorMessage)
        }
        
        sqlite3_finalize(deleteStatement)
    }

}
