//
//  BillDetailsViewController.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 26/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import Firebase
class BillDetailsViewController: UIViewController , UIPickerViewDataSource , UIPickerViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var subscriptionDescrip: UITextField!
    @IBOutlet weak var firstBill: UITextField!
    @IBOutlet weak var cycle: UITextField!
    @IBOutlet weak var currency: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var successMessage: UILabel!
    // MARK: Variables
    var BillKey:String?
    var  firstBillDate: Date! = Date()
    var maximun:NSNumber! = 0.0
    let Picker = UIDatePicker()
    let CyclePicker = UIPickerView()
    let currenciesPicker = UIPickerView()
    let myPickerData = ["Weekly" , "Monthly" , "Yearly" ]
    var currencies: [String]  {
        var arrayOfCountries: [String] = []
        for code in NSLocale.isoCurrencyCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            arrayOfCountries.append(name)
        }
        return arrayOfCountries
    }
    
    override func viewDidLoad() {
        successMessage.isHidden = true
        super.viewDidLoad()
        fetchBillDetails()
        price.setBorder()
        name.setBorder()
        subscriptionDescrip.setBorder()
        firstBill.setBorder()
        cycle.setBorder()
        currency.setBorder()
        createDatePicker()
        createCyclePicker()
        createCurrenciesPicker()
        CyclePicker.delegate = self
        currenciesPicker.delegate = self
    }
    @IBAction func cancelOnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func fetchBillDetails(){
        self.activityIndicator.startAnimating()
        Database.database().reference().child("SubscriptionBilling").child(BillKey!).observeSingleEvent(of: .value, with:{(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.name.text = dictionary["CompanyName"] as? String
                self.currency.text = dictionary["Currency"] as? String
                self.cycle.text  = dictionary["Cycle"] as? String
                self.price.text = dictionary["Price"] as? String
                self.subscriptionDescrip.text = dictionary["SubscriptionDescrip"] as? String
                let firstDate = dictionary["firstBill"] as? Double
                 self.firstBillDate = Date(timeIntervalSince1970: firstDate!)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                let dateString = formatter.string(from: self.firstBillDate)
                self.firstBill.text = "\(dateString)"
            }}, withCancel: nil)
        activityIndicator.stopAnimating()
    }
    @IBAction func updateSubscription(_ sender: Any) {
        self.activityIndicator.startAnimating()
        let firstBillDateTimeStamp = NSNumber(value: firstBillDate!.timeIntervalSince1970)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard firstBill.text != nil else {return}
        if price.text != "" && self.name.text != "" && firstBill.text != nil && cycle.text != "" && currency.text != ""{
            let info = ["CompanyName": self.name.text! , "SubscriptionDescrip" : self.subscriptionDescrip.text! ?? "" , "firstBill" : firstBillDateTimeStamp , "Cycle" : self.cycle.text! ,"Currency" : self.currency.text ,"Price": price.text,"userID" : uid ] as [String : Any]
            let ref = Database.database().reference().child("SubscriptionBilling").child(BillKey!)
            //updateChildValues
            ref.updateChildValues(info)
            self.activityIndicator.stopAnimating()
            successMessage.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.successMessage.isHidden = true
            }
        } else {
            activityIndicator.stopAnimating()
            alert(title: "Oops!", message: "Please make sure you type all details")
        }
    }
    //MARK:- Method that dealing with Pickers
    
    func createDatePicker(){
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let Done = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(datePickerDonePressed))
        Done.tintColor = UIColor(red:158/255, green:12/255, blue: 57/255, alpha:1)
        toolbar.setItems([Done], animated: false)
        firstBill.inputAccessoryView = toolbar
        firstBill.inputView = Picker
        Picker.datePickerMode = .date
        if let maximunDate = self.maximun?.doubleValue {
            let maximumDateForPicker = NSDate(timeIntervalSince1970: maximunDate)
            let currentDate = Date()
            Picker.minimumDate = currentDate
            Picker.maximumDate = maximumDateForPicker as Date
        }
    }
    
    func createCyclePicker(){
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        // Button
        let Done = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(donePressed))
        toolbar.setItems([Done], animated: false)
        Done.tintColor = UIColor(red:158/255, green:12/255, blue: 57/255, alpha:1)
        cycle.inputAccessoryView = toolbar
        cycle.inputView = CyclePicker
    }
    @objc func datePickerDonePressed(){
        // date Format
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        firstBillDate = Picker.date
        let dateString = formatter.string(from: Picker.date)
        firstBill.text = "\(dateString)"
        self.view.endEditing(true)
    }
    @objc func donePressed(){
        self.view.endEditing(true)
    }
    
    func createCurrenciesPicker(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let Done = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(donePressed))
        toolbar.setItems([Done], animated: false)
        Done.tintColor = UIColor(red:158/255, green:12/255, blue: 57/255, alpha:1)
        currency.inputAccessoryView = toolbar
        currency.inputView = currenciesPicker
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if   pickerView == CyclePicker {
            return myPickerData.count
        } else if pickerView == currenciesPicker {
            return currencies.count
        }
        return 0
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == CyclePicker {
            return myPickerData[row]
        } else if  pickerView == currenciesPicker {
            return currencies[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView == CyclePicker {
            self.cycle.text = myPickerData[row]
        } else if pickerView == currenciesPicker {
            self.currency.text = currencies[row]
        }
    }
    
    
}
