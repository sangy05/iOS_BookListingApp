

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

import Foundation

class DataManager {
  
  typealias arrayOfstringDictionary = Array<Dictionary<String,String>>
  typealias anyDictionary = Dictionary<String,Any>
  
  let gatewayURL = "" // <Replace with Server Bluemix End Point URL>
  
  
  var defaultPostData = [
    "serviceType":"",
    "URL":"",
    "deviceID":"dsjdfkk8782",
    "status":"available"
  ]
  
  static var authenticationEndPoint:String?
  static var bookServiceEndPoint:String?
  
  class func urlWithHost(_ endPointString:String)->String {
          return "http://"+endPointString;
    }
  
  
  
   //MARK: BLUEMIX API GATEWAY SERVER CALLS
  
  func regsisterDevice(url:String,type:String,fetchResponse: @escaping(_ status:Bool) -> ()) {
  
    if(type == "book") {
      self.defaultPostData["serviceType"] = "book"
      self.defaultPostData["URL"] = url
    }
    
    self.makeNetworkRequest(urlString: gatewayURL+"/addEntry/device", method: "POST") { (result, error) in
      
      if(error == nil){
        fetchResponse(true)
      }
      else{
        fetchResponse(false)
      }
    }
  }

  
  func authenticationURL(fetchResponse: @escaping(_ URL:String?) -> ()) {
    var responseURL:String?
    
    self.makeNetworkRequest(urlString: gatewayURL+"/getServer/authentication") { (result, error) in
     
      if let result = result , let url = result["ip"] {
        responseURL = url as? String
      }
     fetchResponse(responseURL)
    }
  
  }
 
  
  func bookServiceURL(fetchResponse: @escaping(_ URL:String?) -> ()) {
    var responseURL:String?
    
    
    self.makeNetworkRequest(urlString: gatewayURL+"/getServer/book") { (result, error) in
      
      if let result = result , let url = result["ip"] {
        responseURL = url as? String
      }
      fetchResponse(responseURL)
    }

  }
  

  func reportInvalidEndPoint(type:String, invalidEndPoint:String, fetchResponse: @escaping(_ URL:String?) -> ()) {
    var newResponseURL:String?
    
    self.makeNetworkRequest(urlString: gatewayURL+"/invalidURL/"+type+"/"+invalidEndPoint) { (result, error) in
      if let result = result , let url = result["ip"] {
        newResponseURL = url as? String
      }
      fetchResponse(newResponseURL)
    }
  }
  

  //MARK: LOCAL IOS SERVER CALLS
  func validate(URL:String, username:String, password:String, fetchResponse: @escaping(_ status:Bool) -> ()) {
    
    var isSuccess = false
     let finalURLString = DataManager.urlWithHost(URL)
    
    self.makeNetworkRequest(urlString: finalURLString+"/data/validate/"+username+"/"+password) { (result, error) in
      
      if let result = result , let status = result["result"] {
        isSuccess = (status as! String == "success")
      }
      fetchResponse(isSuccess)
    }

  }
  
  func getBookList(URL:String , fetchResponse: @escaping(_ result:arrayOfstringDictionary, _ serverError:Bool) -> ()) {
    var list = arrayOfstringDictionary()
    var serverIssue = true;
    let finalURLString = DataManager.urlWithHost(URL)

    self.makeNetworkRequest(urlString: finalURLString+"/data/getBooks") { (result, error) in
      
      if let result = result , let bookResult = result["data"] {
        list = bookResult as! arrayOfstringDictionary
        serverIssue = false;
      }
      fetchResponse(list,serverIssue)
    }
    
  }
  
  func makeNetworkRequest(urlString:String, method:String = "GET" ,completionHandler:@escaping (_ result:anyDictionary?, _ error:String?)->()) {
    let url:URL =  URL(string: urlString)!

    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    if(method == "POST"){
      
      do {
        let data = try JSONSerialization.data(withJSONObject: self.defaultPostData, options: .prettyPrinted)
        request.httpBody = data
      }
      catch{
        
      }
    }
    
    let task = session.dataTask(with: request) { (data, response, error) in
      
      if(error == nil) {
        do {
          let resultInJSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! anyDictionary
          completionHandler(resultInJSON, nil)
          
        }
        catch{
           completionHandler(nil, "parsing error")
        }
      }
      else {
        completionHandler(nil, error?.localizedDescription)
      }
      
      
    }
    task.resume()
  }
  
}
