//
//  ViewController.swift
//  toDoList
//
//  Created by lera on 01.12.2022.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate


class ViewController: UIViewController {
    private var parentTask: Task?
    @Fetch<Task> public var tasks

    
    @IBOutlet private weak var myToDo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet private weak var backButton: UIButton!
    @IBAction func createTask(_ sender: Any) {
        showAlert()
        tableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        parentTask = parentTask?.parent
        if parentTask == nil{
            backButton.isHidden = true

        }
        _tasks.configure(with: parentTask)
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    
    private func showAlert(for tasks: Task? = nil) {
        let createListAlert = UIAlertController(title: "New!", message: "Write list title", preferredStyle: .alert)
        createListAlert.addTextField()
        createListAlert.textFields?.first?.text = tasks?.title

        createListAlert.addAction(.init(title: "Save", style: .default) { [weak self] _ in
            if let name = createListAlert.textFields?.first?.text {
                if tasks == nil {
                    self?.saveNewTask(with: name)
                } else {
                    CoreDataService.shared.write {
                        tasks?.title = name
                    }
                }
                self?.tableView.reloadData()
            }
        })
        present(createListAlert, animated: false)
    }
    
    private func saveNewTask(with name: String) {

        guard let parentTask else{
            CoreDataService.shared.write {
                CoreDataService.shared.create(Task.self) { object in
                    object.title = name
                    object.done = false
                    object.dateOfCreation = .init()
                }
            }
            fetchCoreDataObjects()
            return
        }
        
        parentTask.addToSubtasks(CoreDataService.shared.create(Task.self) { object in
            object.title = name
            object.dateOfCreation = .init()
        })
        CoreDataService.shared.saveContext()
        fetchCoreDataObjects()
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        backButton.isHidden = true
        fetchCoreDataObjects()
    }
    func fetchCoreDataObjects(){
        _tasks.configure(with: parentTask)
        if tasks.count >= 1 {
            tableView.isHidden = false
            myToDo.isHidden = true
            
        } else {
            tableView.isHidden = true
            myToDo.isHidden = false
        }
        
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _tasks.configure(with: parentTask)
       return tasks.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ListCell.self), for: indexPath) as! ListCell
        //cell.checkboxBool = tasks[indexPath.row].done
       // cell.accessoryType = .detailDisclosureButton
        cell.config(from: (tasks[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let parentTask else{
                CoreDataService.shared.write {
                    CoreDataService.shared.delete(tasks[indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                fetchCoreDataObjects()
                return
            }
            parentTask.removeFromSubtasks(tasks[indexPath.row])
            CoreDataService.shared.write {
                CoreDataService.shared.delete(tasks[indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            CoreDataService.shared.saveContext()
            fetchCoreDataObjects()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentTask = tasks[indexPath.row]
        _tasks.configure(with: parentTask)
        fetchCoreDataObjects()
        backButton.isHidden = false
        tableView.reloadData()
    }
    
}

