//
//  CameraViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class CameraViewModel {
    
    struct Image {
        var contentID: String = ""
        var imageData = NSData()
        let compressionRate = CGFloat(0.5)
        var trustedTags: [String] = []
        var userTags: [String] = []
    }

    struct State {
        var post = Image()
        
        enum Change{
            case none
            case tags(CollectionChange)
        }
        
        mutating func reloadTags(picTags: [String]) -> Change{
            self.post.trustedTags = picTags
            return Change.tags(.reload)
        }
    }
    
    private(set) var state = State()
    private let imaggaService = ImaggaService()

    var stateChangeHandler: ((State.Change) -> Void)?

    
    func fetchImageTags(image: UIImage, completion callback: () -> Void) {
        
        let rate = state.post.compressionRate
        
        if let imageData = UIImageJPEGRepresentation(image, rate) {
            
            state.post.imageData = imageData
            
            imaggaService.uploadPhotoGetContentID(imageData, completion: { [weak self] (id) in
                
                guard let strongSelf = self else { return }
                
                strongSelf.state.post.contentID = id
                
                strongSelf.imaggaService.findRelatedTagsWith(contentID: id, completion: { [weak self] (tags) in
                    
                    guard let sself = self else {return}
                    sself.state.post.trustedTags = tags
                    sself.emit(State.Change.tags(CollectionChange.reload))
                    callback()
                    })
                })
        }
    }
    
    func addTagByUser(tag: String){
        state.post.userTags += [tag]
        self.emit(State.Change.tags(CollectionChange.reload))
    }
    
    func removeTagByUser(at index: Int) {
        state.post.userTags.removeAtIndex(index)
        self.emit(State.Change.tags(CollectionChange.reload))
    }
    
    func removeAutoTag(at index: Int){
        state.post.trustedTags.removeAtIndex(index)
        self.emit(State.Change.tags(CollectionChange.reload))
    }
    
    func resetImage(){
        self.state.post.trustedTags = []
        self.state.post.userTags = []
        self.state.post.contentID = ""
        self.state.post.imageData = NSData()
        self.emit(State.Change.tags(.reload))
    }
    
}

private extension CameraViewModel{
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}