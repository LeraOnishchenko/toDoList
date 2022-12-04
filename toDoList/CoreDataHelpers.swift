//
//  CoreDataHelpers.swift
//  toDoList
//
//  Created by lera on 01.12.2022.
//

import Foundation
import CoreData


final class CoreDataService {
    
    lazy private var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "toDoList")
        container.loadPersistentStores { _, error in

        }
        return container
    }()
    
    private var context: NSManagedObjectContext { container.viewContext }
    
    private(set) static var shared: CoreDataService = .init()
    
    @discardableResult
    func create<T: NSManagedObject>(_ type: T.Type, _ handler: ((T) -> ())? = nil) -> T {
        let newObject = T(context: context)
        handler?(newObject)
        return newObject
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        try? context.save()
    }
    
    func write(_ handler: () -> ()) {
        handler()
        saveContext()
        
    }
        
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate?) -> [T] {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        fetchRequest.predicate = predicate
        do{
            return (try context.fetch(fetchRequest) as? [T]) ?? []
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            return []
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
}


@propertyWrapper
class Fetch<T: NSManagedObject> {
    
    var wrappedValue: [T] = CoreDataService.shared.fetch(T.self, predicate: NSPredicate(format: "parent == nil")) {
        didSet{
            return
        }
       
    }
    
    public func configure(with parentTask: Task?){
        guard let parentTask else {
            wrappedValue = CoreDataService.shared.fetch(T.self, predicate: NSPredicate(format: "parent == nil"))
            return
        }
        wrappedValue = parentTask.subtasks?.allObjects as! [T]
    }
}
