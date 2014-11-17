//
//  LoginViewController.swift
//  Podio Dev Test
//
//  Created by Karlo Kristensen on 17/11/14.
//  Copyright (c) 2014 floskel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    lazy var usernameTextField:UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Email"
        return textField
    }()
    
    lazy var passwordTextField:UITextField = {
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Password"
        textField.secureTextEntry = true
        return textField
    }()
    
    lazy var loginButton:UIButton = {
        let button = UIButton.buttonWithType(.Custom) as UIButton
        button.setTitle("Log In", forState: .Normal)
        button.addTarget(self, action: Selector("loginButtonTapped:"), forControlEvents: .TouchUpInside)
        button.enabled = false
        button.backgroundColor = UIColor.blueColor()
        button.layer.cornerRadius = 5.0
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name: UITextFieldTextDidChangeNotification, object: usernameTextField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidChange:"), name: UITextFieldTextDidChangeNotification, object: passwordTextField)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let horizontalOffset:CGFloat = 30.0
        let verticalOffset:CGFloat = 15.0
        let width = CGRectGetWidth(self.view.bounds) - 2*horizontalOffset
        let height:CGFloat = 40.0
        
        usernameTextField.frame = CGRectMake(horizontalOffset, CGRectGetHeight(self.view.bounds) / 4.0, width, height)
        
        passwordTextField.frame = CGRectMake(horizontalOffset, CGRectGetMaxY(usernameTextField.frame) + verticalOffset , width, height)
        
        loginButton.frame = CGRectMake(horizontalOffset, CGRectGetMaxY(passwordTextField.frame) + verticalOffset, width, height)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Notifications
    
    func textFieldDidChange(textfield:UITextField) {
        if countElements(usernameTextField.text) > 0 && countElements(passwordTextField.text) > 0 {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
    }
    
    //MARK: Button handlers
    
    func loginButtonTapped(button:UIButton) {
        PodioApi.sharedInstance.login(usernameTextField.text, password: passwordTextField.text) {
            success in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alertViewController = UIAlertController(title: "Whoops", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.Alert)
                
                let tryAgainAction = UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: {
                    action in
                    alertViewController.dismissViewControllerAnimated(true, completion: nil)
                })
                
                alertViewController.addAction(tryAgainAction)
                
                self.presentViewController(alertViewController, animated: true, completion: nil)
            }
        }
    }
}
