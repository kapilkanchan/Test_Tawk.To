//
//  PersistanceDataTests.swift
//  tawk.toTests
//
//  Created by Kapil Kanchan on 24/10/21.
//

import XCTest
@testable import tawk_to
import CoreData

class PersistanceDataTests: XCTestCase {
    
    
    private var sut: ProfileUserViewModel!
    var coreDataStack: TestCoreDataStack!
    static var context: NSManagedObjectContext!
    
//    static func context(managedContext: NSManagedObjectContext) {
////        return context
//        context = managedContext
//    }
    
    // MARK: - LifeCycle
    
    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack()
        sut = ProfileUserViewModel()
//        sut = UserService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        coreDataStack = nil
    }
    
//    func test_create_data() {
//
//    }

//    func test_create_data() {
////        PersistanceDataTests.context(managedContext: self.coreDataStack.storeContainer.viewContext)
//        PersistanceDataTests.context = self.coreDataStack.storeContainer.viewContext
//        //Given the name & status
//        let name = "test"
//
//        //When add New Data
//        try? PersistanceDataTests.context.save()
////        PersistanceDataTests.context.save(name: name, completion: { (result) in
////            XCTAssertEqual( result, true )
////        })
//
//        //Assert: return data item
//
//
//    }
    
//    func test_fetch_all_data() {
//
//        //Given a storage with two data
//
//        //When fetch
//        let results = PersistanceDataTests.context.fetchAllData()
//
//        //Assert return two data items
//        XCTAssertEqual(results?.count, 5)
//    }
//
//    func test_remove_data() {
//
//        //Given a item in persistent store
//        if let items = PersistanceDataTests.context.fetchAllData(){
//        let item = items[0]
//
//        let numberOfItems = items.count
//
//        //When remove a item
//            PersistanceDataTests.context.deleteParticularData(id: item.id) { (result) in
//                 XCTAssertEqual(numberOfItemsInPersistentStore(), numberOfItems-1)
//            }
//
//        //Assert number of item - 1
//
//        }
//
//    }
//
    func test_save() {

        //Give a data item
        let profile = Profile(context: self.coreDataStack.context)
        profile.id = Int64(2)
        profile.login = "abcxyz1"
        profile.name = "ABC XYZ 1"
        profile.avatarUrl = "http://someUrl"
        profile.following = Int64(9)
        profile.followers = Int64(10)
        profile.company = "Some Company"
        profile.blog = ""
        profile.notes = nil
        let result = self.coreDataStack.save()
        
        XCTAssert(result)
    }
    
    func test_update() {
        let result = self.coreDataStack.batchUpdateRequest(entityName: "Profile", updateAttribute: "notes", updateValue: "How are you!", name: "abcxyz1")
        
        XCTAssertEqual(result, true)
    }
        
    
    
    //MARK: mock in-memory persistant store
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
//        return managedObjectModel
//    }()
    
//    lazy var mockPersistantContainer: NSPersistentContainer = {
//
//        let container = NSPersistentContainer(name: "MVVM", managedObjectModel: self.managedObjectModel)
//        let description = NSPersistentStoreDescription()
//        description.type = NSInMemoryStoreType
//        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
//
//        container.persistentStoreDescriptions = [description]
//        container.loadPersistentStores { (description, error) in
//            // Check if the data store is in memory
//            precondition( description.type == NSInMemoryStoreType )
//
//            // Check if creating container wrong
//            if let error = error {
//                fatalError("Create an in-mem coordinator failed \(error)")
//            }
//        }
//        return container
//    }()
    
//    //MARK: Convinient function for notification
//    var saveNotificationCompleteHandler: ((Notification)->())?
//
//    func expectationForSaveNotification() -> XCTestExpectation {
//        let expect = expectation(description: "Context Saved")
//        waitForSavedNotification { (notification) in
//            expect.fulfill()
//        }
//        return expect
//    }
    
//    func waitForSavedNotification(completeHandler: @escaping ((Notification)->()) ) {
//        saveNotificationCompleteHandler = completeHandler
//    }
//
//    func contextSaved( notification: Notification ) {
//        print("\(notification)")
//        saveNotificationCompleteHandler?(notification)
//    }
}

//MARK: Creat some fakes
//extension PersistanceDataTests {
//
//    func initStubs() {
//        PersistanceDataTests.context.save(name: "text1")
//        PersistanceDataTests.context.save(name: "text2")
//        PersistanceDataTests.context.save(name: "text3")
//        PersistanceDataTests.context.save(name: "text4")
//        PersistanceDataTests.context.save(name: "text5")
//
//    }
//
//    func flushData() {
//
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "CoredataList")
//        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
//        for case let obj as NSManagedObject in objs {
//            mockPersistantContainer.viewContext.delete(obj)
//        }
//        try! mockPersistantContainer.viewContext.save()
//
//    }
//
//    func numberOfItemsInPersistentStore() -> Int {
//        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoredataList")
//        let results = try! mockPersistantContainer.viewContext.fetch(request)
//        return results.count
//    }
//
//
//}
