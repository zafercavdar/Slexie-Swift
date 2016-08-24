//
//  Router.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

protocol Router {
    
    func routeTo(routeID: String, VC: UIViewController) -> Void
}
