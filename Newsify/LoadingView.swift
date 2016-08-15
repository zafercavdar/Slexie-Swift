//
//  LoadingView.swift
//  Newsify
//
//  Created by Zafer Cavdar on 10/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    var loadingView = UIView()
    var textLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    
    func addToView(view: UIView, text: String){
        loadingView = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25, width: 180, height: 50))
        loadingView.backgroundColor = UIColor.blackColor()
        loadingView.alpha = 0.8
        loadingView.layer.cornerRadius = 10
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White )
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        textLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.whiteColor()
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
    }

}
