//
//  DataService.swift
//  FoodTrackerUseCoreData
//
//  Created by Tran Ngoc Nam on 5/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import CoreData

class DataService {
    static let shared: DataService = DataService()
    
    private var _fetchedResultsController: NSFetchedResultsController<MealEntity>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<MealEntity> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchedRequest: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
        
        fetchedRequest.fetchBatchSize = 20
        fetchedRequest.predicate = nil
        let nameMeal = NSSortDescriptor(key: "name", ascending: true)
        fetchedRequest.sortDescriptors = [nameMeal]
        
        _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: AppDelegate.context, sectionNameKeyPath: nil, cacheName: "Master")
        
        do {
            try _fetchedResultsController?.performFetch()
            if let objects = _fetchedResultsController?.fetchedObjects {
                if objects.count == 0 {
                    loadSampleMeals()
                    try _fetchedResultsController?.performFetch()
                }
            }
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    func saveDataToCoreData() {
        let context = _fetchedResultsController?.managedObjectContext
        do {
            try context?.save()
            print("CoreData Saved")
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
    }
    
    func deleteDataInCoreData(index: IndexPath) {
        let context = _fetchedResultsController?.managedObjectContext
        context?.delete((_fetchedResultsController?.object(at: index))!)
        saveDataToCoreData()
    }
    
    private func createNewMeal(name: String, photoName: String, rating: Int) {
        let capreseSalad = MealEntity(context: AppDelegate.context)
        capreseSalad.name = name
        capreseSalad.photo = UIImage(named: photoName)
        capreseSalad.rating = Int32(rating)
    }
    
    private func loadSampleMeals() {
        createNewMeal(name: "Caprese Salad", photoName: "meal1", rating: 4)
        createNewMeal(name: "Chicken and Potatoes", photoName: "meal2", rating: 5)
        createNewMeal(name: "Pasta with Meatballs", photoName: "meal3", rating: 3)
        saveDataToCoreData()
    }
    
}
