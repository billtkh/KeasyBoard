//
//  KeasyInputMethodManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 4/10/2021.
//

import Foundation
import CoreData

protocol KeasyInputMethodManagerDelegate: AnyObject {
    func keysInInputBuffer(keys: String, didMatch words: [KeasyWord])
}

class KeasyInputMethodManager: NSObject {
    static let shared = KeasyInputMethodManager()
    
    private override init() {
        super.init()
        
        preloadData()
    }
    
    weak var delegate: KeasyInputMethodManagerDelegate?
    
    private(set) var inputBuffer: String = ""
    
    private let queryQueue = DispatchQueue(label: "keasyBoard.inputMethodManager.queue")
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    var imeName = "Simplex"
    lazy var wordBaseURL = documentsDirectory.appendingPathComponent("\(imeName).sqlite")

    func preloadData() {
        let sourceSqliteURLs = [
            Bundle.main.url(forResource: imeName, withExtension: "sqlite"),
            Bundle.main.url(forResource: imeName, withExtension: "sqlite-wal"),
            Bundle.main.url(forResource: imeName, withExtension: "sqlite-shm")
        ]
        
        let destSqliteURLs = [
            wordBaseURL,
            documentsDirectory.appendingPathComponent("\(imeName).sqlite-wal"),
            documentsDirectory.appendingPathComponent("\(imeName).sqlite-shm"),
        ]
        
        for index in 0...sourceSqliteURLs.count - 1 {
            let dest = destSqliteURLs[index]
            do {
                if FileManager.default.fileExists(atPath: dest.path) {
                    print("File exists: \(dest.path)")
                    try FileManager.default.removeItem(at: dest)
//                    continue
                }
                try FileManager.default.copyItem(at: sourceSqliteURLs[index]!, to: destSqliteURLs[index])
            } catch {
                print("Could not preload data")
            }
        }
        
        print("Data pre-loaded")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: imeName)
        
        let description = NSPersistentStoreDescription(url: wordBaseURL)
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func inputKey(key: String) {
        inputBuffer += key
        queryWord(keys: inputBuffer)
    }
}

extension KeasyInputMethodManager {
    func queryWord(keys: String) {
        queryQueue.async { [weak self] in
            print("queryWord: \(keys)")
            guard let sSelf = self else { return }
            
            let context = sSelf.persistentContainer.viewContext
            
            let fetchRequest = Word.fetchRequest()
//            fetchRequest.fetchLimit = 10
            fetchRequest.predicate = NSPredicate(format: "keys = %@", keys)
            fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "index", ascending: true)]

            do {
                let result = try context.fetch(fetchRequest)
                let words = result.map { KeasyWord(word: $0) }
                sSelf.invokeInputBuffer(keys: keys, didMatch: words)
            } catch {
                print("Failed")
            }
        }
    }
    
    func invokeInputBuffer(keys: String, didMatch words: [KeasyWord]) {
        DispatchQueue.main.sync {
            delegate?.keysInInputBuffer(keys: keys, didMatch: words)
        }
    }
}
