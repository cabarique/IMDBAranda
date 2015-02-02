//
//  moviesTableViewController.swift
//  IMDBAranda
//
//  Created by luis cabarique on 1/31/15.
//  Copyright (c) 2015 Cabarique Inc. All rights reserved.
//

import UIKit

class moviesTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var movies = [Movie]()
    var searchSeries = [Movie]()
    let api_key = "28499075fc4a6412fc09ef87aedbc359"
    let image_url = "https://image.tmdb.org/t/p/w92/"
    var enableSeach = true

    override func viewDidLoad() {
        super.viewDidLoad()
        var done = dispatch_semaphore_create(0);
        let url = NSURL(string: "http://api.themoviedb.org/3/discover/tv?api_key=\(api_key)")
        
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
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["page"] as? Int
                    let results = parseJSON["results"] as NSArray
                    for item in results{
                        let name : String = item.valueForKey("name") as NSString
                        var poster_path = "nALNtBMQVf27H4HiSZnKNfFVvXX.jpg"
                        if (item.valueForKey("poster_path") as? String != nil){
                            poster_path = item.valueForKey("poster_path") as String
                        }
                        let tvTemp = Movie(type: "serie", name: name, poster_path: poster_path)
                        self.movies.append(tvTemp)
                    }
                    dispatch_semaphore_signal(done);
                    self.tableView.reloadData()
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.searchSeries.count
        } else {
            return self.movies.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("movieCell") as UITableViewCell

        // Configure the cell...
        var movie : Movie
        // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
        if tableView == self.searchDisplayController!.searchResultsTableView {
            movie = self.searchSeries[indexPath.row]
        } else {
            movie = self.movies[indexPath.row]
        }
        
        let url = NSURL(string: "https://image.tmdb.org/t/p/w92/\(movie.poster_path)")
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        let image = UIImage(data: data!)
        
        cell.textLabel!.text = movie.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.imageView?.image = image

        return cell
    }
    
    func searchTV(searchText: String) {
        // Filter the array using the filter method
        if countElements(searchText) > 3 && self.enableSeach{
            var done = dispatch_semaphore_create(0);
            self.enableSeach = false
            self.searchSeries = []
            let url = NSURL(string: "http://api.themoviedb.org/3/search/tv?&search_type=ngram&query=\(searchText)&api_key=\(api_key)")
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                //println("Response: \(response)")
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var err: NSError?
                var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
                
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                    dispatch_semaphore_signal(done);
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                        var page = parseJSON["page"] as? Int
                        let results = parseJSON["results"] as NSArray
                        for item in results{
                            let name : String = item.valueForKey("name") as NSString
                            var poster_path = "nALNtBMQVf27H4HiSZnKNfFVvXX.jpg"
                            if (item.valueForKey("poster_path") as? String != nil){
                                poster_path = item.valueForKey("poster_path") as String
                            }
                            let tvTemp = Movie(type: "serie", name: name, poster_path: poster_path)
                            self.searchSeries.append(tvTemp)
                            
                        }
                        dispatch_semaphore_signal(done);
                        self.enableSeach = true
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("Error could not parse JSON: \(jsonStr)")
                        dispatch_semaphore_signal(done);
                    }
                }
            }
            
            task.resume()
            dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.searchTV(searchString)
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("itemDetail", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "itemDetail" {
            let itemDetailViewController = segue.destinationViewController as UIViewController
            if sender as UITableView == self.searchDisplayController!.searchResultsTableView {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                let destinationTitle = self.searchSeries[indexPath.row].name
                itemDetailViewController.title = destinationTitle
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                let destinationTitle = self.movies[indexPath.row].name
                itemDetailViewController.title = destinationTitle
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
