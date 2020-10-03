//
//  StorageManager.swift
//  CoreDataDemoApp
//
//  Created by VICTOR on 02.10.2020.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemoApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var context: NSManagedObjectContext { return self.persistentContainer.viewContext }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch let error {
            print(error)
            return []
        }
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func deleteTask(at index: Int) {
        let tasks = fetchData()
        
        context.delete(tasks[index])
        saveContext()
    }
    
    func save(_ taskName: String, at index: Int?) {
        
        var tasks = fetchData()
        // если новое задание
        if index == nil {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
            guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
            task.name = taskName
            tasks.append(task)
        } else {
            // если редактирование старого
            let task = tasks[index!] as NSManagedObject
            task.setValue(taskName, forKey: "name")
        }
        saveContext()
    }
    
}

//func deleteAll() {
//            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//            if let tasks = try? context.fetch(fetchRequest) {
//                for task in tasks {
//                    tasks.delete(task)
//                }
//            }
//    saveContext()
//}
