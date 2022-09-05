//
//  CategoryController.swift
//  ToDo
//
//  Created by Chris Boshoff on 2022/09/05.
//

import UIKit
import CoreData

class CategoryController: UITableViewController {

    // MARK: - Initializers
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    

    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.titleLabel.text = categories[indexPath.row].name
        cell.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10.0, right: 0))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self!.context.delete(self!.categories[indexPath.row])
            self!.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self!.saveCategories()
        }
        delete.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            var titleTextField = UITextField()
            let alert          = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert)
            let action         = UIAlertAction(title: "Update", style: .default) { action in
                let newCategory              = Category(context: self!.context)
                newCategory.name             = titleTextField.text!
                self!.categories[indexPath.row] = newCategory
                self!.saveCategories()
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                }
            }
            alert.addTextField { alertTextField in
                alertTextField.placeholder            = "Category Name"
                titleTextField                        = alertTextField
                titleTextField.font                   = UIFont(name: "Avenir", size: 19)
                
            }
            alert.addAction(action)
            self!.present(alert, animated: true)
        }
        edit.backgroundColor = UIColor(red:0.44, green:0.79, blue:0.81, alpha:1.0)
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ListController
        if let indexPath  = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func addCategoryTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert     = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action    = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategories()
        }
        alert.addAction(action)
        alert.addTextField { field in
            textField                        = field
            textField.placeholder            = "Add a new category"
            textField.autocapitalizationType = .words
            textField.returnKeyType          = .done
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Core Data
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
}
