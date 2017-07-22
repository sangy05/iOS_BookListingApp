//
//  ViewController.swift
//  MyIOS
//
//  Created by Sivakumar Sangeeth (SEIT) on 2017-05-22.


/*
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var logViewLabel: UILabel!
  var endPointUsed:String?
  @IBOutlet weak var indicator: UIActivityIndicatorView!
  var endPointLoaded = false
  @IBOutlet weak var userName: UITextField!
  
  @IBOutlet weak var password: UITextField!
  
  
  override func viewDidLoad() {
    self.userName.borderStyle = .none
    self.password.borderStyle = .none
    
    self.userName.delegate = self
    self.password.delegate = self

    self.loadEndPoint()
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.resignFirstResponder()
  }
  
  @IBAction func changeServerButtonTapped(_ sender: Any) {
    guard endPointLoaded else{
      return
    }
    let dataManager = DataManager()
    
    endPointLoaded = false
    dataManager.reportInvalidEndPoint(type: "authentication", invalidEndPoint: self.endPointUsed!) { (newURL) in
      if(newURL != nil){
        self.endPointUsed = newURL;
        self.endPointLoaded = true
      }
      else {
         DispatchQueue.main.async {
          self.logViewLabel.text = "New URL Fetch Failed - Restart App If Needed"
        }
      }
      
    }
  }
  
  
  @IBAction func loginButtonTapped(_ sender: Any) {
    if(endPointLoaded) {
      self.indicator.startAnimating()
      let dataManager = DataManager()
      dataManager.validate(URL: self.endPointUsed!, username: self.userName.text ?? "nil", password: self.password.text ?? "nil", fetchResponse: { (status) in
        
        if(status) {
          DispatchQueue.main.async {
            self.indicator.stopAnimating()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookVC") as! BookViewController
            self.navigationController?.pushViewController(vc, animated: true)
          }
        }
        else{
          DispatchQueue.main.async {
          self.indicator.stopAnimating()
          self.logViewLabel.text = "Authentication Failed"
          }
        }
      })
    }
    else {
      
      self.logViewLabel.text = "Connection Failed: Server Unavailable"
    }
  }
  
  func loadEndPoint() {
    let dataManager = DataManager()
    
    if let url = DataManager.authenticationEndPoint {
      self.endPointUsed = url
      self.endPointLoaded = true
      DispatchQueue.main.async {
        self.logViewLabel.text = "Connected to :" + url
      }
      
    }
    else{
      dataManager.authenticationURL(fetchResponse: { (fetchedUrl) in
        if (fetchedUrl != nil){
          self.endPointUsed = fetchedUrl
          DataManager.authenticationEndPoint = fetchedUrl
          self.endPointLoaded = true
          DispatchQueue.main.async {
            self.logViewLabel.text = "Connected to :" + (fetchedUrl ?? "NULL")
          }
          
        }
      })
    }
  }
  
  
}
