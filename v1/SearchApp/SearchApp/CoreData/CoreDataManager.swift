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
    func saveRecord(word: String) throws {
        do {
            if let allRecords = try readRecord() {
                let contains = allRecords.filter { $0.word == word }
                contains.forEach { try? deleteObject(object: $0) }
            }

            let object = SearchRecord(context: context)
            object.word = word

            try context.save()
        } catch {
            throw APIError.coreDataError
        }
    }

    // MARK: - Read
    func readRecord() throws -> [SearchRecord]? {
        let fetchRequest = SearchRecord.fetchRequest()

        do {
            let result = try self.context.fetch(fetchRequest)

            return result.reversed()
        } catch {
            throw APIError.coreDataError
        }
    }

    // MARK: - Delete All
    func deleteAll() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchRecord")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.context.execute(deleteRequest)
        } catch {
            throw APIError.coreDataError
        }
    }

    // MARK: - Delete Object
    func deleteObject(object: SearchRecord) throws {
        self.context.delete(object)

        do {
            try self.context.save()
        } catch {
            throw APIError.coreDataError
        }
    }

}
