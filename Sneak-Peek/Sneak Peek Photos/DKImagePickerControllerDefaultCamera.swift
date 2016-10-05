//
//  DKImagePickerControllerDefaultCamera.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit


@objc
public class DKImagePickerControllerDefaultUIDelegate: UIViewController, DKImagePickerControllerUIDelegate {
	
	private var doneButton: UIButton?
	
	public func doneButtonForPickerController(imagePickerController: DKImagePickerController) -> UIButton {
		if self.doneButton == nil {
			let button = UIButton(type: UIButtonType.Custom)
			button.setTitleColor(UINavigationBar.appearance().tintColor ?? imagePickerController.navigationBar.tintColor, forState: UIControlState.Normal)
			button.addTarget(imagePickerController, action: #selector(DKImagePickerController.done), forControlEvents: UIControlEvents.TouchUpInside)
			
			self.doneButton = button
			
			self.updateDoneButtonTitleForImagePickerController(imagePickerController)
		}
		
		return self.doneButton!
	}
	
	// Delegate methods...
	
	public func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
	                                              didCancel: (() -> Void),
	                                              didFinishCapturingImage: ((image: UIImage) -> Void),
	                                              didFinishCapturingVideo: ((videoURL: NSURL) -> Void)) -> UIViewController {
		
		let camera = DKCamera()
		
		camera.didCancel = { () -> Void in
			didCancel()
		}
		
		camera.didFinishCapturingImage = { (image) in
			didFinishCapturingImage(image: image)
		}
		
		self.checkCameraPermission(camera)
	
		return camera
	}
	
	public func layoutForImagePickerController(imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	public func imagePickerControllerCameraImage() -> UIImage {
		return DKImageResource.cameraImage()
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
		                                                      target: imagePickerController,
		                                                      action: #selector(DKImagePickerController.dismiss))
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, showsDoneButtonForVC vc: UIViewController) {
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButtonForPickerController(imagePickerController))
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitleForImagePickerController(imagePickerController)
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitleForImagePickerController(imagePickerController)
	}
	
	public func imagePickerControllerDidReachMaxLimit(imagePickerController: DKImagePickerController) {
        
        dispatch_async(dispatch_get_main_queue()) {
            // update some UI
            //Display a message to user that insert failed
            
             self.displayFailureAlert(title: DKImageLocalizedStringWithKey("maxLimitReached"), body: String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage")))
        }

       
    
    }
	
	// Internal
	
	public func checkCameraPermission(camera: DKCamera) {
		func cameraDenied() {
			dispatch_async(dispatch_get_main_queue()) {
				let permissionView = DKPermissionView.permissionView(.Camera)
				camera.cameraOverlayView = permissionView
			}
		}
		
		func setup() {
			camera.cameraOverlayView = nil
		}
		
		DKCamera.checkCameraPermission { granted in
			granted ? setup() : cameraDenied()
		}
	}
	
	public func updateDoneButtonTitleForImagePickerController(imagePickerController: DKImagePickerController) {
		if imagePickerController.selectedAssets.count > 0 {
			self.doneButtonForPickerController(imagePickerController).setTitle(String(format: DKImageLocalizedStringWithKey("select"), imagePickerController.selectedAssets.count), forState: UIControlState.Normal)
		} else {
			self.doneButtonForPickerController(imagePickerController).setTitle(DKImageLocalizedStringWithKey("done"), forState: UIControlState.Normal)
		}
		
		self.doneButton?.sizeToFit()
	}
    
    func displayFailureAlert(title heading: String, body message: String)
    {
        let alertController = UIAlertController(title: heading, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
 

	
}
