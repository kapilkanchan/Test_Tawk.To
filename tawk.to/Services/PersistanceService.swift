//
//  PersistanceService.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 29/09/21.
//

import Foundation
import CoreData

class PersistanceService {
    let modelName: String!
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    static let shared = PersistanceService(modelName: "PersistanceStoreModel")
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

//Core Data Operations Handlers
extension PersistanceService {
    // MARK: - Core Data Saving support
    func save() -> Bool {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                return false
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        return false
    }
    
    //fetch the next 30 users from database
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
    
    //fetch user profile from database with give username
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

    //checks whether the id's > givenId or use matching the given name are present in database
    func isExist<T:NSManagedObject>(_ type: T.Type, id: Int?, name: String?, for profile: Bool) -> Bool {
        let context = persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: type))
        fetchRequest.predicate = profile ? NSPredicate(format: "login == %@",name!) : NSPredicate(format: "id > \(id!)")
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0 ? true : false
        } catch {
            return false
        }
    }
    
    //Updates only note column for a given username
    func batchUpdateRequest(entityName: String, updateAttribute: String, updateValue: String, name: String) -> Bool {
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
            
            return true
        } catch {
            return false
        }
    }
}
