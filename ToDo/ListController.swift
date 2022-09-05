//
//  ListController.swift
//  ToDo
//
//  Created by Chris Boshoff on 2022/09/05.
//

import UIKit
import CoreData

class ListController: UITableViewController {
    
    // MARK: - Initializers
    var listArray        = [Item]()
    let context          = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        let item = listArray[indexPath.row]
        cell.titleLabel.text = item.title
        cell.accessoryType   = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listArray[indexPath.row].done = !listArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self!.context.delete(self!.listArray[indexPath.row])
            self!.listArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self!.saveItems()
        }
        delete.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            var titleTextField = UITextField()
            
            let alert  = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Update", style: .default) { action in
                
                let newItem                    = Item(context: self!.context)
                newItem.title                  = titleTextField.text!
                self!.listArray[indexPath.row] = newItem
                self!.saveItems()
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
                }
            }
            alert.addTextField { alertTextField in
                alertTextField.placeholder            = "Item Name"
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
    
    
    // MARK: - IBActions
    @IBAction func addItemTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert     = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action    = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem            = Item(context: self.context)
            newItem.title          = textField.text!
            newItem.done           = false
            newItem.parentCategory = self.selectedCategory
            self.listArray.append(newItem)
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder       = "Create new item"
            textField                        = alertTextField
            textField.autocapitalizationType = .words
            textField.returnKeyType          = .done
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Core Data
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving list \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            listArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}


//MARK: - Search bar methods

extension ListController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }            
        }
    }
}
