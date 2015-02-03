//
//  DetailViewController.swift
//  IMDBAranda
//
//  Created by luis cabarique on 2/1/15.
//  Copyright (c) 2015 Cabarique Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var movie : Movie!
    let api_key = "28499075fc4a6412fc09ef87aedbc359"
    let image_url = "https://image.tmdb.org/t/p/w185"
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genres.sizeToFit()
        self.name.sizeToFit()
        self.overview.layer.borderWidth = 1
        var text : String = "hello "
        self.overview.text = text as String
        let url = NSURL(string: "https://api.themoviedb.org/3/tv/\(movie.id)?api_key=\(api_key)")
        var done = dispatch_semaphore_create(0);
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            //println("Response: \(response)")
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    //println(parseJSON)
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    self.name.text = parseJSON["name"] as NSString
                    var genderString = ""
                    if (parseJSON["genres"] as? NSArray != nil){
                        let genderArray = parseJSON["genres"] as NSArray
                        for item in genderArray{
                            genderString += item.valueForKey("name") as String
                            genderString += ", "
                        }
                    }
                    
                    self.genres.text = genderString
                    var poster_path = "nALNtBMQVf27H4HiSZnKNfFVvXX.jpg"
                    if (parseJSON["poster_path"] as? String != nil){
                        poster_path = parseJSON["poster_path"] as String
                    }
                    let url = NSURL(string: "\(self.image_url)\(poster_path)")
                    let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                    let imageTmpl = UIImage(data: data!)
                    self.image.image = imageTmpl
                    
                    
                    dispatch_semaphore_signal(done);

                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        }
        
        task.resume()
        dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
        
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
