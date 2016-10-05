//
//  DeleteView.swift
//  Sneak Peek Photos
//
//  Created by Roland Thomas on 6/24/16.
//  Copyright © 2016 Jedisware, LLC. All rights reserved.
//

import UIKit
import CoreData

class DeleteView: UIViewController,  UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UpdateDelegate, ImageDelegate{
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    

    let delController = DeleteController()
    let pics = MyPicsImagesController()
    
    @IBOutlet weak var btnDelete: UIButton!
    
    var imagesDict = Dictionary<String, Images>()
    var imagesArray:Array<Images> = []
    var selectedPicGroupId:String? = String()
    var itemsToDelete:NSMutableArray = []
    let util = Utilities()
    
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()

    
    @IBOutlet weak var previewView: UICollectionView!
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DeleteView.isReadyToLogOut(_:)), name: "DeleteView.isReadyToLogOut", object: nil)

        let notificationSelector: Selector = #selector(DeleteView.deleteUsers(_:))
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: notificationSelector,
                                                         name:"UIApplicationWillTerminateNotification",
                                                         object:nil)
        

        if Reachability.isConnectedToNetwork()
        {

            let width = previewView.bounds.width
            let height = previewView.bounds.height
            layout.estimatedItemSize = CGSize(width: width, height: height)
            
            // Do any additional setup after loading the view.
            progressBarDisplayer("Loading Images", true)
            
            getImages()
            layout = self.previewView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            util.setButtonAttributes(btnDelete)
            
            self.delController.delegate = self
            self.pics.delegate = self
        }
        else
        {
            displayFailureAlert(title: "Not Connected", body: "You are not connected to the internet.")
        }

        defineWhichLayout()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        self.previewView.dataSource = self
        self.previewView.delegate = self
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func defineWhichLayout()
    {
        layout = self.previewView.collectionViewLayout as! UICollectionViewFlowLayout
        switch (UIDevice.currentDevice().modelName)
        {
        case "iPod Touch 5", "iPod Touch 6", "iPhone 4","iPhone 4s", "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus":
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical
            
        default:
            // All iPads
            switch UIDevice.currentDevice().orientation{
            case .Portrait:
                layout.scrollDirection = UICollectionViewScrollDirection.Vertical
            case .PortraitUpsideDown:
                layout.scrollDirection = UICollectionViewScrollDirection.Vertical
            case .LandscapeLeft:
                layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            case .LandscapeRight:
                layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            default:
                layout.scrollDirection = UICollectionViewScrollDirection.Vertical
            }
            
        }
        
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        //let screenHeight = screenSize.height
        
        
     switch UIDevice.currentDevice().orientation{
     case .Portrait:
     return CGSize(width: (screenWidth / 2), height: collectionView.frame.height * 0.3)
     case .PortraitUpsideDown:
     return CGSize(width: (screenWidth  / 2), height: collectionView.frame.height * 0.3)
     case .LandscapeLeft:
     return CGSize(width: (screenWidth / 3), height: collectionView.frame.height * 0.5)
     case .LandscapeRight:
     return CGSize(width: (screenWidth / 3), height: collectionView.frame.height * 0.5)
     default:
     return CGSize(width: (screenWidth / 2), height: collectionView.frame.height * 0.3)
     }
     
    }

    
    @IBAction func deleteTap(sender: AnyObject) {
        let alert = UIAlertController(title: "Deletions are Permanent!", message: "Are you sure you want to continue?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            //Perform Yes action
            
            self.delController.delete(self.selectedPicGroupId!, imgIdArray: self.itemsToDelete)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            //Perform No Action
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
  
    
    func getImages()
    {

       // let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
       // dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            // do some task
            //self.imagesDict =
                
                self.pics.GetImages(self.selectedPicGroupId!)
            
         //   dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                
                if self.imagesDict.count > 0 {
                    self.imagesArray = Array(self.imagesDict.values)
                    self.previewView.reloadData()
                }
                else
                {
                    
                }
          //  }
            
       // }
    }
    
    func updateView()
    {
        getImages()
    }
    
    func imageResult(imgDict: Dictionary<String, Images>)
    {
        if imgDict.count > 0 {
            self.imagesArray = Array(imgDict.values)
            self.imagesDict = imgDict
            
            dispatch_async(dispatch_get_main_queue()) {
                [unowned self] in
                self.previewView.reloadData()
                
                self.messageFrame.removeFromSuperview()
            }
        }
    }
    
  
    // MARK: UICollectionViewDelegates
    
    
    
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesDict.count ?? 0
    }
    
    
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        var cell: UICollectionViewCell?
        var imageView: UIImageView?
        var image:UIImage
        
        
        
        image = UIImage(data: self.imagesArray[indexPath.row].img)!
        
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellImage", forIndexPath: indexPath)
        imageView = cell?.contentView.viewWithTag(100) as? UIImageView
        imageView?.image = image
        
        
        
        cell!.layer.borderWidth = 2
        cell!.layer.borderColor = UIColor.yellowColor().CGColor
        
        
        return cell!
    }
    
    
    
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!

        let uiColor = UIColor(CGColor: cell.layer.borderColor!)
        
        if uiColor.isEqual(UIColor.yellowColor())
        {
            cell.layer.borderWidth = 8
            cell.layer.borderColor = UIColor.redColor().CGColor
            itemsToDelete.addObject(self.imagesArray[indexPath.row].imgId)
        }
        else
        {
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.yellowColor().CGColor
            itemsToDelete.removeObject(self.imagesArray[indexPath.row].imgId)
        }
        
        
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        let layout = self.previewView.collectionViewLayout as! UICollectionViewFlowLayout
        
        if ((toInterfaceOrientation == UIInterfaceOrientation.LandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientation.LandscapeRight)){
            
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
        
        if ((toInterfaceOrientation == UIInterfaceOrientation.Portrait) || (toInterfaceOrientation == UIInterfaceOrientation.PortraitUpsideDown)){
            layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        }
        
        
    }
    
    // MARK: - Activity Indicator
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.blackColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 200, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor.whiteColor()
        //UIColor(white: 0, alpha: 0.3)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }

    func displayFailureAlert(title heading: String, body message: String)
    {
        let alertController = UIAlertController(title: heading, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func isReadyToLogOut(notification: NSNotification) {
        let alert = UIAlertController(title: "Your session has timed out!", message: "Do you want to stay logged in?", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            
            NSNotificationCenter.defaultCenter().postNotificationName("TimerUIApplication.resetTimer", object: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            
            
            NSNotificationCenter.defaultCenter().postNotificationName(TimerUIApplication.ApplicationDidTimoutNotification, object: nil)
            
            
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
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
