//
//  TaskListViewController.swift
//  CoreDataDemoApp
//
//  Created by Alexey Efimov on 30.09.2020.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    
    private enum actionType {
        case saveNewTask, saveEditedTask, deleteTask
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        //    StorageManager.shared.deleteAll()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = StorageManager.shared.fetchData()
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        showAlert(with: "New Task", and: "What do you want to do?", newTask: true, nil)
    }
    
    private func showAlert(with title: String, and message: String, newTask: Bool, _ taskIndex: Int?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if newTask {
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.doAction(.saveNewTask, taskName: task, at: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alert.addTextField()
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
        } else {
            
            guard let index = taskIndex else {return}
            alert.addTextField()
            alert.textFields?.first?.text = tasks[index].name
            
            let saveEditedAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.doAction(.saveEditedTask, taskName: task, at: index)
            }
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.doAction(.deleteTask, taskName: nil, at: index)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(saveEditedAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
        }
        present(alert, animated: true)
    }
    
    private func doAction(_ action: actionType, taskName: String?, at index: Int?) {
        switch action {
        case .saveNewTask: StorageManager.shared.save(taskName!, at: nil)
        case .saveEditedTask: StorageManager.shared.save(taskName!, at: index)
        case .deleteTask: StorageManager.shared.deleteTask(at: index!)
        }
        viewWillAppear(true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let taskIndex = indexPath.row
        showAlert(with: "Editing mode", and: "You can edit or delete", newTask: false, taskIndex)
    }
}
