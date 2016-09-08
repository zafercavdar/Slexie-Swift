//
//  CreateAccountViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 06/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class CreateAccountViewModel{
    
    struct State{
        
        var loadingState = LoadingState()
        
        enum Change: Equatable{
            case none
            case signUpAttemp(CallbackResult)
            case error(String)
            case cancel
            case loading(LoadingState)
        }
        
        mutating func addActivity() -> Change {
            
            loadingState.addActivity()
            return Change.loading(loadingState)
        }
        
        mutating func removeActivity() -> Change {
            
            loadingState.removeActivity()
            return .loading(loadingState)
        }
        
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    private var authController = FirebaseController()
    
    func signUpWithUsernamePassword(email: String, _ password: String, _ username: String, _ profileType: String, language: String){
        
        emit(state.addActivity())
        
        authController.signUp(email, username: username, password: password, profileType: profileType, language: language) { [weak self](error) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.emit(strongSelf.state.removeActivity())
            
            if let error = error {
                strongSelf.emit(State.Change.error(error.localizedDescription))
            } else {
                strongSelf.emit(State.Change.signUpAttemp(CallbackResult.Success))
            }
        }
    }
    
    func cancelPressed(){
        emit(State.Change.cancel)
    }
}

private extension CreateAccountViewModel{
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }

}

func ==(lhs: CreateAccountViewModel.State.Change, rhs: CreateAccountViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.loading(let loadingState1), .loading(let loadingState2)):
        return loadingState1.activityCount == loadingState2.activityCount
    default:
        return false
    }
}
