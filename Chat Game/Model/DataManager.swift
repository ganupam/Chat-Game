//
//  DataManager.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/27/23.
//

import UIKit
import CoreData

final class DataManager: NSObject {
    static let shared = DataManager()
    
    private let persistentContainer = NSPersistentContainer(name: "DataModel")

    private(set) var games = [Game]()
    
    private override init() {
        super.init()
        
        NSAttributedStringTransformer.register()

        self.persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                preconditionFailure("Error loading persistent store.")
            }
            
            self.games = (try? self.persistentContainer.viewContext.fetch(NSFetchRequest<Game>(entityName: "Game"))) ?? []
        }
    }
    
    func initialize() {
        
    }
    
    func createNewGame(_ title: String) -> Game {
        let game = Game(context: self.persistentContainer.viewContext)
        game.title = title
        let level = Level(context: self.persistentContainer.viewContext)
        game.addToLevels(level)
        do {
            try self.persistentContainer.viewContext.save()
        }
        catch {
            preconditionFailure("Failed to create new game")
        }
        return game
    }
    
    func addLevel(to game: Game) {
        let moc = game.managedObjectContext!
        game.addToLevels(Level(context: moc))
        do {
            try moc.save()
        }
        catch {
            preconditionFailure("Failed to add level")
        }
    }
    
    func addTextModule(to level: Level) -> TextModule {
        var character: Character! = self.character(with: "Narrator")
        if character == nil {
            character = Character(context: level.managedObjectContext!)
            character.name = "Narrator"
        }
        
        let textModule = TextModule(context: level.managedObjectContext!)
        textModule.character = character
        level.addToModules(textModule)
        do {
            try level.managedObjectContext?.save()
        }
        catch {
            preconditionFailure("Failed to add text module.")
        }
        return textModule
    }
    
    func character(with name: String) -> Character? {
        let fetchRequest = NSFetchRequest<Character>(entityName: Character.entity().name!)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        return (try? fetchRequest.execute())?.first
    }
}
