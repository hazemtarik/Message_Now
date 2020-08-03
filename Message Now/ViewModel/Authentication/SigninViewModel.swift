//
//  SigninViewModel.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/23/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation

class SigninViewModel {
    
    private var isSignIn: Bool? { didSet { signInClosure?() }}
    public  var message : String? { didSet { showAlertClosure?() }}
    
    
    var signInClosure: (()->())?
    var showAlertClosure: (()->())?
    
    
    
    
    
    
    func signInPressed(withEmail email: String, password: String) {
        FBAuthentication.shared.FBSignInUser(withEmail: email, password: password) { [weak self] (isSuccess, error) in
            guard let self = self else { return }
            if !isSuccess {
                self.message = error
            } else {
                self.isSignIn = isSuccess
            }
        }
    }
    
}
