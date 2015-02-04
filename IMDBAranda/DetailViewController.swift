//
//  DetailViewController.swift
//  IMDBAranda
//
//  Created by luis cabarique on 2/1/15.
//  Copyright (c) 2015 Cabarique Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movie : Movie!
    var episodes : [Episode]!
    var tvShow : NSDictionary!
    let api_key = "28499075fc4a6412fc09ef87aedbc359"
    let image_url = "https://image.tmdb.org/t/p/w185"
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var seasons: UITableView!
    var selectedRowIndex: NSIndexPath = NSIndexPath(forRow: -1, inSection: 0)

    
    var items: [String] = ["We", "Heart", "Swift"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.seasons.registerClass(UITableViewCell.self, forCellReuseIdentifier: "seasonCell")
        self.genres.sizeToFit()
        self.name.sizeToFit()
        self.overview.layer.borderWidth = 1
        var text : String = "hello "
        self.overview.text = text as String
        
        if let parseJSON = self.tvShow {
            //println(parseJSON)
            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
            self.name.text = parseJSON["name"] as NSString
            self.overview.text = parseJSON["overview"] as NSString
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
            
            
            
        }
        else {
            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
            
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberSeasons : Int!
        if let parseJSON = self.tvShow {
            let seasons = self.tvShow.valueForKey("seasons") as NSArray;
            numberSeasons = seasons.count
        }
        return numberSeasons;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.seasons.dequeueReusableCellWithIdentifier("seasonCell") as UITableViewCell
        //var cell:UITableViewCell = self.seasons.dequeueReusableCellWithIdentifier("seasonCell") as UITableViewCell
        
        //var episodesTemp = self.episodes[indexPath.row]
        
        cell.textLabel?.text = "Temporada \(indexPath.row)"
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        self.selectedRowIndex = indexPath
        
        //tableView.beginUpdates()
        //tableView.endUpdates()
        
    }

    /*
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == self.selectedRowIndex.row {
            return 100
        }
        return 44
    }*/

    
    
    
    //Search for seasons
    func searchSeasons(idTV: Int, seasonNumber: Int) -> NSArray{
        var searchSeasonsArray : NSArray!
        var seasonDone = dispatch_semaphore_create(0);
        let url = NSURL(string: "https://api.themoviedb.org/3/tv/\(idTV)/season/\(seasonNumber)?api_key=\(api_key)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                //println("Response: \(response)")
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                if let parseJSON = json {
                    //println(parseJSON)
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    searchSeasonsArray = parseJSON["episodes"] as NSArray
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
                dispatch_semaphore_signal(seasonDone);
            }
        }
        task.resume()
        dispatch_semaphore_wait(seasonDone, DISPATCH_TIME_FOREVER);
        return searchSeasonsArray
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "episodesDetail" {
            let itemDetailViewController = segue.destinationViewController as EpisodesTableViewController
            let indexPath = self.seasons.indexPathForSelectedRow()!
            itemDetailViewController.title = "Temporada \(indexPath.row)"
            var episodes = self.searchSeasons(movie.id, seasonNumber: indexPath.row)
            itemDetailViewController.episodes = episodes
            
        }
    }
    
}
