//
//  ViewController.swift
//  IMDBAranda
//
//  Created by luis cabarique on 1/29/15.
//  Copyright (c) 2015 Cabarique Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let api_key = "28499075fc4a6412fc09ef87aedbc359"

    @IBOutlet weak var text_result: UITextView!
    
    @IBAction func searchText(search: UITextField) {
        text_result.text = search.text
        let url = NSURL(string: "https://api.themoviedb.org/3/tv/?api_key=\(api_key)")
        var post:NSString = "api_key=\(api_key)"
        NSLog("PostData: %@",post);
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

