//
//  TableViewController.swift
//  SQLite
//
//  Created by JongHyuk Park on 2022/06/26.
//

import UIKit
import SQLite3 // <----

class TableViewController: UITableViewController {

    @IBOutlet var tvListView: UITableView!
    
    var db: OpaquePointer?
    var studentsList : [Students] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SQLite 생성하기
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("StudentsData.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //sid AUTOINCREMENT라서 신경안써도 됨
        //sname
        //sdept
        //sphone 위의 세개만 신경쓰면 된다.
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS students (sid INTEGER PRIMARY KEY AUTOINCREMENT, sname TEXT, sdept TEXT, sphone TEXT)", nil, nil, nil) != SQLITE_OK {
            //에러메시지를 가져올거다.
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("err creating table : \(errmsg)")
        }
        
        // Temporary Insert
        tempInsert()
        
        //DB 내용 불러오기
        readValues()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func tempInsert() {
        var stmt : OpaquePointer?
        //아래 문장은 한글로 할 거면 필요함. 영어로 할거면 굳이 안써도 됨
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        //sqlite3타입에는 없는 타입이니까 우리타입으로 쓸거야~ 하고 정의해둔것.
        
        //스위프트는 sql을 모르기 때문에 타입 그대로 넣는 것은 불가하다.
        //문장 만들어준다.
        let queryString = "INSERT INTO Students (sname, sdept, sphone) VALUES (?,?,?)"
        
        //SQL문장을 통신 프로그램으로 바꿔주는애가 prepare. prepare가 필요하다.
        // -1은 바이트수를 모른다는 의미
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            //prepare를 못하면 에러가 걸림.
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error preparing insert : \(errmsg)")
            return
        }
        
        // 두번째 인자가 각 순서가 된다. 각 물음표에 들어갈 데이터를 넣는다.
        sqlite3_bind_text(stmt, 1, "유비", -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, "컴퓨터공학과", -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, "1234", -1, SQLITE_TRANSIENT)
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("failure inserting : \(errmsg)")
            return
        }
        
        print("Student saved successfully!")
    }
    
    func readValues() {
        studentsList.removeAll()//리스트에 있는걸 지우고 시작하자.
        
        let queryString = "SELECT * FROM students"
        
        var stmt : OpaquePointer? //statement의 축약
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("error preparing select : \(errmsg)")
            return
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let dept = String(cString: sqlite3_column_text(stmt, 2))
            let phone = String(cString: sqlite3_column_text(stmt, 3))
            
            print(id, name, dept, phone)
            //SQL은 32비트 64비트 쓰지만,
            //얘는 32비트인줄 안다. 어쨌든 자동 형변환이 안되므로 직접 캐스팅해줘야함
            studentsList.append(Students(id: Int(id), name: name, dept: dept, phone: phone))
            
        }
        
        self.tvListView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "학번 : \(studentsList[indexPath.row].id)"
        cell.detailTextLabel?.text = "성명 : \(studentsList[indexPath.row].name!)"
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
