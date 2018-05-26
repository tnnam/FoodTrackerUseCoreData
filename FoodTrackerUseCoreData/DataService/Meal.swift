//
//  Meal.swift
//  FoodTrackerUseCoreData
//
//  Created by Tran Ngoc Nam on 5/26/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit

class Meal: Equatable {
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    init(name:String, photo: UIImage?, rating: Int) {
        self.name = name
        self.photo = photo
        self.rating = rating
    }
}
