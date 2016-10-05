//
//  DeleteController.swift
//  Sneak Peek Photos
//
//  Created by Roland Thomas on 6/24/16.
//  Copyright © 2016 Jedisware, LLC. All rights reserved.
//

import UIKit
protocol UpdateDelegate {
    func updateView()
    func displayFailureAlert(title heading: String, body message: String)
}

class DeleteController: UIViewController {
   var delegate: UpdateDelegate! = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delete(picId: String, imgIdArray:NSMutableArray)
    {
        deleteImages(picId, imgIdArray: imgIdArray)
    }
    
    func deleteImages(picId: String, imgIdArray: NSMutableArray) -> Bool {
        
        var result: Bool = false
        var returnResult: String = String()
        var status = 200
        
        let userId = UtilSingleton.shareInstance.userId
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://www.URL" + "?userId=\(userId)&picId=\(picId)")!)

        request.HTTPMethod = "DELETE"
        
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(imgIdArray, options: NSJSONWritingOptions.PrettyPrinted)
            
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
        }catch let error as NSError{
            print(error.description)
        }

        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                // check for fundamental networking error
                
                let errorMsg:String =  (error?.localizedDescription)!
                
                if errorMsg.rangeOfString("The Internet connection appears to be offline") != nil{
                    returnResult = "The Internet connection appears to be offline"
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        //Display a message to user that insert failed
                        
                        self.delegate?.displayFailureAlert(title: "Error Occurred.", body: returnResult)
                    }
                    
                }
                else
                {
                    returnResult = "An unspecified error occurred."
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        //Display a message to user that insert failed
                        
                        self.delegate?.displayFailureAlert(title: "Error Occurred.", body: returnResult)
                    }
                }
                return

            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                status = httpStatus.statusCode
                
            }
            else
            {
                do {
                    let jsonStr = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                   
                    if status == 200
                    {
                        _ = jsonStr.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)

                        let returnString:String = jsonStr as! String
                        
                        //Check if the Uploadwas successful
                        if returnString.rangeOfString("Deletion Complete") != nil{
                            result = true
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // update some UI
                                //Display a message to user that insert failed
                                
                                self.delegate?.updateView()
                            }
                        }
                        else
                        {
                            result = false
                            dispatch_async(dispatch_get_main_queue()) {
                                // update some UI
                                //Display a message to user that insert failed
                                
                                self.delegate?.displayFailureAlert(title: "Error Occurred.", body: returnString)
                            }

                        }
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue()) {
                            // update some UI
                            //Display a message to user that insert failed
                            
                            self.delegate?.displayFailureAlert(title: "Server Error.", body: "Could not process request")
                        }
                        
                    }
                }
                    
                catch {
                result = false
                }
            }
        }
        
        
        task.resume()

        return result
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
