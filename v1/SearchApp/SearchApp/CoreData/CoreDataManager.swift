//
//  CoreDataManager.swift
//  SearchApp
//
//  Created by LeeJaehoon on 2023/12/04.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    static let shard = CoreDataManager()

    private init() {}

    // MARK: - Creat
    func saveRecord(word: String) {
        if let allRecords = readRecord() {
            let contains = allRecords.filter { $0.word == word }
            contains.forEach { deleteObject(object: $0) }
        }

        let object = SearchRecord(context: context)
        object.word = word

        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Read
    func readRecord() -> [SearchRecord]? {
        let fetchRequest = SearchRecord.fetchRequest()

        do {
            let result = try self.context.fetch(fetchRequest)

            return result.reversed()
        } catch {
            return nil
        }
    }

    // MARK: - Delete All
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchRecord")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.context.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Delete Object
    func deleteObject(object: SearchRecord) {
        self.context.delete(object)

        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

}
