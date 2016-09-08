//
//  VC Extensions.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

extension UITableView{
    
    func scrollToTop(animated: Bool) {
        setContentOffset(CGPointZero, animated: animated)
    }
}