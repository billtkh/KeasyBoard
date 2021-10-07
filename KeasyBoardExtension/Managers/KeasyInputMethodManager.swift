//
//  KeasyInputMethodManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 4/10/2021.
//

import Foundation
import CoreData

enum KeasyInputMethod: String {
    case simplex = "Simplex"
    case cangjie = "Cangjie"
}

protocol KeasyInputMethodManagerDelegate: AnyObject {
    func keysInInputBuffer(keys: String, didMatch anyWords: [KeasyWord])
    func didEraseInputBuffer()
}

class KeasyInputMethodManager: NSObject {
    static let shared = KeasyInputMethodManager()
    
    private override init() {
        super.init()
        
        preloadData()
    }
    
    weak var delegate: KeasyInputMethodManagerDelegate?
    
    private(set) var currentInputMethod: KeasyInputMethod = .simplex
    private(set) var inputBuffer: String = ""
    
    private let queryQueue = DispatchQueue(label: "keasyBoard.inputMethodManager.queue")
    
    private var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    var ime = "IME"
    lazy var wordBaseURL = documentsDirectory.appendingPathComponent("\(currentInputMethod.rawValue).sqlite")

    func preloadData() {
        let sourceSqliteURLs = [
            Bundle.main.url(forResource: currentInputMethod.rawValue, withExtension: "sqlite"),
            Bundle.main.url(forResource: currentInputMethod.rawValue, withExtension: "sqlite-wal"),
            Bundle.main.url(forResource: currentInputMethod.rawValue, withExtension: "sqlite-shm")
        ]
        
        let destSqliteURLs = [
            wordBaseURL,
            documentsDirectory.appendingPathComponent("\(currentInputMethod.rawValue).sqlite-wal"),
            documentsDirectory.appendingPathComponent("\(currentInputMethod.rawValue).sqlite-shm"),
        ]
        
        for index in 0...sourceSqliteURLs.count - 1 {
            let dest = destSqliteURLs[index]
            do {
                if FileManager.default.fileExists(atPath: dest.path) {
                    print("File exists: \(dest.path)")
//                    try FileManager.default.removeItem(at: dest)
                    continue
                }
                try FileManager.default.copyItem(at: sourceSqliteURLs[index]!, to: destSqliteURLs[index])
            } catch {
                print("Could not preload data")
            }
        }
        
        print("Data pre-loaded")
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: ime)
        
        let description = NSPersistentStoreDescription(url: wordBaseURL)
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

extension KeasyInputMethodManager {
    func inputKey(key: String) {
        inputBuffer += key
        guard key != " " else { return }
        queryWord(keys: inputBuffer.trimmingCharacters(in: .whitespaces))
    }
    
    func eraseInputBuffer() {
        inputBuffer = ""
        invokeDidEraseInputBuffer()
    }
    
    func popInputBuffer() -> String {
        if inputBuffer.isEmpty {
            return ""
        } else {
            let last = String(inputBuffer.removeLast())
            if inputBuffer.isEmpty {
                invokeDidEraseInputBuffer()
            } else {
                queryWord(keys: inputBuffer.trimmingCharacters(in: .whitespaces))
            }
            return last
        }
    }
    
    func resetInputBuffer() {
        inputBuffer = ""
    }
    
    var isInputBufferEmpty: Bool {
        return inputBuffer.isEmpty
    }
    
    func queryWord(keys: String) {
        queryQueue.async { [weak self] in
            print("queryWord: \(keys)")
            guard let sSelf = self else { return }
            
            let context = sSelf.persistentContainer.viewContext
            
            let fetchRequest = Word.fetchRequest()
//            fetchRequest.fetchLimit = 10
            fetchRequest.predicate = NSPredicate(format: "keys = %@", keys.lowercased())
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
    
    func invokeInputBuffer(keys: String, didMatch anyWords: [KeasyWord]) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.keysInInputBuffer(keys: keys, didMatch: anyWords)
        }
    }
    
    func invokeDidEraseInputBuffer() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.delegate?.didEraseInputBuffer()
        }
    }
}
