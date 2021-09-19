//
//  DraftDataViewModel.swift
//  geosy
//
//  Created by 宮下知也 on 2021/08/23.
//

import Foundation
import CoreData
import SwiftUI

struct DraftDataItem: Identifiable {
    var title: String
    var body_text: String
    var image: UIImage?
    var latitude: Double
    var longitude: Double
    var tag: String
    var id: UUID = UUID()
    var placeName: String
    var objectID: NSManagedObjectID?
    var isHorizontal = true
    
    func reverseGeocode(completion: @escaping ((String?) -> ())){
        if latitude == 0{ completion(nil); return }
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { completion(nil); return }
            guard let administrativeArea = placemark.administrativeArea, let locality = placemark.locality, let thoroughfare = placemark.thoroughfare, let subThoroughfare = placemark.subThoroughfare else { completion(nil); return }
            let placeName = "@" + administrativeArea + locality + thoroughfare + subThoroughfare
            completion(placeName)
        }
    }
    
    func isEmpty() -> Bool{
        return self.title.isEmpty && self.body_text.isEmpty && self.tag.isEmpty && self.placeName.isEmpty && (self.latitude == 0) && (self.longitude == 0) && self.image == nil
    }
    
    func isPostable() -> Bool{
        return !(self.title.isEmpty && self.body_text.isEmpty && self.image == nil)
    }
    
    func isPostableVerticale() -> Bool{
        if body_text.isEmpty {
            return true
        }
        let processedDescription = descriptionProcess(rawDescription: body_text)
        let maxLength = processedDescription.map({$0.count}).max()!
        return processedDescription.count <= 5 && maxLength <= 100
    }
}
extension DraftDataItem {
    init() {
        title = ""
        body_text = ""
        tag = ""
        placeName = ""
        latitude = 0
        longitude = 0
    }
}

enum CoreDataStoreError: Error {
    case failureFetch
}


extension DraftData {
    func convert() -> DraftDataItem? {
        var returnImage: UIImage?
        if image != nil{
            returnImage = UIImage(data: image!)
        }
        
        return DraftDataItem(title: title ?? "",
                            body_text: body_text ?? "",
                            image: returnImage,
                            latitude: latitude,
                            longitude: longitude,
                            tag: tag ?? "",
                            id: id!,
                            placeName: placeName ?? "",
                            objectID: objectID,
                            isHorizontal: isHorizontal)
    }
}


final class DraftDataStore {
    typealias Entity = DraftData
    static var containerName: String = "DraftDataModel"
    static var entityName: String = "DraftData"

    func insert(item: DraftDataItem) throws {
        if item.isEmpty() { return }
        let newItem = NSEntityDescription.insertNewObject(forEntityName: DraftDataStore.entityName, into: persistentContainer.viewContext) as? Entity
        newItem?.body_text = item.body_text
        newItem?.latitude = item.latitude
        newItem?.longitude = item.longitude
        newItem?.title = item.title
        newItem?.tag = item.tag
        newItem?.image = item.image?.pngData()
        newItem?.id = item.id
        newItem?.placeName = item.placeName
        newItem?.isHorizontal = item.isHorizontal
        try saveContext()
    }

    func fetchAll() throws -> [DraftDataItem] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DraftDataStore.entityName)
        do {
            guard let result = try persistentContainer.viewContext.fetch(fetchRequest) as? [Entity] else {
                throw CoreDataStoreError.failureFetch
            }
            let draftData = result.compactMap { $0.convert() }
            return draftData
        } catch let error {
            throw error
        }
    }


    func delete(id: NSManagedObjectID) throws {
        persistentContainer.viewContext.delete(persistentContainer.viewContext.object(with: id))
        try saveContext()
    }

    // MARK: - private
    // https://stackoverflow.com/questions/41684256/accessing-core-data-from-both-container-app-and-extension
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: DraftDataStore.containerName)
//        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.personal-factory.Draft")!.appendingPathComponent("\(DraftDataStore.containerName).sqlite"))]
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                throw nserror
            }
        }
    }
}
