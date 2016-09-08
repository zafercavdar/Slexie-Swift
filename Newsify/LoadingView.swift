//
//  LoadingView.swift
//  Newsify
//
//  Created by Zafer Cavdar on 10/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    private var loadingView = UIView()
    private var textLabel = UILabel()
    private var activityIndicator = UIActivityIndicatorView()
    
    func addToView(view: UIView, text: String){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        loadingView = UIView(frame: CGRect(x: view.frame.midX - 110, y: view.frame.midY - 25, width: 220, height: 50))
        loadingView.backgroundColor = UIColor.midnightBlue()
        loadingView.alpha = 1
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White )
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.center.x = loadingView.center.x
        textLabel.text = text
        
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(textLabel)
        
        view.addSubview(loadingView)
        
    }
    
    func changeText(text: String){
        textLabel.text = text
    }
    
    func removeFromView(view: UIView){
        loadingView.removeFromSuperview()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
