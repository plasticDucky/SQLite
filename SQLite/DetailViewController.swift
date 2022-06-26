//
//  DetailViewController.swift
//  SQLite
//
//  Created by JongHyuk Park on 2022/06/26.
//

import UIKit
import SQLite3 // <---

class DetailViewController: UIViewController {

    
    @IBOutlet weak var tfId: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfDept: UITextField!
    @IBOutlet weak var tfTel: UITextField!
    
    fileprivate var receiveID = 0
    fileprivate var receiveName = ""
    fileprivate var receiveDept = ""
    fileprivate var receivePhone = ""
    
    var db : OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfId.text = String(receiveID)
        tfId.isUserInteractionEnabled = false // Read Only
        tfName.text = receiveName
        tfDept.text = receiveDept
        tfTel.text = receivePhone
        
        // Do any additional setup after loading the view.
        // SQLite 생성하기
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("StudentsData.sqlite")
        
        sqlite3_open(fileURL.path, &db)
    }
    
    func receiveItems(_ id: Int, _ name: String, _ dept: String, _ phone: String) {
        receiveID = id
        receiveName = name
        receiveDept = dept
        receivePhone = phone
    }
    
    
    @IBAction func btnUpdate(_ sender: UIButton) {
        
        var stmt : OpaquePointer?
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
        let id : String = tfId.text!
        let name = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let dept = tfDept.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let tel = tfTel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let queryString = "UPDATE students SET sname = ?, sdept = ?, sphone = ? WHERE sid = ?"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_text(stmt, 1, name, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, dept, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, tel, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 4, Int32(id)!)
        sqlite3_step(stmt)
        
        let resultAlert = UIAlertController(title: "결과", message: "수정 되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네, 알겠습니다.", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        
        resultAlert.addAction(okAction)
        present(resultAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func btnDelete(_ sender: UIButton) {
        var stmt : OpaquePointer?
        
        let id : String = tfId.text!

        let queryString = "DELETE FROM students WHERE sid = ?"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        sqlite3_bind_int(stmt, 1, Int32(id)!)
        sqlite3_step(stmt)
        
        let resultAlert = UIAlertController(title: "결과", message: "삭제 되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네, 알겠습니다.", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        
        resultAlert.addAction(okAction)
        present(resultAlert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
