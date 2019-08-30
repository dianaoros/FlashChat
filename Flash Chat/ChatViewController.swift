//
//  ViewController.swift
//  Flash Chat
//
//  Created by Diana Oros on 10/20/2018.
//  Copyright (c) 2018 Diana Oros. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    // Declare instance variables here
    
    //blank array is [Messages]();  this variable is populated with message objects, set to a completely empty array for now
    var messageArray : [Message] = [Message]()
    //this is for keyboard height
    var keyHeight : CGFloat = 0
    var valueToAddToKeyboardHeight : CGFloat = 0
    let deviceModel : String = UIDevice().name
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //this is for keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //TODO: Set yourself as the delegate of the text field here:

        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        //No separator line ------- between messages
        messageTableView.separatorStyle = .none
        
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            //Messages we sent color
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        }
        else {
            //Messages we did not send ie. messages we received
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageArray.count
        
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    

    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//        UIView.animate(withDuration: 0.3){
//            self.heightConstraint.constant = 308
//            self.view.layoutIfNeeded()
//        }
//    }
    
    //this is for keyboard height
    @objc func keyboardWillShow(_ notification: Notification) {

        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {

            let keyboardRectangle = keyboardFrame.cgRectValue

            let keyboardHeight = keyboardRectangle.height

            print("KEYBOARD is \(keyboardHeight)")

            keyHeight = keyboardHeight

            print("keyHeight is \(keyHeight)")

            if self.deviceModel == "iPhone X" || self.deviceModel == "iPhone XR" || self.deviceModel == "iPhone XS" || self.deviceModel == "iPhone XS Max" {
                
                print("iPhone Model is an X series : \(self.deviceModel)")
                
                valueToAddToKeyboardHeight = 15
                
            } else {
                print("iPhone Model is NOT an X series : \(self.deviceModel)")
                valueToAddToKeyboardHeight = 50
            }

            UIView.animate(withDuration: 0.23) {

                self.heightConstraint.constant = self.keyHeight + self.valueToAddToKeyboardHeight
                
                self.view.layoutIfNeeded()



            }

        }

    }
    

    //TODO: Declare textFieldDidEndEditing here:
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        
        //firebase method childByAutoID creates a custom random key for our message so our messages can be saved under their unique keys
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil {
                print("Error!")
            }
            else {
                print("Message saved successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                
                //this restarts the text field to empty after the user pressed send to send their text. this way the massage they send won't remain in the textfield
                self.messageTextfield.text = ""
            }
        }
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    func retrieveMessages () {
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            // you can upload an UI image letting the user know there was an error (maybe their internet connction
            print("Error. There was a probem signing out")
        }
    }
    


}
