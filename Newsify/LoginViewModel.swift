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
        
        enum Change{
            case none
            case loginAttemp(CallbackResult)
            case loggedIn(CallbackResult)
            case loadingView
            case removeView
            case error(String)
            case redirectSignup
        }
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    private var authController = FirebaseController()
    
    func checkUserLoginStatus(){
        if authController.getCurrentUser() != nil {
            
            emit(State.Change.loadingView)
            
            self.authController.fetchUserLanguage(completion: { (identifier) in
                switch identifier{
                case LanguageIdentifier.Turkish.rawValue, LanguageIdentifier.English.rawValue, LanguageIdentifier.Russian.rawValue:
                    lang = identifier
                default:
                    lang = LanguageIdentifier.English.rawValue
                }
                
                self.emit(State.Change.removeView)
                self.emit(State.Change.loggedIn(CallbackResult.Success))
            })
        }
    }
    
    func loginWithUsername(username: String, _ password: String){
        
        emit(State.Change.loadingView)
        
        authController.signInWith(username: username, password: password, enableNotification: true) { [weak self](error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.emit(State.Change.removeView)
                strongSelf.emit(State.Change.error(error.localizedDescription))
            } else {
                strongSelf.authController.fetchUserLanguage(completion: { (identifier) in
                    switch identifier{
                    case LanguageIdentifier.Turkish.rawValue, LanguageIdentifier.English.rawValue, LanguageIdentifier.Russian.rawValue:
                        lang = identifier
                    default:
                        lang = LanguageIdentifier.English.rawValue
                    }
                    
                    strongSelf.emit(State.Change.removeView)
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