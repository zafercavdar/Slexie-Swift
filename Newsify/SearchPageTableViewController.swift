//
//  SearchPageTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class AdvancedGestureRecognizer: UITapGestureRecognizer {
    var tappedCell = UITableViewCell()
}

struct SearchPostsPresentation {
    
    struct SearchPostPresentation {
        var id: String
        var owner: String
        var image: UIImage
        var tagList: String
        var likers: [String]
        var likeCount: Int
        var liked: Bool
    }
    
    var searchPosts: [SearchPostPresentation] = []
    
    mutating func update(withState state: SearchPostViewModel.State){
        
        searchPosts = state.searchPosts.map({ (searchPost) -> SearchPostPresentation in
            let owner = searchPost.username
            let image = searchPost.photo
            var tagText = ""
            for tag in searchPost.tags{
                tagText += "#\(tag) "
            }
            let tagList = tagText
            let id = searchPost.id
            let likers = searchPost.likers
            let likeCount = searchPost.likeCount
            let liked = searchPost.isAlreadyLiked
            return SearchPostPresentation(id: id, owner: owner, image: image!, tagList: tagList, likers: likers, likeCount: likeCount, liked: liked)
        })
    }
}



class SearchPageTableViewController: UITableViewController, UISearchResultsUpdating {
    
    private struct Identifier {
        static let SearchFeedCell = "SearchFeedItemCell"
    }
    
    private var model = SearchPostViewModel()
    private let loadingView = LoadingView()
    private var presentation = SearchPostsPresentation()


    var searchController = UISearchController(searchResultsController: nil)
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ..."
        //searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = preferredLanguage.NavBarSearch
        
        self.definesPresentationContext = true
        configureSearchController()

        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        
    }
    
    // MARK: State functions
    
    func applyState(state: SearchPostViewModel.State) {
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: SearchPostViewModel.State.Change) {
        switch change {
        case .posts(let collectionChange):
            presentation.update(withState: model.state)
            switch collectionChange {
            case .reload:
                self.tableView.reloadData()
            }
        case .none:
            break
        }
    }
    
    // MARK: Search Bar actions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //model.cleanSearchPosts()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        model.cleanSearchPosts()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercaseString
        model.fetchSearchPosts(searchString!) { }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if presentation.searchPosts.count > 0 {
            return 1
        } else { return 0 }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.searchPosts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feedPresentation = presentation.searchPosts[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.SearchFeedCell, forIndexPath: indexPath) as! SearchFeedItemCell
        
        cell.id = feedPresentation.id
        cell.usernameLabel.text = feedPresentation.owner
        cell.photoView.image = feedPresentation.image
        cell.tagsLabel.text = feedPresentation.tagList
        
        cell.tapRecognizer.addTarget(self, action: #selector(photoTapped(_:)))
        cell.tapRecognizer.numberOfTapsRequired = 2
        cell.tapRecognizer.numberOfTouchesRequired = 1
        cell.photoView.gestureRecognizers = []
        cell.photoView.gestureRecognizers!.append(cell.tapRecognizer)
        cell.tapRecognizer.tappedCell = cell
        
        if feedPresentation.liked {
            cell.heart.image = UIImage(named: "Filled Heart")
        } else {
            cell.heart.image = UIImage(named: "Empty Heart")
        }
        
        cell.likeCount.text = String(feedPresentation.likeCount)

        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func photoTapped(sender: AdvancedGestureRecognizer){
        let cell = (sender.tappedCell as! SearchFeedItemCell)
        let id = cell.id
        print(id)
        
        let controller = FirebaseController()

        model.likePhoto(id)
        
        for searchPost in presentation.searchPosts {
            if searchPost.id == id {
                cell.heart.image = UIImage(named: "Filled Heart")
                
                if !searchPost.likers.contains(controller.getUID()!) {
                    cell.likeCount.text = String(searchPost.likeCount + 1)
                }
            }
        }

        
        UIView.animateWithDuration(3.0, delay: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            cell.likedView.alpha = 1
            
            }, completion: {
                (value:Bool) in
                
                cell.likedView.hidden = false
        })
        
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            cell.likedView.alpha = 0
            
            }, completion: {
                (value:Bool) in
                
                cell.likedView.hidden = true
        })
    }
}
