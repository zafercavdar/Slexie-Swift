//
//  LanguageTVController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 02/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

enum LanguageIdentifier: String {
    case Turkish = "tr"
    case English = "en"
    case Russian = "ru"
    case NULL = "nil"
}

class LanguageTVModel{
    
    let languages = [LanguageIdentifier.Turkish, LanguageIdentifier.English, LanguageIdentifier.Russian]
    let controller = FirebaseController()
    
    func fetchUserLanguage(completion callback: (identifier: LanguageIdentifier) -> Void) {
        controller.fetchUserLanguage { (identifier) in
            switch identifier {
            case LanguageIdentifier.Turkish.rawValue:
                callback(identifier: LanguageIdentifier.Turkish)
            case LanguageIdentifier.English.rawValue:
                callback(identifier: LanguageIdentifier.English)
            case LanguageIdentifier.Russian.rawValue:
                callback(identifier: LanguageIdentifier.Russian)
            default:
                callback(identifier: LanguageIdentifier.NULL)
            }
        }
    }
    
    func changeLanguage(identifier: LanguageIdentifier, completion callback: () -> Void){
        controller.changeLanguage(identifier) { 
            callback()
        }
    }
}

class LanguageTVController: UITableViewController {
    
    struct LanguageTVPresentation{
        
        struct Language{
            var identifier: LanguageIdentifier
            var languageName: String
        }
        
        var languages: [Language] = []
        
        mutating func update(withModel model: LanguageTVModel){
            
            self.languages = model.languages.map({ (langIdentifier) -> Language in
                
                let identifier = langIdentifier
                var languageName = ""
                
                switch langIdentifier {
                case .Turkish:
                    languageName = "Türkçe"
                case .English:
                    languageName = "English"
                case .Russian:
                    languageName = "русский"
                case .NULL:
                    languageName = "NULL"
                }
                
                return Language(identifier: identifier, languageName: languageName)
            })
        }
    }

    
    private let model = LanguageTVModel()
    private let router = LanguageTVRouter()
    private var presentation = LanguageTVPresentation()
    
    private var cancelButton = UIBarButtonItem()
    private var applyButton = UIBarButtonItem()
    
    private var userLanguageIdentifier = LanguageIdentifier.NULL
    private var checkMarkIndex = -1
    
    private struct Identifier{
        static let LanguageTVCell = "LanguageTVCell"
    }
    
    private struct RouteID{
        static let Cancel = "Cancel"
        static let Apply = "Apply"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        cancelButton = UIBarButtonItem(image: UIImage(named: "backButton"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        model.fetchUserLanguage { [weak self] (identifier) in
            
            guard let strongSelf = self else { return }
            strongSelf.userLanguageIdentifier = identifier
            
            for i in 0..<strongSelf.presentation.languages.count{
                if strongSelf.presentation.languages[i].identifier == identifier{
                    strongSelf.checkMarkIndex = i
                    break
                }
            }
            
            self?.tableView.reloadData()

        }
        
        presentation.update(withModel: model)
    }
    
    func cancelButtonPressed(sender: UIBarButtonItem){
        self.router.routeTo(RouteID.Cancel, VC: self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIColors()
        setUITitles()
    }
    
    private func setUIColors(){
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
    }
    
    private func setUITitles(){
        self.title = localized("Language")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.languages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.LanguageTVCell, forIndexPath: indexPath) as! LanguageTVCell
        
        cell.tintColor = UIColor.reddishColor()
        cell.languageLabel.text = presentation.languages[indexPath.row].languageName
        
        if (checkMarkIndex == indexPath.row){
            cell.accessoryType = .Checkmark
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let title = localized("ChangeLanguage")
        let message = localized("RestartWarning")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.view.tintColor = UIColor.reddishColor()
        
        let noAction = UIAlertAction(title: localized("Cancel"), style: .Default, handler: { (action: UIAlertAction!) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let yesAction = UIAlertAction(title: localized("Change"), style: .Default, handler: { [weak self] (action: UIAlertAction!) in
            
            guard let strongSelf = self else { return }
            let identifier = strongSelf.presentation.languages[indexPath.row].identifier
            
            strongSelf.model.changeLanguage(identifier, completion: {
                strongSelf.router.routeTo(RouteID.Apply, VC: strongSelf)
            })
        })
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
