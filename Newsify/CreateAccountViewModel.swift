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
        
        enum Change{
            case none
            case signUpAttemp(CallbackResult)
            case loadingView
            case removeView
            case error(String)
            case cancel
        }
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    private var authController = FirebaseController()
    
    func signUpWithUsernamePassword(email: String, _ password: String, _ username: String, _ profileType: String, language: String){
        
        emit(State.Change.loadingView)
        
        authController.signUp(email, username: username, password: password, profileType: profileType, language: language) { [weak self](error) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.emit(State.Change.removeView)
            
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