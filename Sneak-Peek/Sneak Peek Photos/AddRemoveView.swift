//
//  AddRemoveView.swift
//  Lets Share Vacations
//
//  Created by Roland Thomas on 5/29/16.
//  Copyright © 2016 Jedisware, LLC. All rights reserved.
//

import UIKit
import CoreData

class AddRemoveView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
 
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet var addRempvePicker: UIPickerView!
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet var btnNew: UIButton!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerArray:[(picId: String, groupName: String)] = []
    var locationDict: Dictionary<String, PicLocation> = [:]
    var selectedPicGroupId:String? = String()
    var selectedIndex:String? = String()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let util = Utilities()
        util.setButtonAttributes(btnAdd)
        util.setButtonAttributes(btnNew)
        util.setButtonAttributes(btnDelete)
        defineButtonText()
        
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddRemoveView.isReadyToLogOut(_:)), name: "AddRemoveView.isReadyToLogOut", object: nil)

        let notificationSelector: Selector = #selector(AddRemoveView.deleteUsers(_:))
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: notificationSelector,
                                                         name:"UIApplicationWillTerminateNotification",
                                                         object:nil)
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork()
        {
            
            if UtilSingleton.shareInstance.reloadDataFlag == true{
                UtilSingleton.shareInstance.locationDict.removeAll()
                UtilSingleton.shareInstance.reloadDataFlag = false
                pickerArray.removeAll()
                reloadData()
            }
            else
            {
                pickerArray.removeAll()
                getPickerData()
            }
        }
        else
        {
            displayFailureAlert(title: "Not Connected", body: "You are not connected to the internet.")
        }
        
        if UtilSingleton.shareInstance.reloadTakePicture == true
        {
            self.performSegueWithIdentifier("sgTakePhoto", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func defineButtonText()
    {
        
        switch (UIDevice.currentDevice().modelName)
        {
        case "iPod Touch 5", "iPod Touch 6", "iPhone 4","iPhone 4s", "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus":
            btnDelete.setTitle("Del", forState: .Normal)
        default:
            btnDelete.setTitle("Delete", forState: .Normal)
        }
        
    }

    
    
    func reloadData()
    {
        let locations = MyPicsImagesController()
        let userId = UtilSingleton.shareInstance.userId

            
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            // do some task
            
            self.locationDict.removeAll()
            self.locationDict = locations.GetLocations(userId)
            
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                
                if self.locationDict.count > 0 {
                    self.preparePickerData(self.locationDict)
                    UtilSingleton.shareInstance.locationDict = self.locationDict
                }
                else
                {
                    
                }
            }
        }
    }
    
    //MARK - Picker
    func getPickerData()
    {
        locationDict = UtilSingleton.shareInstance.locationDict
        if locationDict.count > 0 {
            preparePickerData(self.locationDict)
        }
    }
    
    func preparePickerData(pickerData: [String: PicLocation])
    {
        
        for (key,value) in pickerData
        {
            pickerArray.append((picId: key, groupName: value.groupName))
        }
        picker.reloadAllComponents()
        
       
        let selectedItem = UtilSingleton.shareInstance.selectedIndex
        picker.selectRow(selectedItem, inComponent: 0, animated: false)

        let selectedPicId = pickerArray[selectedItem].picId
        selectedPicGroupId = selectedPicId
        
        let value = locationDict[selectedPicId]
        lblLocation.text = value?.groupLocation
        lblDescription.text = value?.groupDescription

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row].groupName
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedPicId = pickerArray[row].picId
        UtilSingleton.shareInstance.selectedIndex = row
        selectedPicGroupId = selectedPicId
        
        let value = locationDict[selectedPicId]
        lblLocation.text = value?.groupLocation
        lblDescription.text = value?.groupDescription
        
        
        picker.reloadAllComponents()
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        
        pickerLabel.text = pickerArray[row].groupName
        //pickerLabel.font = UIFont(name: "Times New Roman", size: 2.0)
        pickerLabel.font = UIFont(name: "Arial-BoldMT", size: 17)
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    

    
    @IBAction func addTap(sender: AnyObject) {
        if pickerArray.count < 1
        {
            let title = "No Groups Available"
            let message = "You must first create a group and add Images."
            
            displayFailureAlert(title: title, body: message)
        }
    }

    @IBAction func newTap(sender: AnyObject) {
    }
    
    @IBAction func deleteTap(sender: AnyObject) {
        if pickerArray.count < 1
        {
            let title = "No Groups Available"
            let message = "You must first create a group and add Images."
            
            displayFailureAlert(title: title, body: message)
        }

    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "sgTakePhoto") {
            if let destinationVC = segue.destinationViewController as? TakePictureView {
                destinationVC.selectedPicGroupId = selectedPicGroupId
                destinationVC.cameFrom = "AddRemove"
                
                if UtilSingleton.shareInstance.reloadTakePicture == true
                {
                    UtilSingleton.shareInstance.reloadTakePicture = false
                    destinationVC.reloadingView = true
                }
            }

        }
        
        if (segue.identifier == "sgDelete") {
            if let destinationVC = segue.destinationViewController as? DeleteView {
                destinationVC.selectedPicGroupId = selectedPicGroupId
            }
            
        }        


    }

    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
        if sender?.tag == 1 || sender?.tag == 3
        {
            if pickerArray.count < 1
            {
                
                return false
            }
            else
            {
                return true
            }
        }
        else
        {
            return true
        }
    }
    
    
    //MARK - Failure Alert
    func displayFailureAlert(title heading: String, body message: String)
    {
        let alertController = UIAlertController(title: heading, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func isReadyToLogOut(notification: NSNotification) {
        let alert = UIAlertController(title: "Your session has timed out!", message: "Do you want to stay logged in?", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            
            NSNotificationCenter.defaultCenter().postNotificationName("TimerUIApplication.resetTimer", object: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(TimerUIApplication.ApplicationDidTimoutNotification, object: nil)
            
            
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        //Two minutes
        let delay = 120.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: nil)
            
            NSNotificationCenter.defaultCenter().postNotificationName(TimerUIApplication.ApplicationDidTimoutNotification, object: nil)
        })

    }
    
    func deleteUsers(notification: NSNotification) {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Users")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }



}
