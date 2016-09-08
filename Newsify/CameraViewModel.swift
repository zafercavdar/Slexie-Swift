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
        
        enum Change: Equatable{
            case none
            case tags(CollectionChange)
            case photo
            case loadingView(String)
            case removeView
            case upload(NSError?)
        }
        
        mutating func reloadTags(picTags: [String]) -> Change{
            self.post.trustedTags = picTags
            return Change.tags(.reload)
        }
        
        mutating func updatePhoto(data: NSData) -> Change{
            self.post.imageData = data
            return Change.photo
        }
        
        func showLoadingView(text: String) -> Change {
            return Change.loadingView(text)
        }
    }
    
    private(set) var state = State()
    private let imaggaService = ImaggaService()
    private let controller = FirebaseController()

    var stateChangeHandler: ((State.Change) -> Void)?

    
    func fetchImageTags(image: UIImage, completion callback: (tags: [String]) -> Void) {
        
        self.emit(self.state.showLoadingView(localized("AnalyzingInfo")))
        
        let rate = state.post.compressionRate
        
        if let imageData = UIImageJPEGRepresentation(image, rate) {
            
            self.emit(self.state.updatePhoto(imageData))
            
            imaggaService.uploadPhotoGetContentID(imageData, completion: { [weak self] (id) in
                
                guard let strongSelf = self else { return }
                
                strongSelf.state.post.contentID = id
                
                strongSelf.imaggaService.findRelatedTagsWith(contentID: id, completion: { [weak self] (tags) in
                    
                    guard let sself = self else {return}
                    sself.emit(State.Change.removeView)
                    sself.emit(sself.state.reloadTags(tags))
                    callback(tags: tags)
                    })
                })
        }
    }
    
    func uploadData(imageData: NSData, tags: [String]){
        
        emit(state.showLoadingView(localized("UploadingInfo")))
        
        controller.uploadPhoto(imageData, tags: tags) { [weak self] (error, photoID, url) in
            self?.emit(State.Change.upload(error))
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

func ==(lhs: CameraViewModel.State.Change, rhs: CameraViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.tags(let update1), .tags(let update2)):
        switch (update1, update2) {
        case (.reload, .reload):
            return true
        default:
            return false
        }
    case (.photo, .photo):
        return true
    case (.loadingView(let text1) ,.loadingView(let text2)):
        return text1 == text2
    case (.removeView, .removeView):
        return true
    case (.upload(let error1), .upload(let error2)):
        return error1 == error2
    default:
        return false
    }
}

