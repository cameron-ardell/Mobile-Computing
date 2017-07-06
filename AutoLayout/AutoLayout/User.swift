//
//  User.swift
//  AutoLayoutPractice
//
//  Created by Eric Chown on 2/27/16.
//  Copyright © 2016 Eric Chown. All rights reserved.
//

import Foundation

struct User
{
    let name: String
    let company: String
    let login: String
    let password: String
    
    static func login(login: String, password: String) -> User? {
        if let user = database[login] {
            if user.password == password {
                return user
            }
        }
        return nil
    }
    
    static let database: Dictionary<String, User> = {
        var theDatabase = Dictionary<String, User>()
        for user in [
            User(name: "John Appleseed", company: "Apple", login: "japple", password:  "foo"),
            User(name: "Beyonce", company: "Northern Bites", login: "bey", password: "foo"),
            User(name: "Clayton Rose", company: "Bowdoin", login: "crose", password: "foo"),
            User(name: "Guy Criminal", company: "Crime Inc.", login: "guy", password: "foo")] {
            theDatabase[user.login] = user
        }
        return theDatabase
    }()
}