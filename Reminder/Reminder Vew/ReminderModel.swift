//
//  ReminderModel.swift
//  Reminder
//
//  Created by unthinkable-mac-0025 on 08/06/21.
//

import Foundation

//struct ReminderModel : Codable{
//    let title : String
//    let body : String
//    let date : Date
//}

class ReminderModel: NSObject, NSCoding {
    
    var title : String?
    var body : String?
    var date : Date?
    
    init(json: [String: Any])
    {
        self.title = json["title"] as? String
        self.body = json["body"] as? String
        self.date = json["date"] as? Date
    }
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.body, forKey: "body")
        aCoder.encode(self.date, forKey: "date")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.body = aDecoder.decodeObject(forKey: "body") as? String
        self.date = aDecoder.decodeObject(forKey: "date") as? Date
    }
    
}
