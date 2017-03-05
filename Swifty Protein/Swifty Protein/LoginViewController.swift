//
//  LoginViewController.swift
//  Swifty Protein
//
//  Copyright © 2017 chtison. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let login = "root"
    let password = "secret"
    
    @IBOutlet weak var inputLogin: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var buttonTouchId: UIButton!
    
    var authContext: LAContext!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authContext = LAContext()
        authContext.localizedFallbackTitle = ""
        var err: NSError?
        if !authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) {
            buttonTouchId.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Swifty Proteins"
    }
    
    @IBAction func signIn(_ sender: Any) {
        if inputLogin.text == nil || inputLogin.text != login || inputPassword.text == nil || inputPassword.text != password {
            let alert = UIAlertController(title: "Sign In Failed", message: "User/Password are \(login)/\(password)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        inputPassword.text = nil
        performSegue(withIdentifier: "Authenticated", sender: self)
    }

    @IBAction func signInWithTouchId(_ sender: Any) {
        view.endEditing(false)
        authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentication") { [unowned self] (success: Bool, error: Error?) in
            OperationQueue.main.addOperation {
                if success {
                    self.inputLogin.text = nil
                    self.inputPassword.text = nil
                    self.performSegue(withIdentifier: "Authenticated", sender: self)
                } else if let error = error {
                    let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == inputLogin {
            inputLogin.resignFirstResponder()
            inputPassword.becomeFirstResponder()
            return true
        }
        if textField == inputPassword {
            inputPassword.resignFirstResponder()
            return true
        }
        return false
    }

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(false)
    }
}
