//
//  LoginController.swift
//  found
//
//  Created by Ellen Li on 5/1/22.
//

import Foundation
import UIKit

class LoginController: UIViewController {
    
    @objc let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = .boldSystemFont(ofSize: 25)
        return label
    }()
    
    let usernameField = InputField(title: "Username")
    let passwordField = InputField(title: "Password")
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = .Theme.highlight
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .Theme.background
        setupLoginFields()

        
        [loginLabel, usernameField, passwordField, usernameField, loginButton].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }
        
        NSLayoutConstraint.activate([
            loginLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 2 / 3),
            loginLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            
            usernameField.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 30),
            usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -60),
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 30),
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -60),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -60),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    fileprivate func setupLoginFields() {
        passwordField.isSecureTextEntry = true
        
        loginLabel.textAlignment = .center
        loginLabel.textColor = .Theme.text
        usernameField.textAlignment = .center
        usernameField.autocorrectionType = .no
        passwordField.textAlignment = .center
        usernameField.textColor = .Theme.text
        passwordField.textColor = .Theme.subText
        
        usernameField.backgroundColor = .black.withAlphaComponent(0.5)
        passwordField.backgroundColor = .black.withAlphaComponent(0.5)
        
        usernameField.layer.cornerRadius = 10
        passwordField.layer.cornerRadius = 10
    }
    
    @objc func login() {
        if let username = usernameField.decodeText(), let password = passwordField.decodeText() {
            DefaultsManager.username = username
            DefaultsManager.password = password
            navigationController?.popViewController(animated: true)
            navigationController?.isNavigationBarHidden = false
        } else {
            let _ = usernameField.validate()
            let _ = passwordField.validate()
        }
    }
}
