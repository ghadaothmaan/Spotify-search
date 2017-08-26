//
//  ViewController.swift
//  Spot
//
//  Created by gee on 8/20/17.
//  Copyright © 2017 gee. All rights reserved.
//

import UIKit
import Alamofire

struct post {
    let image: UIImage!
    let name: String!
}

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var posts = [post]()
    
    var searchURL = String()
    
    let accessToken: HTTPHeaders = ["Authorization": "Bearer BQC4jldDic3HEYDWrtBJT_5-u0vHA1kp570iDqpuN7SlBqM5OCHbwgyTjpVjvGAwl9a6RrpqEtlkQFkTKHuotyyzuqP8qJiK0pndtw-dGKJscg24MDmnmbWqaO4ZHUszOhpG8Jjd_A"]
    
    typealias JSONStandard = [String: AnyObject]

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)&type=track"
        
        print(searchURL)
        
        callAlamo(url: searchURL, header: accessToken)
        
        self.view.endEditing(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    Alamofire.request(searchURL, method: .get, parameters: ["q":"Arctic Monkeys", "type":"track"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+ accessToken]).responseJSON { response in
//    print(response)﻿}

    
    func callAlamo(url: String, header: HTTPHeaders) {
        Alamofire.request(url, headers: accessToken).responseJSON(completionHandler: {
            response in
            // search how to do it using response.result.value
            self.parseData(JSONData: response.data!)
        })
        
    }
    
    func parseData(JSONData: Data) {
        do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            print(readableJSON)
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                if let items = tracks["items"] as? [JSONStandard] {
                    for i in 0..<items.count {
                        let item = items[i]
                        let name = item["name"] as! String
                        
                        if let album = item["album"] as? JSONStandard {
                            if let images = album["images"] as? [JSONStandard] {
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                
                                let mainImage = UIImage(data: mainImageData! as Data)
                                
                                posts.append(post.init(image: mainImage, name: name))
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    // number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // cell for each row at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        
        mainImageView.image = posts[indexPath.row].image
        
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        
        mainLabel.text = posts[indexPath.row].name
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioVC
        
        vc.image = posts[indexPath!].image
        vc.mainSongTitle = posts[indexPath!].name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}




