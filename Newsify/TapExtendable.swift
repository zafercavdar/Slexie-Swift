//
//  TapExtendable.swift
//  Slexie
//
//  Created by Zafer Cavdar on 25/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

protocol TapExtendable {
    
}

extension TapExtendable where Self: HaveNetworkingController{

    func likePhoto(id: String, completion callback: (CallbackResult) -> Void){
        networkingController.photoLiked(id) { (result) in
            callback(result)
        }
    }
}


protocol HaveNetworkingController {
    var networkingController: FirebaseController {get set}
}