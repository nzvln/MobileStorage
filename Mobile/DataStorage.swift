//
//  DataStorage.swift
//  Mobile
//
//  Created by Nadia on 08.09.2022.
//

import CoreData
import UIKit

enum Errors: Error {
    case duplicate
    case empty
}

protocol MobileStorage {
    func getAll()
    func findByImei(_ imei: String) -> Mobile?
    func save(_ mobile: Mobile) throws -> Mobile
    func delete(_ product: Mobile) throws
    func exists(_ product: Mobile) -> Bool
}

class DataStorage: MobileStorage {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext  
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Mobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createDevice(model: String, imei: String, completion: @escaping (Mobile) -> Void) throws {
        let newDevice = Mobile(context: context)
        
        newDevice.model = model
        newDevice.imei = imei
        do {
            if exists(newDevice) {
                throw Errors.duplicate
            } else {
                completion(try save(newDevice))
            }
        } catch let error {
            throw error
        }
    }
    
    func getAll()  {
        do {
            mobiles = try! context.fetch(Mobile.fetchRequest())
        }
        catch {
            print("error")
        }
    }
    
    func findByImei(_ imei: String) -> Mobile? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mobile")
        request.predicate = NSPredicate(format: "imei = %@", imei)
        let devices = try? context.fetch(request) as? [Mobile]
        if devices?.count == 0 {
            return nil
        } else {
            let exactDevice = devices?.first
            saveContext()
            return exactDevice
        }
    }
    
    func updateItem(item: Mobile, newModel: String) {
        item.model = newModel
        do {
            try context.save()
        }
        catch {
        }
    }
    
    func save(_ mobile: Mobile) throws -> Mobile {
        if exists(mobile) {
            throw Errors.duplicate
        } else {
            context.insert(mobile)
            saveContext()
            return mobile
        }
    }
    
    func delete(_ product: Mobile) throws {
        context.delete(product)
        do {
            try context.save()
        }
        catch let error {
            throw error
        }
    }
    
    func deleteDeviceWith(model: String, imei: String, completion: @escaping () -> Void) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mobile")
        request.predicate = NSPredicate(format: "imei = %@ && model = %@", imei, model)
        let result = try? context.fetch(request) as? [NSManagedObject]
        
        result?.forEach { context.delete($0) }
        completion()
    }
    
    func exists(_ product: Mobile) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Mobile")
        request.predicate = NSPredicate(format: "imei = %@", product.imei ?? "")
        do {
            if try context.fetch(request).count > 1 {
                context.delete(product)
                saveContext()
                return true
            }
        } catch {
            return false
        }
        return false
    }
}

