//
//  CustomErrorView.swift
//  Slexie
//
//  Created by Zafer Cavdar on 02/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class CustomErrorView {
    
    private var view = UIView()
    private var errorLabel = UILabel()
    private var frameColor = UIColor.reddishColor()
    
    func createView(errorMessage: String) -> UIView{
        
        let width = UIScreen.mainScreen().bounds.width
        
        view =  UIView(frame: CGRectMake(0, 0, width, 30))
        view.backgroundColor = frameColor
        view.alpha = 1
        
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.textAlignment = .Center
        errorLabel.font = errorLabel.font.fontWithSize(CGFloat(12.00))
        errorLabel.text = errorMessage
        errorLabel.center = view.center
        
        view.addSubview(errorLabel)
        
        return view
    }
}
