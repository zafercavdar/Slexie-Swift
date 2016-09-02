//
//  PrivacyPolicyViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 02/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class PrivacyPolicyViewModel{
    
    func fetchPolicyFilePath(completion callback: (url: NSURL) -> Void){
        let localFilePath = NSBundle.mainBundle().URLForResource("Policy", withExtension: "html")
        callback(url: localFilePath!)
    }
    
}

class PrivacyPolicyViewController: UIViewController {

    private var webView =  UIWebView()
    private var model = PrivacyPolicyViewModel()
    private let router = PolicyPageRouter()
    
    private var backButton = UIBarButtonItem()
    
    private struct RouteID{
        static let Back = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView =  UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        
        backButton = UIBarButtonItem(image: UIImage(named: "backButton"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backButtonPressed(_:)))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        model.fetchPolicyFilePath { (url) in
            self.webView.loadRequest(NSURLRequest(URL: url))
            self.view.addSubview(self.webView)
        }
    }
    
    func backButtonPressed(sender: UIBarButtonItem){
        self.router.routeTo(RouteID.Back, VC: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIColors()
        setUITitles()
    }
    
    private func setUIColors(){
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
    }
    
    private func setUITitles(){
        self.title = "Privacy Policy"
    }

}
