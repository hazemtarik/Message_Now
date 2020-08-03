//
//  ChangePasswordViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/20/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    private let vm = ChangePasswordViewModel()
    
    
    @IBOutlet weak var passwordextField: UITextField!
    @IBOutlet weak var repasswordTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellUI()
        initVM()
    }
    
    
    
    
    
    // MARK:- Init view model
    
    private func initVM() {
        vm.changePasswordClosure = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.changeButton.isEnabled = true
            Alert.showAlert(at: self, title: "", message: self.vm.message)
        }
    }
    
    
    
    
    
    
    
    // MARK:- Actions
    
    @IBAction func UpdateButtonPressed(_ sender: UIButton) {
        vm.chnagePassword(password: passwordextField.text!, repassword: repasswordTextField.text!)
        dismissKeyboard()
        activityIndicator.startAnimating()
        changeButton.isEnabled = false
    }
    private func presentViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "tabBar")
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true)
    }
    

    private func setupCellUI() {
        //Setup cornerRadius
        changeButton.layer.cornerRadius = 27.5
        passwordextField.layer.cornerRadius = 27.5
        repasswordTextField.layer.cornerRadius = 27.5
        
        //Setup backgroundColor
        passwordextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        repasswordTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        //Setup delegates
        setupTextFields(textField: passwordextField)
        setupTextFields(textField: repasswordTextField)
        
        tapGesture.addTarget(self, action: #selector(dismissKeyboard))
        
        activityIndicator.stopAnimating()
        
    }
    
    func setupTextFields(textField: UITextField) {
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.height))
        textField.rightViewMode = .always
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    

}
