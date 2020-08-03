//
//  SigninViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 6/22/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {

    private let vm = SigninViewModel()
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var heightStack: NSLayoutConstraint!
    @IBOutlet weak var topForget: NSLayoutConstraint!
    
    
    
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initView()
        initVM()
    }
    
    
    
    
    
    
    
    //MARK:- Init view and fetch View Model
    
    private func initView() {
        //Setup navigationBar
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = false
    }
    
    
    private func initVM() {
        vm.signInClosure = { [weak self] in
            guard let self = self else { return }
            self.presentViewController()
        }
        vm.showAlertClosure = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.loginButton.isEnabled = true
            Alert.showAlert(at: self, title: "Sing In Validation", message: self.vm.message!)
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK:- Actions
    
    @IBAction func signinPressed(_ sender: UIButton) {
        updateUI()
        dismissKeyboard()
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        vm.signInPressed(withEmail: emailTextField.text!, password: passwordTextField.text!)
    }
    private func presentViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "tabBar")
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true)
    }
    

    
    func setupTextFields(textField: UITextField) {
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textField.frame.height))
        textField.rightViewMode = .always
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        updateUI()
    }

    
    
    
    
    
    
    
    
    private func setupUI() {
        //Setup cornerRadius
        loginButton.layer.cornerRadius = 27.5
        createAccountButton.layer.cornerRadius = 27.5
        emailTextField.layer.cornerRadius = 27.5
        passwordTextField.layer.cornerRadius = 27.5
        
        //Setup backgroundColor
        emailTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        passwordTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        createAccountButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        //Setup delegates
        setupTextFields(textField: emailTextField)
        setupTextFields(textField: passwordTextField)
        
        tapGesture.addTarget(self, action: #selector(dismissKeyboard))
        
        activityIndicator.stopAnimating()
        
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.logoImageView.isHidden = false
                self.heightStack.constant = 190
                self.topForget.constant = 50
            }
        }
    }
    
}


// MARK:- TextField delegate

extension SigninViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.logoImageView.isHidden = true
                self.heightStack.constant = 70
                self.topForget.constant = 170
            }
        }
        
    }
}
