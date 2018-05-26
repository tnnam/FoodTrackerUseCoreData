//
//  ViewController.swift
//  FoodTrackerUseCoreData
//
//  Created by Tran Ngoc Nam on 5/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import CoreData

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var meal: MealEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        configure()
        updateSaveButtonStates()
    }

    func configure() {
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo as? UIImage
            ratingControl.rating = Int(meal.rating)
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let masterViewController = segue.destination as? MasterViewController {
            print(masterViewController.tableView.indexPathForSelectedRow == nil)
            if masterViewController.tableView.indexPathForSelectedRow == nil && meal == nil {
                meal = MealEntity(context: masterViewController.fetchedResultsController.managedObjectContext)
            }
            meal?.name = nameTextField.text
            meal?.photo = photoImageView.image
            meal?.rating = Int32(ratingControl.rating)
            DataService.shared.saveDataToCoreData()
        }
    }
    
    // MARK: Action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonStates()
        navigationItem.title = nameTextField.text
    }

    private func updateSaveButtonStates() {
        saveButton.isEnabled = nameTextField.text! != ""
    }
}

