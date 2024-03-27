//
//  CoreDataStack.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 20/2/2567 BE.
//

import CoreData

@objc(Activity)
public class Activity: NSManagedObject {
    @NSManaged public var time: Double
    @NSManaged public var calories: Double
    @NSManaged public var exerciseType: String
    @NSManaged public var calBurnedType: String
    @NSManaged public var activityCount: Int64
    @NSManaged public var dateAndTime: Date
}

extension Activity: Identifiable {
    public var id: NSManagedObjectID { self.objectID }
}


class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        
        let activityEntity = NSEntityDescription()
        activityEntity.name = "Activity"
        activityEntity.managedObjectClassName = NSStringFromClass(Activity.self)
        
        let timeAttribute = NSAttributeDescription()
        timeAttribute.name = "time"
        timeAttribute.attributeType = .doubleAttributeType
        timeAttribute.isOptional = false
        
        let caloriesAttribute = NSAttributeDescription()
        caloriesAttribute.name = "calories"
        caloriesAttribute.attributeType = .doubleAttributeType
        caloriesAttribute.isOptional = false
        
        let exerciseTypeAttribute = NSAttributeDescription()
        exerciseTypeAttribute.name = "exerciseType"
        exerciseTypeAttribute.attributeType = .stringAttributeType
        exerciseTypeAttribute.isOptional = false
        
        let calBurnedTypeAttribute = NSAttributeDescription()
        calBurnedTypeAttribute.name = "calBurnedType"
        calBurnedTypeAttribute.attributeType = .stringAttributeType
        calBurnedTypeAttribute.isOptional = false
        
        let activityCountAttribute = NSAttributeDescription()
        activityCountAttribute.name = "activityCount"
        activityCountAttribute.attributeType = .integer64AttributeType
        activityCountAttribute.isOptional = false
        
        let dateAndTimeAttribute = NSAttributeDescription()
        dateAndTimeAttribute.name = "dateAndTime"
        dateAndTimeAttribute.attributeType = .dateAttributeType
        dateAndTimeAttribute.isOptional = false
        
        activityEntity.properties = [timeAttribute, caloriesAttribute, exerciseTypeAttribute, calBurnedTypeAttribute, activityCountAttribute, dateAndTimeAttribute]
        model.entities = [activityEntity]
        
        return model
    }()

    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("fitjourney.sqlite")
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            fatalError("Error adding persistent store: \(error)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "Activity", managedObjectModel: self.managedObjectModel)
          container.loadPersistentStores { (storeDescription, error) in
              if let error = error as NSError? {
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          }
          return container
      }()
      
      var viewContext: NSManagedObjectContext {
          return persistentContainer.viewContext
      }
}

extension CoreDataStack {
    func resetAllCoreData() {
        let context = managedObjectContext
        let persistentStoreCoordinator = context.persistentStoreCoordinator
        
        guard let entities = persistentStoreCoordinator?.managedObjectModel.entities else { return }
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
            } catch let error as NSError {
                print("Error resetting \(entity.name!): \(error), \(error.userInfo)")
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error saving after reset: \(error), \(error.userInfo)")
        }
    }
}
