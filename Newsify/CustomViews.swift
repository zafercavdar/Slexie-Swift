//
//  CustomViews.swift
//  Slexie
//
//  Created by Zafer Cavdar on 02/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit


class CustomErrorView: CustomView{
    var frameColor = UIColor.reddishColor()
}

class CustomDoneView: CustomView{
    var frameColor = UIColor.greenishColor()
}

protocol CustomView {
    var frameColor: UIColor {get set}
}

extension CustomView{
    
    mutating func createView(textMessage: String) -> UIView{
        
        var view = UIView()
        var textLabel = UILabel()
        
        let width = UIScreen.mainScreen().bounds.width
        view = UIView(frame: CGRectMake(0, 0, width, 30))
        view.backgroundColor = frameColor
        view.alpha = 1
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = .Center
        textLabel.font = textLabel.font.fontWithSize(CGFloat(12.00))
        textLabel.text = textMessage
        textLabel.center = view.center
        
        view.addSubview(textLabel)
        return view
    }
}

