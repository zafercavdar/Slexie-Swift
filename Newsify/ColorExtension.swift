//
//  ColorExtension.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func coreColor() -> UIColor {
        return UIColor.blackColor()
    }
    
    static func reddishColor() -> UIColor {
        return UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0 , blue: 48.0 / 255.0, alpha: 1)
    }
    
    static func greenishColor() -> UIColor {
        return UIColor(red: 39.0 / 255.0, green: 174.0 / 255.0 , blue: 96.0 / 255.0, alpha: 1)
    }
    
    static func tableBackgroundGray() -> UIColor {
        return UIColor(red: 240.0 / 255.0, green: 240.0 / 255.0 , blue: 240.0 / 255.0, alpha: 1)
    }
    
    static func headerTitleGray() -> UIColor {
        return UIColor(red: 120.0 / 255.0, green: 120.0 / 255.0 , blue: 120.0 / 255.0, alpha: 1)
    }
    
    static func flatBlue() -> UIColor {
        return UIColor(red: 52.0 / 255.0, green: 152.0 / 255.0 , blue: 219.0 / 255.0, alpha: 1)    
    }
    
}