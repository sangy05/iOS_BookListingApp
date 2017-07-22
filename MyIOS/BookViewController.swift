//
//  BookViewController.swift
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

class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var logsLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var bookList:[Dictionary<String,String>]?
  var alternateServerAttempted = false;
  
  var endPointUsed:String?
  
  @IBAction func manualIPChangeButtonTapped(_ sender: Any) {
    if(!self.alternateServerAttempted){
      self.loadWithAlternateServer()
    }
  }
  
  
  override func viewDidLoad() {
    //self.navigationController?.navigationBar.isHidden = true
    self.alternateServerAttempted = false;
    self.loadData()
  }
  
  func loadData() {
    
    let dataManager = DataManager()
    
    if let url = DataManager.bookServiceEndPoint {
      self.loadBookList(dataManager:dataManager, urlString: url)
    }
    else{
      dataManager.bookServiceURL(fetchResponse: { (fetchedUrl) in
        if (fetchedUrl != nil){
          self.loadBookList(dataManager:dataManager, urlString: fetchedUrl!)
        }
        else{
          DispatchQueue.main.async {
            self.logsLabel.text = "All Book Services are down";
          }
        }
      })
    }
  }
  
  func loadBookList(dataManager:DataManager, urlString:String) {
    
    self.endPointUsed = urlString
    DataManager.bookServiceEndPoint = urlString
    DispatchQueue.main.async {
      if(!self.alternateServerAttempted){
        self.logsLabel.text = "Data from:" + urlString;
      }
      else{
        self.logsLabel.text = (self.logsLabel.text ?? "") + "\nAlternate service switched to:" + urlString;
      }
      
    }
    
    dataManager.getBookList(URL: urlString, fetchResponse: { (resultJson, serverError) in
      
      if(!serverError){
        self.bookList = resultJson;
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
      else{
        if(!self.alternateServerAttempted){
          self.loadWithAlternateServer()
        }
        else{
          DispatchQueue.main.async {
            self.logsLabel.text = "Loading Failed";
          }
        }
      }
      
    })
  }
  
  func loadWithAlternateServer() {
    
    DispatchQueue.main.async {
      self.logsLabel.text = (self.logsLabel.text ?? "") + "\nAttempting Alternate Server"
    }
    let dataManager = DataManager()
    dataManager.reportInvalidEndPoint(type: "book", invalidEndPoint: self.endPointUsed!) { (newUrl) in
      if let url = newUrl {
        self.alternateServerAttempted = true
        self.loadBookList(dataManager: dataManager, urlString: url)
      }
      else {
        DispatchQueue.main.async {
          self.alternateServerAttempted = true
          self.logsLabel.text = "Loading Failed on Alternate as well";
        }
      }
      
      
    }
  }
  
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.bookList?.count ?? 1
  }
  
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell")!
    if let bookItem = bookList?[indexPath.row], let name = bookItem["Name"] {
      cell.textLabel?.text = name
    }
    else{
      cell.textLabel?.text = "Loading..."
    }
    
    return cell;
  }
  
  
}
