//
//  ThirdViewController.swift
//  furnitureApp
//
//  Created by Jordan on 04/02/2020.
//  Copyright © 2020 Jordan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Braintree
class ThirdViewController: UIViewController{
    
    var braintreeClient: BTAPIClient!
   
    var getOrderRef = Database.database().reference()
    var databaseHandle:DatabaseHandle?
    
    var getOrderData:DatabaseHandle?
    
    @IBOutlet weak var orderIDLabel: UILabel!

    @IBAction func sendEmail(_ sender: Any) {
        
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let request = BTPayPalRequest(amount: "2.32")
        request.currencyCode = "MYR" // Optional; see BTPayPalRequest.h for more options

        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")

                // Access additional information
                let email = tokenizedPayPalAccount.email
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone

                // See BTPostalAddress.h for details
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
                
                //Once payment success will send an email
                self.getOrderData = self.getOrderRef.child("Customer").queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                    let orderID = snapshot.childSnapshot(forPath: "orderID").value as! String
                    let detail = snapshot.childSnapshot(forPath: "detail").value as! String
                    let orderName = snapshot.childSnapshot(forPath: "order_name").value as! String
                    let phNo = snapshot.childSnapshot(forPath: "ph_no").value as! String
                    let img = snapshot.childSnapshot(forPath: "image").value as! String
                    let email = snapshot.childSnapshot(forPath: "email").value as! String

                    let smtpSession = MCOSMTPSession()
                    smtpSession.hostname = "smtp.gmail.com"
                    smtpSession.username = "junming518@gmail.com"
                    smtpSession.password = "no5377890l"
                    smtpSession.port = 465
                    smtpSession.authType = MCOAuthType.saslPlain
                    smtpSession.connectionType = MCOConnectionType.TLS
                    smtpSession.connectionLogger = {(connectionID, type, data) in
                        if data != nil {
                            if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                                NSLog("Connectionlogger: \(string)")
                            }
                        }
                    }
                    let builder = MCOMessageBuilder()
                    builder.header.to = [MCOAddress(displayName: orderName, mailbox: email)]
                    builder.header.from = MCOAddress(displayName: "Jordan furniture app", mailbox: "junming518@gmail.com")
                    builder.header.subject = "Order ID : \(orderID)"
                    builder.htmlBody="</br>Additional detail: \(detail) </br> Phone number: \(phNo) </br> Image URL : \(img)</br> Token id: \(tokenizedPayPalAccount.nonce) </br>"
                    


                    let rfc822Data = builder.data()
                    let sendOperation = smtpSession.sendOperation(with: rfc822Data)
                    sendOperation?.start { (error) -> Void in
                        if (error != nil) {
                            NSLog("Error sending email: \(error)")

                        } else {
                            NSLog("Successfully sent email!")
                        }
                    }
                }
                
            } else if let error = error {
                // Handle error here...
            } else {
                // Buyer canceled payment approval
            }
        }
     
      
    }
    
        override func viewDidLoad() {
            super.viewDidLoad()

            braintreeClient = BTAPIClient(authorization: "sandbox_gp3qm9yz_87qhmtfcnwtmc7vy")!
            // Do any additional setup after loading the view.
            getOrderID()
            
        }
    
        func getOrderID(){
            databaseHandle = getOrderRef.child("Customer").queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
            // To get query of order id
                let orderID = snapshot.childSnapshot(forPath: "orderID").value as! String
                
                self.orderIDLabel.text = orderID
                
                print(orderID)
            }
            
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

extension ThirdViewController : BTViewControllerPresentingDelegate{
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
    
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {

    }
    
    
}

extension ThirdViewController : BTAppSwitchDelegate{
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
  
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
    
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
    
    }
    
    
}
