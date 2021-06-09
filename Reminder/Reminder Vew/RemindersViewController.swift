//
//  ViewController.swift
//  Reminder
//
//  Created by unthinkable-mac-0025 on 08/06/21.
//

import UIKit
import UserNotifications

class RemindersViewController: UIViewController , UNUserNotificationCenterDelegate{

    @IBOutlet var remindersTableView: UITableView!
    
    var remindersArray = [ReminderModel]()
    
    //1)register the notification center
    let notificationCenter =  UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        remindersTableView.delegate = self
        remindersTableView.dataSource = self
        
        notificationCenter.delegate = self
        
        //getting data from UserDefaults
        var decodedArray : [ReminderModel] = []
        if let items = UserDefaults.standard.object(forKey: "items"){
            let data = items as! Data
            let decodedData = NSKeyedUnarchiver.unarchiveObject(with: data)
            decodedArray =  decodedData as! [ReminderModel]
        }
            
       

        remindersArray = decodedArray
        remindersTableView.reloadData()
        //print("\(decodedArray[0].title)\(decodedArray[1].title)")
        
        
        //getting permission from user for showing notification
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (permissionGranted, error) in
            if permissionGranted{
                //
            }else if let err = error{
                print("Error getting Ntification Permission \(err)")
            }
        }
    }

    //initializing a TEST notification via button
    @IBAction func testButtonPressed(_ sender: UIBarButtonItem) {
        //2)setting the content
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.sound = .default
        content.body = "This is the body of the test Notification"
        
        //3)adding the trigger
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate),repeats: false)
        
        //4)adding the request
        let request = UNNotificationRequest(identifier: "testNotificationID", content: content, trigger: trigger)
        
        //5)registering the request
        notificationCenter.add(request) { (error) in
            if error != nil{
                print("Error adding the notification")
            }
        }
       
    }
    
    @IBAction func addNewReminderButtonPressed(_ sender: UIBarButtonItem) {
        guard let destinationVC = storyboard?.instantiateViewController(identifier: "addNewReminderVCID") as? AddNewReminderViewController else {
            return
        }
        destinationVC.title = "Add New Reminder"
        destinationVC.navigationItem.largeTitleDisplayMode = .never
        destinationVC.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                
                let newReminder = ReminderModel(json: ["title" : title, "body" : body, "date" : date])
    
                //inserting into the UserDefaults
                self.remindersArray.append(newReminder)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.remindersArray)
                UserDefaults.standard.set(encodedData, forKey: "items")
                
                //adding newReminder to the Local Array
                
                self.remindersTableView.reloadData()
                
                //adding the content of notification
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = body

                //adding trigger time
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate),repeats: false)
                
                //adding request to notification center
                let request = UNNotificationRequest(identifier: "id_\(title)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("something went wrong")
                    }
                })
                
                //add action to notification
                let delete = UNNotificationAction.init(identifier: "Delete", title: "Delete", options: .destructive)
                let category = UNNotificationCategory.init(identifier: content.categoryIdentifier, actions: [delete], intentIdentifiers: [], options: [])
                self.notificationCenter.setNotificationCategories([category])
                
            } //:Dispatch Queue
        } //:completion handler
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    
    //to manage notifcation when the app running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("app in foregorund, initiating local notification")
        completionHandler([.banner, .badge, .sound])
    }
    
    //to manage the clicks on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("notification clicked")
        let title = response.notification.request.content.title
        showToast(message: "Deleting Reminder ")
        remindersArray.removeAll{ value in
            return value.title == "\(title)"
        }
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: remindersArray)
        UserDefaults.standard.set(encodedData, forKey: "items")
        remindersTableView.reloadData()
        
        completionHandler()
    }
    
}

//MARK: - TableView Delegate and DataSource methods
extension RemindersViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = remindersTableView.dequeueReusableCell(withIdentifier: "remindersCellID", for: indexPath)
        
        cell.textLabel?.text = remindersArray[indexPath.row].title
        
        //adding the date in the cell
        let date = remindersArray[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY"
        let formatedDate = formatter.string(from: date!)
        cell.detailTextLabel?.text = formatedDate
        
        //changing the font/size of the cell items
        cell.textLabel?.font = UIFont(name: "Arial", size: 25)
        cell.detailTextLabel?.font = UIFont(name: "Arial", size: 22)

        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            //remove pending notification
            let notificationID = "id_" + remindersArray[indexPath.row].title!
            print(notificationID)
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationID])
            
            //remove delivered notification
            //notificationCenter.removeDeliveredNotifications(withIdentifiers: [notificationID])
            
            remindersArray.remove(at: indexPath.row)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: remindersArray)
            UserDefaults.standard.set(encodedData, forKey: "items")
            
            remindersTableView.reloadData()
        }
    }
    
    
}

extension RemindersViewController{
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

