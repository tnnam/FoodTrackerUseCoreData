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
    let searchController = UISearchController(searchResultsController: nil)
    var filterMeals : [MealEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        fetchedResultsController.delegate = self
        searchController.searchBar.placeholder = "Search Meal"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
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
        let meal: MealEntity
        if isFiltering() {
            meal = filterMeals[indexPath.row]
        } else {
            meal = fetchedResultsController.object(at: indexPath)
        }
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
        tableView.reloadData()
        //
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mealViewController = segue.destination as? MealViewController else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let meal: MealEntity
        if isFiltering() {
            meal = filterMeals[indexPath.row]
        } else {
            meal = fetchedResultsController.object(at: indexPath)
        }
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
        guard let searchText = searchController.searchBar.text else { return }
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return }
        filterMeals = fetchedObjects.filter({ (meal) -> Bool in
            let foldingNameMealEntity = meal.name?.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current)
            let foldingSearchText = searchText.lowercased().folding(options: .diacriticInsensitive, locale: Locale.current)
            return (foldingNameMealEntity ?? "").contains(foldingSearchText)
        })
        tableView.reloadData()
    }
    
    
}
