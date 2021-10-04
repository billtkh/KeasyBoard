//
//  KeasyInputMethodManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 4/10/2021.
//

import Foundation
import CoreData

class KeasyInputMethodManager: NSObject {
    static let shared = KeasyFontManager()
    
    func preloadData() {
        let sourceSqliteURLs = [
            Bundle.main.url(forResource: "DataModel", withExtension: "sqlite"),
            Bundle.main.url(forResource: "DataModel", withExtension: "sqlite-wal"),
            Bundle.main.url(forResource: "DataModel", withExtension: "sqlite-shm")
        ]
        
        let destSqliteURLs = [
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/DataModel.sqlite"),
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/DataModel.sqlite-wal"),
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/DataModel.sqlite-shm")]

        for index in 0...sourceSqliteURLs.count-1 {
            do {
                try FileManager.default.copyItem(at: sourceSqliteURLs[index]!, to: destSqliteURLs[index])
            } catch {
                print("Could not preload data")
            }
        }
    }
}
