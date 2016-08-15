//
//  RandomBase.swift
//  Newsify
//
//  Created by Zafer Cavdar on 10/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import FirebaseDatabase

class RandomBase {

    let wordBank: [String] = ["Njorth","hierarchising","transparietal","overspecializing","latest","Prajna","topeka","mashhad","antiradiating","pesky","Guerrilla","trouser","odour","noesis","huysmans","Wheel","connubiality","beelike","unprintable","agarita","Incogitable","chubbier","volga","noncoagulable","kernite","Unpredacious","penetrate","chairlift","lustrously","prepossession","Decigram","uredinia","diver","princeship","superglottic","Ratatouille","photochromy","wmo","cirrous","saut","Goodby","floy","thymbraeus","labialization","indicatively","Carbolize","skiograph","abortively","rockfishes","grayce","Farci","snuffiness","damaskeen","arri","auscultating","Sheers","quadrivia","redeployment","unbud","multiracial","Graphicly","semihard","tapetal","edibles","shield","Chyack","commend","palsylike","salivator","vulvitis","Milledgeville","athenaeus","glaucomatous","lifer","bawdily","Nothus","nova","unfrizzly","targum","virulently","Bravoing","decaliter","lubricant","besague","reheel","Dacryagogue","overclemency","untenderized","riel","unpurposed","Heartsickness","kulturkampf","leukemia","expeditated","punnet","Teresa","retest","magazinish","grandparent","idola"]
    
    let colorBank: [String] = ["white","black","blue","green","red","yellow","pink","purple","grey","violet"]
    let tonesBank: [String] = ["dark","light", ""]

    /*func createUser() {
        let userID = getRandomUserID()
        let username = getRandomUsername()
        let password = getRandomPassword()
        let profileType = getRandomProfileType()
        
        FireBaseDatabaseOperations.writeFirebaseForRandomUser(["users",userID,"username"], data: username)
        FireBaseDatabaseOperations.writeFirebaseForRandomUser(["users",userID,"password"], data: password)
        FireBaseDatabaseOperations.writeFirebaseForRandomUser(["users",userID,"profile-type"], data: profileType)

        let numOfPhotos = getRandomIntBetween(5, 10)
        for _ in 0..<numOfPhotos {
            let photoID = getRandomContentID()
            let color = getRandomColor()
            let compressionRate = getRandomCompressionRate()
            let tags = getRandomTags()
            
            FireBaseDatabaseOperations.writeFirebaseForRandomUser(["users",userID,"photo",photoID,"color"], data: color)
            FireBaseDatabaseOperations.writeFirebaseForRandomUser(["users",userID,"photo",photoID,"compressionRate"], data: compressionRate)
            FireBaseDatabaseOperations.writeFirebaseForRandomUser(["users",userID,"photo",photoID,"tags"], data: tags)
        }
        
        print("User generated.")
    }*/
    
    
    
    func randomAlphaNumericString(length: Int, isAlpha: Bool = true, isUpper: Bool = true, isLower: Bool = true) -> String {
        
        var allowedChars = ""
        
        if isLower{
             allowedChars += "abcdefghijklmnopqrstuvwxyz"
        }
        if isUpper {
            allowedChars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if isAlpha {
            allowedChars += "0123456789"
        }
        
        
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    func getRandomUsername() -> String{
        return randomAlphaNumericString(8, isAlpha: false, isUpper: false, isLower: true)
    }
    
    func getRandomPassword() -> String{
        return randomAlphaNumericString(10, isAlpha: true, isUpper: true, isLower: true)
    }
    
    func getRandomProfileType() -> String {
        let randomNum = Int(arc4random_uniform(10))
        if randomNum > 7 {
            return "Private"
        } else {
            return "Public"
        }
    }
    
    func getRandomUserID() -> String{
        return randomAlphaNumericString(28)
    }
    
    func getRandomContentID() -> String {
        return randomAlphaNumericString(32, isAlpha: true, isUpper: false, isLower: true)
    }
    
    func getRandomColor() -> String {
        let toneIndex = Int(arc4random_uniform(UInt32(tonesBank.count)))
        let colorIndex = Int(arc4random_uniform(UInt32(colorBank.count)))
        if tonesBank[toneIndex] != "" {
            return  "\(tonesBank[toneIndex]) \(colorBank[colorIndex])"
        } else {
            return "\(colorBank[colorIndex])"
        }
    }
    
    func getRandomCompressionRate() -> Float {
        let result = Float(arc4random_uniform(50)) / 100.00
        return result + 0.50
    }
    
    func getRandomIntBetween(min: Int, _ max: Int) -> Int{
        let range = UInt32(max-min)
        return Int(arc4random_uniform(range)) + min
    }
    
    func getRandomTags() -> [String] {
        let numOfTags = getRandomIntBetween(4, 9    )
        var resultTags: [String] = []
        for _ in 0..<numOfTags{
            let index = Int(arc4random_uniform(UInt32(wordBank.count)))
            resultTags.append(wordBank[index])
        }
        return resultTags
    }
    
    
    
}
