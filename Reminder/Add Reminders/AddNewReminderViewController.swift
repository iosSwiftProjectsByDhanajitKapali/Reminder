//
//  AddNewReminderViewController.swift
//  Reminder
//
//  Created by unthinkable-mac-0025 on 08/06/21.
//

import UIKit

class AddNewReminderViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var reminderTitle: UITextField!
    @IBOutlet var reminderBody: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    public var completion: ((String, String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        reminderBody.delegate = self
        reminderTitle.delegate = self
        
        datePicker.preferredDatePickerStyle = .wheels
        
    }
    
    @IBAction func saveReminderButtonPressed(_ sender: UIButton) {
        if let titleText = reminderTitle.text, !titleText.isEmpty, let bodyText = reminderBody.text, !bodyText.isEmpty {
            
            let targetDate = datePicker.date
            completion?(titleText, bodyText, targetDate)

        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
   
}
