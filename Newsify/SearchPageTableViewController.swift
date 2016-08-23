//
//  SearchPageTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct SearchPostsPresentation {
    
    struct SearchPostPresentation {
        var owner: String
        var image: UIImage
        var tagList: String
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
            return SearchPostPresentation(owner: owner, image: image!, tagList: tagList)
        })
    }
}



class SearchPageTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    private struct Identifier {
        static let SearchFeedCell = "SearchFeedItemCell"
    }
    
    private var model = SearchPostViewModel()
    private let loadingView = LoadingView()
    private var presentation = SearchPostsPresentation()


    var searchController = UISearchController()
    var shouldShowSearchResults: Bool = false
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        model.cleanSearchPosts()

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

        configureSearchController()
        model.cleanSearchPosts()
        
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
        shouldShowSearchResults = true
        model.cleanSearchPosts()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        model.cleanSearchPosts()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercaseString
            
        model.fetchSearchPosts(searchString!) {
        }
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
        
        cell.usernameLabel.text = feedPresentation.owner
        cell.photoView.image = feedPresentation.image
        cell.tagsLabel.text = feedPresentation.tagList
        
        return cell
    }
    
}
