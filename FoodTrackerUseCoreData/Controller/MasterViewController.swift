//
//  MasterViewController.swift
//  FoodTrackerUseCoreData
//
//  Created by Tran Ngoc Nam on 5/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {
    
    var fetchedResultsController = DataService.shared.fetchedResultsController
    
    var filterMeals : [MealEntity] = []
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        fetchedResultsController.delegate = self
        
        // setup searchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Meal"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        navigationItem.hidesSearchBarWhenScrolling = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return filterMeals.count
        }
        return fetchedResultsController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MealTableViewCell
        let meal = !searchController.isActive ? fetchedResultsController.object(at: indexPath) : filterMeals[indexPath.row]
        configureCell(cell, with: meal)
        return cell
    }

    func configureCell(_ cell: MealTableViewCell, with meal: MealEntity) {
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo as? UIImage
        cell.ratingControl.rating = Int(meal.rating)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataService.shared.deleteDataInCoreData(index: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mealViewController = segue.destination as? MealViewController else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let meal = !searchController.isActive ? fetchedResultsController.object(at: indexPath) : filterMeals[indexPath.row]
        mealViewController.meal = meal
        searchController.isActive = false
    }

}

extension MasterViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)! as! MealTableViewCell, with: anObject as! MealEntity)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)! as! MealTableViewCell, with: anObject as! MealEntity)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension MasterViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
            filterMeals = fetchedObjects.filter({ (meal) -> Bool in
                return meal.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
            tableView.reloadData()
        }
    }
}
