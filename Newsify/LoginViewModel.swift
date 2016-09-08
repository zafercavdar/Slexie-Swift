//
//  LoginViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 06/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class LoginViewModel{

    struct State{
        
        var loadingState = LoadingState()
        
        enum Change: Equatable{
            case none
            case loginAttemp(CallbackResult)
            case loggedIn(CallbackResult)
            case loading(LoadingState)
            case error(String)
            case redirectSignup
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
    
    func checkUserLoginStatus(){
        if authController.getCurrentUser() != nil {
            
            emit(state.addActivity())
            
            self.authController.fetchUserLanguage(completion: { (identifier) in
                switch identifier{
                case LanguageIdentifier.Turkish.rawValue, LanguageIdentifier.English.rawValue, LanguageIdentifier.Russian.rawValue:
                    lang = identifier
                default:
                    lang = LanguageIdentifier.English.rawValue
                }
                
                self.emit(self.state.removeActivity())
                self.emit(State.Change.loggedIn(CallbackResult.Success))
            })
        }
    }
    
    func loginWithUsername(username: String, _ password: String){
        
        emit(state.addActivity())
        
        authController.signInWith(username: username, password: password, enableNotification: true) { [weak self](error) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.emit(strongSelf.state.removeActivity())
            
            if let error = error {
                strongSelf.emit(State.Change.error(error.localizedDescription))
            } else {
                strongSelf.authController.fetchUserLanguage(completion: { (identifier) in
                    switch identifier{
                    case LanguageIdentifier.Turkish.rawValue, LanguageIdentifier.English.rawValue, LanguageIdentifier.Russian.rawValue:
                        lang = identifier
                    default:
                        lang = LanguageIdentifier.English.rawValue
                    }
                    
                    strongSelf.emit(State.Change.loginAttemp(CallbackResult.Success))
                })
                
            }
        }
    }
    
    func signUpPressed(){
        emit(State.Change.redirectSignup)
    }
}

private extension LoginViewModel{
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}

func ==(lhs: LoginViewModel.State.Change, rhs: LoginViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.loading(let loadingState1), .loading(let loadingState2)):
        return loadingState1.activityCount == loadingState2.activityCount
    default:
        return false
    }
}
