//
//  NotificationController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 12/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func signInFailedNotification(error: String){
        self.showAlertView("Error", message: "Sign in failed. \(error)", duration: 3)
    }
    
    func fillAllFields() {
        showAlertView("Caution!", message: "Fill both of the fields!", duration: 3)
    }
    
    func signUpFailedNotification(error: String) {
        showAlertView("Error", message: "Sign up failed. \(error)", duration: 3)
    }
    
    func passwordsDoNotMatch(){
        showAlertView("Caution!", message: "Both passwords should be same ...", duration: 3)
    }
    
    func showAlertView(title: String?, message: String?, duration: Int) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        /*let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(duration) * Double(NSEC_PER_SEC)))
         dispatch_after(delayTime, dispatch_get_main_queue()) {
         print("Bye. Lovvy")
         alertController.dismissViewControllerAnimated(true, completion: nil)
         }*/
    }
}