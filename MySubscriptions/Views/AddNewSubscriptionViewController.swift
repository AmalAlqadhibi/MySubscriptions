//
//  AddNewSubscriptionViewController.swift
//  MySubscriptions
//
//  Created by Amal Alqadhibi on 23/06/2019.
//  Copyright © 2019 Amal Alqadhibi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddNewSubscriptionTableViewController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate , UIPickerViewDataSource , UIPickerViewDelegate {
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var imagePickedView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var subscriptionDescrip: UITextField!
    @IBOutlet weak var firstBill: UITextField! // not
    @IBOutlet weak var cycle: UITextField! //not
    @IBOutlet weak var currency: UITextField! //not
    
    let Picker = UIDatePicker()
    let CyclePicker = UIPickerView()
    let currenciesPicker = UIPickerView()
    var  firstBillDate: Date! = Date()
    var ReturnDateOfProdctTS:NSNumber! = 0.0
    let myPickerData = ["Week" , "Month" , "Years" ]
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
        super.viewDidLoad()
        createDatePicker()
        createCyclePicker()
        createCurrenciesPicker()
        CyclePicker.delegate = self
        currenciesPicker.delegate = self

      
    }
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        // to allow the user to crop the image.
        imagePicker.allowsEditing = true
        imagePicker.sourceType = (sender.tag == 0) ? .photoLibrary : .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createNewSubscription(_ sender: Any) {
         let firstBillDateTimeStamp = NSNumber(value: firstBillDate!.timeIntervalSince1970)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard firstBill.text != nil else {return}
        if price.text != "" || self.name.text != "" || firstBill.text != nil || cycle.text != "" || currency.text != ""{
            let info = ["CompanyName": self.name.text! , "SubscriptionDescrip" : self.subscriptionDescrip.text! ?? "" , "firstBill" : firstBillDateTimeStamp , "Cycle" : self.cycle.text! ,"Currency" : self.currency.text ,"Price": price.text,"userID" : uid ] as [String : Any]
        let ref = Database.database().reference().child("SubscriptionBilling").childByAutoId()
            ref.setValue(info) } else {
            //TODO Add view
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        // to add editedImage if threr is, or set originalImage
        if let image = info[.editedImage] as? UIImage {
            imagePickedView.image = image
        } else if let image = info[.originalImage] as? UIImage {
            imagePickedView.image = image
        } else{
            print("image not found!")
        }
        dismiss(animated: true, completion: nil)
    }
    func createDatePicker(){
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let Done = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(datePickerDonePressed))
        toolbar.setItems([Done], animated: false)
        firstBill.inputAccessoryView = toolbar
        firstBill.inputView = Picker
        Picker.datePickerMode = .date
        if let ReturnDateTimeStamp = self.ReturnDateOfProdctTS?.doubleValue {
            let maximumDateForPicker = NSDate(timeIntervalSince1970: ReturnDateTimeStamp)
            let currentDate = Date()
            let minimumDateForPicker = (24 * 60 * 60)*120
            let minDate = currentDate.addingTimeInterval(TimeInterval(1 * minimumDateForPicker))
            Picker.minimumDate = minDate
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
