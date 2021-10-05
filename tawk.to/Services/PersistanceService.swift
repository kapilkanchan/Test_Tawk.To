//
//  PersistanceService.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 29/09/21.
//

import Foundation
import CoreData

class PersistanceService {
    
    private init() {}
    
    static let shared = PersistanceService()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PersistanceStoreModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func save () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T:NSManagedObject>(_ type: T.Type, id: Int, completion: @escaping ([T]) -> Void) {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.fetchLimit = 30
        request.predicate = NSPredicate(format: "id > \(id)")
        do {
            let objects = try context.fetch(request)
            completion(objects)
        } catch {
            print(error)
            completion([])
        }
    }
    
    func fetchProfile<T:NSManagedObject>(_ type: T.Type, name: String, completion: @escaping ([T]) -> Void) {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "login == %@",name)
        do {
            let objects = try context.fetch(request)
            completion(objects)
        } catch {
            print(error)
            completion([])
        }
    }

    
    func isExist<T:NSManagedObject>(_ type: T.Type, id: Int?, name: String?, for profile: Bool) -> Bool {
        let context = persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: type))
        fetchRequest.predicate = profile ? NSPredicate(format: "login == %@",name!) : NSPredicate(format: "id > \(id!)")
        do {
            let count = try context.count(for: fetchRequest)
//            let res = try context.fetch(fetchRequest)
            return count > 0 ? true : false
        } catch {
            return false
        }
    }
    
    func batchUpdateRequest(entityName: String, updateAttribute: String, updateValue: String, name: String) {
        let context = persistentContainer.viewContext

        let batchRequest = NSBatchUpdateRequest(entityName: entityName)
        batchRequest.propertiesToUpdate = [ updateAttribute : updateValue]
        batchRequest.predicate = NSPredicate(format: "login == %@",name)
        batchRequest.resultType = .updatedObjectIDsResultType

        do{
           let objectIDs = try context.execute(batchRequest) as! NSBatchUpdateResult
           let objects = objectIDs.result as! [NSManagedObjectID]

            objects.forEach({ objID in
                let managedObject = context.object(with: objID)
                context.refresh(managedObject, mergeChanges: false)
            })
        } catch {
        }
    }
}
