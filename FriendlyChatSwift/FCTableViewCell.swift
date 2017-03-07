//
//  FCTableViewCell.swift
//  FriendlyChatSwift
//
//  Created by Jennifer Person on 9/26/16.
//  Copyright © 2016 Google Inc. All rights reserved.
//

import UIKit
import Firebase

class FCTableViewCell: UITableViewCell {
    let imageCache = NSCache<NSString, UIImage>()
    var placeholderImage = UIImage(named: "ic_account_circle")

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func createChat(message: FIRDataSnapshot, user: FIRUser) {
        
         let name = message.childSnapshot(forPath: Constants.MessageFields.name).value as? String ?? "none found"
         if let text = message.childSnapshot(forPath: Constants.MessageFields.text).value as? String {
            self.populateCellWithChat(user, name: name, text: text)
         }
         if let photoUrl = message.childSnapshot(forPath: Constants.MessageFields.photoUrl).value as? String {
            self.populateCellWithChat(user, name: name, photoUrl: photoUrl)
        }
        
    }
    
    func populateCellWithChat(_ user: FIRUser?, name: String, photoUrl: String? = nil, text: String? = nil) {
        if let photoUrl = photoUrl {
            self.textLabel?.text = "sent by: \(name)"
            // image already exists in cache
            if let cachedImage = imageCache.object(forKey: photoUrl as NSString) {
                self.imageView?.image = cachedImage
                self.setNeedsLayout()
            } else {
                // download image
                
                FIRStorage.storage().reference(forURL: photoUrl).data(withMaxSize: INT64_MAX){ data, error in
                    guard error == nil else {
                        print("Error downloading: \(error!)")
                        return
                    }
                    let messageImage = UIImage.init(data: data!, scale: 50)
                    self.imageCache.setObject(messageImage!, forKey: photoUrl as NSString as NSString)
                    self.imageView?.image = messageImage
                    self.setNeedsLayout()
                }
            }
        } else {
            self.textLabel?.text = name + ": " + text!
            self.imageView?.image = placeholderImage
        }
    }
}
