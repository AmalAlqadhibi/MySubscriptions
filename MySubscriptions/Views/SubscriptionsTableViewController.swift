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
    // MARK: Variables
    var subscriptions = [Subscription] ()
    var keyArray = [String] ()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchRequests()
        tableView.tableFooterView = UIView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        subscriptions.removeAll()
        keyArray.removeAll()
        
    }
    func fetchRequests (){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("SubscriptionBilling")
        let refHandle = ref.queryOrdered(byChild: "userID").queryEqual(toValue: uid).observeSingleEvent(of:.value, with: { (snapshot) in
            
            for childSnapshot in snapshot.children {
                let child = childSnapshot as? DataSnapshot
                if let dictionary = child?.value as? [String : AnyObject] {
                    let subscription = Subscription()
                    subscription.currency = dictionary["Currency"] as? String
                    subscription.cycle = dictionary["Cycle"] as? String
                    subscription.name = dictionary["CompanyName"] as? String
                    subscription.SubscriptionDescrip = dictionary["CompanyName"] as? String
                    subscription.price = dictionary["Price"] as? String
                    subscription.firstBillTimeStamp = dictionary["firstBill"] as? NSNumber
                    self.calculate(subscription: subscription)
                    self.keyArray.append(child?.key ?? "")
                    self.subscriptions.append(subscription)
                    DispatchQueue.main.async {
                        ref.keepSynced(true)
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
        let detailedFirstBill = greg.dateComponents([.year,.weekday , .month, .day], from: firstBill as Date)
        let detailedtodayDate = greg.dateComponents([.year,.weekday , .month, .day], from: todayDate)
        let months = greg.dateComponents([.year, .month, .day], from:  detailedFirstBill, to: detailedtodayDate)
        switch subscription.cycle {
        case "Weekly" :
            if detailedFirstBill.weekday == detailedtodayDate.weekday {
                subscription.UntilNextBill = "Today"
            } else {
                if detailedFirstBill.weekday! > detailedtodayDate.weekday! {
                    let diffrince = detailedFirstBill.weekday! - detailedtodayDate.weekday!
                    subscription.UntilNextBill = String(diffrince) + " day(s)"
                } else {
                    let diffrince = detailedFirstBill.weekday! - detailedtodayDate.weekday!
                    subscription.UntilNextBill = String(7  - abs(diffrince)) + " day(s)"
                }
            }
        case "Monthly" :
            let afff = 30 - months.day!
            let  nextDateOfBilling = Calendar.current.date(byAdding: .day, value: afff , to: Date())
            let detailedNextDateOfBilling = greg.dateComponents([.year, .month, .day], from: nextDateOfBilling as! Date)
            let UntilNextBill = greg.dateComponents([.day], from: detailedtodayDate, to: detailedNextDateOfBilling )
            if UntilNextBill.day == 0 {
                subscription.UntilNextBill = "Tomorrow"
            } else if UntilNextBill.day == 30 {
                subscription.UntilNextBill = "Today"
            } else {
                subscription.UntilNextBill = String(UntilNextBill.day ?? 0) + " day(s)"
            }
        case "Yearly" :
            let months = greg.dateComponents([.day], from:  detailedFirstBill, to: detailedtodayDate)
            let afff = 365 - months.day!
            let  nextDateOfBilling = Calendar.current.date(byAdding: .day, value: afff , to: Date())
            let detailedNextDateOfBilling = greg.dateComponents([.year, .month, .day], from: nextDateOfBilling as! Date)
            let UntilNextBill = greg.dateComponents([.day], from: detailedtodayDate, to: detailedNextDateOfBilling )
            if UntilNextBill.day == 0 || UntilNextBill.day == 365{
                subscription.UntilNextBill  = "Today"
            } else {
                subscription.UntilNextBill = String(UntilNextBill.day ?? 0) + " day(s)"
            }
        default :
            subscription.UntilNextBill = "Error"
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try! Auth.auth().signOut()
            if Auth.auth().currentUser == nil {
                let presentMemeEditorVC = storyboard?.instantiateViewController(withIdentifier: "mainPage") as! FirstPageViewController
                present(presentMemeEditorVC, animated: true, completion: nil)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subscriptions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Subscription", for: indexPath) as! SubscriptionTableViewCell
        let subscriptionBill = subscriptions[indexPath.row]
        cell.firstBill.text = subscriptionBill.UntilNextBill
        cell.companyName.text = subscriptionBill.name
        if let subscriptionBill = subscriptionBill.UntilNextBill {
            cell.firstBill.text = subscriptionBill
        }
        if let price = subscriptionBill.price ,let currency = subscriptionBill.currency {
            cell.subscriptionPrice.text = price + " " + currency
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let information = keyArray[indexPath.row]
        performSegue(withIdentifier: "ShowDetails", sender: information)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails" {
            let controller = segue.destination as! BillDetailsViewController
            controller.BillKey = sender as! String
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                let ref = Database.database().reference()
                ref.child("SubscriptionBilling").child(self.keyArray[indexPath.row]).removeValue()
                self.subscriptions.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                self.keyArray.remove(at: indexPath.row)
                tableView.reloadData()
            })
        }}
}
