//
//  Students.swift
//  SQLite
//
//  Created by JongHyuk Park on 2022/06/26.
//

import Foundation

class Students {
    var id : Int
    var name : String?
    var dept : String?
    var phone : String
    
    init(id : Int, name : String?, dept : String?, phone: String?) {
        self.id = id
        self.name = name
        self.dept = dept
        self.phone = phone
    }
}
