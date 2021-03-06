//
//  ImageViewController.swift
//  ZbranevichComics
//
//  Created by user on 13.06.16.
//  Copyright © 2016 itransition. All rights reserved.
//

struct MyFrame {
    var URLname = ""
    var x : CGFloat
    var y : CGFloat
    var width : CGFloat
    var heigth : CGFloat
}



import UIKit
import MobileCoreServices
import UIKit
import AVFoundation

class TemplateViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate
{
    
    //MARK: - Other
    
    var load = false
    var imageSet: [[String: AnyObject]] = []
    var templates: [[String: AnyObject]]? = nil
    var media = [NSURL]()

    var templateContainer: UIView!
    @IBOutlet weak var cloudCollection: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var mainView: UIView!
    var first = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        loadJSONTemplates()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.cloudCollection.delegate = self
        self.cloudCollection.dataSource = self
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if first {
         return templates!.count
        }
        else {
            return templates!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        
        if first {
            for aa in cell.subviews {
                aa.removeFromSuperview()
            }
            let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width))

            iv.image = UIImage(named: "pug2")
            cell.addSubview(iv)
        }
        else {
            for aa in cell.subviews {
                aa.removeFromSuperview()
            }
            let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width))
            let imageName = templates![indexPath.row]["name"] as? String
            
            iv.image = UIImage(named: imageName!)
            cell.addSubview(iv)


        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if first {
            let template = templates![indexPath.row]["struct"]
            
            self.imageSet = template as! [[String : AnyObject]]
            if load == false {
                imagePicker.delegate = self
                createTemplateView()
                for viewPart in imageSet {
                    createScrollView(viewPart)
                }
                load = true
                collectionView.reloadData()
            }
            first = false;
            saveButton.enabled = true
            loadJSONCloud()
        }
        else {
            let dataFrame =  templates![indexPath.row]["frame"]
            

            let tmp = Cloud(frame: CGRect(x: dataFrame!["x"] as! CGFloat,
                y: dataFrame!["y"] as! CGFloat,
                width: dataFrame!["width"] as! CGFloat,
                height: dataFrame!["height"] as! CGFloat
                ))
            tmp.imageName = templates![indexPath.row]["name"] as? String
            if let textData = templates![indexPath.row]["text"] as? [String : AnyObject] {
                tmp.imageText = textData
            }
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TemplateViewController.panGestureDetected(_:)))
            panGestureRecognizer.minimumNumberOfTouches = 1
            tmp.addGestureRecognizer(panGestureRecognizer)
            templateContainer.addSubview(tmp)
        }
    }
    
    func loadJSONTemplates() {
        let url = NSBundle.mainBundle().URLForResource("Template", withExtension: "json")
        let data = NSData(contentsOfURL: url!)
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                guard
                let templates = dictionary["templates"] as? [[String: AnyObject]] else { print("err");return }
                self.templates = templates
            }
        } catch {
            // Handle Error
        }
    }
    
    func loadJSONCloud() {
        let url = NSBundle.mainBundle().URLForResource("sticker", withExtension: "json")
        let data = NSData(contentsOfURL: url!)
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                guard
                    let templates = dictionary["clouds"] as? [[String: AnyObject]] else { print("err");return }
                self.templates = templates
            }
        } catch {
            // Handle Error
        }
    }
    
  
    
    func panGestureDetected(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.templateContainer)
        
        let newPoint = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        if self.templateContainer.pointInside(newPoint, withEvent: nil) {
            sender.view!.center = newPoint
        }
        else {
            sender.view?.removeFromSuperview()
        }
        
        sender.setTranslation(CGPointZero, inView: self.templateContainer)
    }
    
    func createTemplateView() {
        let width = mainView.bounds.width
        let height = width
        templateContainer = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mainView.addSubview(templateContainer)
        templateContainer.addSubview(UIView())//?????????????????
    }
    
    
    //MARK: - TemplateControll
    
    func createScrollView(dataOfView: [String: AnyObject]) {
        guard
        let dataX = dataOfView["x"] as? CGFloat,
        let dataY = dataOfView["y"] as? CGFloat,
        let dataWidth = dataOfView["width"] as? CGFloat,
        let dataHeight = dataOfView["heigth"] as? CGFloat else { return }
        
        let x = mainView.bounds.width * dataX
        let y = mainView.bounds.width * dataY
        let width = mainView.bounds.width * dataWidth
        let height = mainView.bounds.width * dataHeight
        
        let imageView = UIImageView()
        
        let scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: width, height: height))
        
        scrollView.delegate = self
        scrollView.layer.borderWidth = 2
        scrollView.addSubview(imageView)

        
         let image = UIImage(named: "pug3")!
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(TemplateViewController.imageTapped(_:) ))
        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        insertImage(scrollView , image: image)
        
        templateContainer.addSubview(scrollView)
        
        }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first! as UIView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents(scrollView, imageView: scrollView.subviews.first as! UIImageView)
    }
    
    func centerScrollViewContents(scrollView: UIScrollView, imageView: UIView){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }

        imageView.frame = contentsFrame
        
    }
    
    func insertImage(scrollView: UIScrollView, image: UIImage)
    {
        
        let imageView = scrollView.subviews.first as! UIImageView
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        imageView.contentMode = UIViewContentMode.Center
        //scrollView.userInteractionEnabled = true
        imageView.userInteractionEnabled = true
        
        
        imageView.image = image
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        scrollView.contentSize = image.size
        
        
        
        
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        scrollView.contentSize = image.size
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = 1
        
        centerScrollViewContents(scrollView, imageView: imageView)
        
        if scrollView.tag == 0 {
            media.append(NSURL())
            scrollView.tag = media.count
        }
        

    }
    
    func insertVideo(scrollView: UIScrollView, videoURL: NSURL)
    {
        let imageView = scrollView.subviews.first as! UIImageView
        var uiImage = UIImage()
        do {
            let asset = AVURLAsset(URL: videoURL, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            let cgImage = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            uiImage = UIImage(CGImage: cgImage)
            // lay out this image view, or if it already exists, set its image property to uiImage
        } catch let error as NSError {
            print("Error generating thumbnail: \(error)")
        }
        
        
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //scrollView.userInteractionEnabled = true
        imageView.userInteractionEnabled = true
        
        
        imageView.image = uiImage


        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        
        
        media[scrollView.tag - 1] = videoURL
        
        
}
    
    




    
// MARK: - UIImagePickerControllerDelegate Method
    
    var currPicker = UIScrollView()
    private var curreImage = UIImage()
    let imagePicker = UIImagePickerController()

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // dismiss image picker controller
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismissViewControllerAnimated(true) {
            // 3
            if mediaType == kUTTypeMovie {
                let contentURL = info[UIImagePickerControllerMediaURL] as! NSURL
                self.callbackVideo(contentURL)
                
            }
            else {
                // if image selected the set in preview.
                if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    self.curreImage = newImage
                    self.performSegueWithIdentifier("chouseImage", sender: self)
                }
            }
        }
    }
    
    func callbackImage(img: UIImage) {
        self.insertImage(currPicker, image: img)
    }
    
    func callbackVideo(URL: NSURL) {
        self.insertVideo(self.currPicker, videoURL: URL)
        
    }

    
    func imageTapped(img: UITapGestureRecognizer)
    {
        let alertController = UIAlertController(title: "Set media", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        let photoAction = UIAlertAction(title: "Library", style: .Default) { (action) in
            self.currPicker = (img.view as! UIImageView).superview as! UIScrollView
            self.showPhotoGallery()
        }

        alertController.addAction(photoAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Show photo gallery to choose image
    private func showPhotoGallery() -> Void {
        
         // show picker to select image form gallery
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            
            // create image picker
            let imagePicker = UIImagePickerController()
            
            // set image picker property
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = false
            
            
            // show image picker
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }else{
            self.showAlertMessage(alertTitle: "Not Supported", alertMessage: "Device can not access gallery.")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "chouseImage"
        {
            let vc = segue.destinationViewController as! FiltersViewController
            vc.selctedImage = curreImage
        }
    }

    
    //MARK: - Realm
    
    let page = Page()
    var comics = Book()
    
    @IBAction func savePage(sender: AnyObject) {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        if comics.id == 0 {
            comics.id = Int(arc4random_uniform(600)+1)
            comics.name = "tmp" + String(Int(arc4random_uniform(600)+1))
            try! uiRealm.write { () -> Void in
                uiRealm.add([comics], update: true)
            }
        }
        try! uiRealm.write {
            page.id = Int(arc4random_uniform(600)+1)
        
            let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
            print(pathDocuments)
            let pathImage = "\(pathDocuments)/\(page.id).jpg"
        
            templateContainer.saveImageFromView(path: pathImage)
            page.URL = pathImage

            for subScrolls in templateContainer.subviews
            {
                if let scroll = subScrolls as? UIScrollView
                {
                    if media[scroll.tag - 1].absoluteString != ""
                    {
                        let video = Media()
                        video.setFrame(scroll.frame)
                        video.setLocalURL(saveLocalVideo(media[scroll.tag - 1]))
                        page.data.append(video)
                    }
                    else {
                        
                    }
                }
            }
        
        

            comics.page.append(page)
        
        }
        
     
        navigationController?.popViewControllerAnimated(true)
    }
    
    func saveLocalVideo (localPatch: NSURL) -> Int {
        let videoID =  Int(arc4random_uniform(600)+1)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let pathVideo = "\(pathDocuments)/\(videoID).MOV"
        let videoData = NSData(contentsOfURL: localPatch)
        
        videoData?.writeToFile(pathVideo, atomically: false)
        print(pathVideo)
        return videoID
    }
    
    func showAlertMessage(alertTitle alertTitle: String, alertMessage: String) {
        
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlertVC.addAction(okAction)
        
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
}




extension UIView {
    func saveImageFromView(path path:String) {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageJPEGRepresentation(image, 0.4)?.writeToFile(path, atomically: true)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
    }}