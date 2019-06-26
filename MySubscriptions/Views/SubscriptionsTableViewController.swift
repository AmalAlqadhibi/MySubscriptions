//
//  SubscriptionsTableViewController.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 24/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SubscriptionsTableViewController: UITableViewController {
      var subscriptions = [Subscription] ()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRequests()
        print(subscriptions.count)
//        tableView.tableFooterView = UIView()
    }
    func fetchRequests (){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("SubscriptionBilling")
        let refHandle = ref.queryOrdered(byChild: "userID").queryEqual(toValue: uid).observeSingleEvent(of:.value, with: { (snapshot) in
//            print(snapshot)
            print(uid)
                    
            for childSnapshot in snapshot.children {
                let child = childSnapshot as? DataSnapshot
                if let dictionary = child?.value as? [String : AnyObject] {
                    print(dictionary)
                    let subscription = Subscription()
                    subscription.currency = dictionary["Currency"] as? String
                    subscription.cycle = dictionary["Cycle"] as? String
                    subscription.name = dictionary["CompanyName"] as? String
                    subscription.SubscriptionDescrip = dictionary["CompanyName"] as? String
                    subscription.price = dictionary["Price"] as? String
                    subscription.firstBillTimeStamp = dictionary["firstBill"] as? NSNumber
                    // func
                    self.calculate(subscription: subscription)
                    self.subscriptions.append(subscription)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }}
        })
    }

    func  calculate(subscription: Subscription){
        guard let firstBillTimeStamp = subscription.firstBillTimeStamp?.doubleValue else { return }
        let firstBill = NSDate(timeIntervalSince1970: firstBillTimeStamp)
        let greg = Calendar(identifier: .gregorian)
        let todayDate = Date()
        // calculate the duration between today and first billed date
        let detailedFirstBill = greg.dateComponents([.year, .month, .day], from: firstBill as Date)
        let detailedtodayDate = greg.dateComponents([.year, .month, .day], from: todayDate)
        let months = greg.dateComponents([.day], from: detailedtodayDate, to: detailedFirstBill)
        let afff = 30 - months.day!
        let  nextDateOfBilling = Calendar.current.date(byAdding: .day, value: afff , to: Date())
//        let numberOfDays = months.day ?? 0
//        print(numberOfDays)
//        let nextDateOfBilling = todayDate.addingTimeInterval(TimeInterval((24 * 60 * 60)*numberOfDays))
        let detailedNextDateOfBilling = greg.dateComponents([.year, .month, .day], from: nextDateOfBilling as! Date)
        let UntilNextBill = greg.dateComponents([.day], from: detailedNextDateOfBilling, to: detailedFirstBill)
       
        subscription.UntilNextBill = String(UntilNextBill.day ?? 0) + "Day(s)" 
    }
    
    
    
    
    
    
    
    // MARK: - Table view data source

  

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(subscriptions.count)
        // #warning Incomplete implementation, return the number of rows
        return subscriptions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Subscription", for: indexPath) as! SubscriptionTableViewCell
        let subscriptionBill = subscriptions[indexPath.row]
        cell.firstBill.text = "hi"
        cell.companyName.text = subscriptionBill.name
        if let subscriptionBill = subscriptionBill.UntilNextBill {
            cell.firstBill.text = String(subscriptionBill) + " day(s)"
        }
       if let price = subscriptionBill.price ,let currency = subscriptionBill.currency {
        cell.subscriptionPrice.text = price + "" + currency
        }
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
