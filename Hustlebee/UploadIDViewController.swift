//
//  UploadIDViewController.swift
//  Hustlebee
//
//  Created by Anthony Do on 9/13/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import AWSS3

class UploadIDViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User?
    private var image: UIImage?
    private var observer: AnyObject?
    private var amountUploaded: Int64?
    private var filesize: Int64?
    private lazy var imagePicker = UIImagePickerController()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBOutlet weak var idImageView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBAction func uploadBtn(_ sender: UIButton) {
        pickPhoto()
    }
    @IBOutlet weak var uploadBtnOutlet: UIButton!
    
    // MARK: - Functions
    private func pickPhoto() {
        UIImagePickerController.isSourceTypeAvailable(.camera) ? showPhotoMenu() : chosePhotoFromLibrary()
        
    }
    
    private func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
    
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { [weak weakSelf = self] _ in
            weakSelf?.takePhotoWithCamera()
        }
        
        alertController.addAction(takePhotoAction)
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .default) { [weak weakSelf = self] _ in
            weakSelf?.chosePhotoFromLibrary()
        }
        
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func takePhotoWithCamera() {
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func chosePhotoFromLibrary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showImage(_ image: UIImage) {
        idImageView.image = image
        idImageView.contentMode = UIViewContentMode.scaleAspectFit
        idImageView.clipsToBounds = true
        idImageView.backgroundColor = UIColor.clear
    }
    
    private func updateProgressBar() {
        let uploadProgress = Float(amountUploaded!)/Float(filesize!)
        loadingIndicator.progress = uploadProgress
        let percentComplete = Int(uploadProgress*100)
        if percentComplete < 100 {
            progressLabel.text = "\(percentComplete)%"
        } else {
            progressLabel.text = "Upload Completed!"
        }
    }
    
    private func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) { [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil {
                    strongSelf.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    private func uploadImage(_ url: URL) {
        self.uploadBtnOutlet.isEnabled = false
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = url
        uploadRequest?.key = "photoID/\(user!.firstName)_\(user!.lastName)_\(user!.id)"
        uploadRequest?.bucket = "hustlebee"
        uploadRequest?.contentType = "image/png"
        uploadRequest?.uploadProgress =  { [unowned self] (bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
            DispatchQueue.main.async{ Void in
                self.amountUploaded = totalBytesSent
                self.filesize = totalBytesExpectedToSend
                self.updateProgressBar()
            }
        }
        
        let transferManager = AWSS3TransferManager.default()
            transferManager?.upload(uploadRequest).continue({ [unowned self] (task) -> AnyObject? in
                if let error = task.error {
                    self.present(UIView.warningAlert(title: "Upload Error", message: error.localizedDescription), animated: true, completion: nil)
                    self.uploadBtnOutlet.isEnabled = true
                }
                
                if task.result != nil {
                    self.uploadBtnOutlet.isEnabled = true
                    if let key = uploadRequest?.key {
                        print(key)
                        let s3URL = NSURL(string: "http://s3.amazonaws.com/hustlebee/\(key)")!
                        print("Uploaded to:\n\(s3URL)")
                    }
                } else {
                    self.present(UIView.warningAlert(title: "Unknown Error", message: "Unknown error. Please try again."), animated: true, completion: nil)
                    self.uploadBtnOutlet.isEnabled = true
                }
                
                return nil
            })
    }

    
    // MARK: - ImagePickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if let image = image, let user = user {
            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(user.firstName)_\(user.lastName)_\(user.id).png")
            let imageData = UIImagePNGRepresentation(image)!
            try? imageData.write(to: URL(fileURLWithPath: path as String), options: .atomicWrite)
            let imageURL = URL(fileURLWithPath: path as String)
            
            showImage(image)
            uploadImage(imageURL)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
