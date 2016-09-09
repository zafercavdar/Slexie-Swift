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
        let width: CGFloat = 200.00
        loadingView = UIView(frame: CGRect(x: view.frame.midX - CGFloat(width/2), y: view.frame.midY - 25, width: width, height: 50.00))
        loadingView.backgroundColor = UIColor.midnightBlue()
        loadingView.alpha = 1
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White )
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        textLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 150, height: 50))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = .Center
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
