//
//  Operator Overloads.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

func += <K, V> (inout left: Dictionary <K,V> , right: Dictionary <K,V>) {
    for (k, v) in right {
        left[k] = v
    }
}
