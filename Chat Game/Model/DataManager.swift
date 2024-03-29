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
        UIImageArrayTransformer.register()

        self.persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                preconditionFailure("Error loading persistent store.")
            }
            
            self.games = (try? self.persistentContainer.viewContext.fetch(NSFetchRequest<Game>(entityName: "Game"))) ?? []
        }
    }
    
    func initialize() {
        
    }
    
    var viewContext: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }
    
    func createNewGame(_ title: String) -> Game {
        let game = Game(context: self.persistentContainer.viewContext)
        game.title = title
        game.creationDate = Date()
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
        var character: Character! = self.character(with: "Narrator", game: level.game!)
        if character == nil {
            character = self.createCharacter(with: "Narrator", game: level.game!)
        }
        
        level.game!.addToCharacters(character)
        
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
    
    func addImageModule(to level: Level, image: UIImage) -> ImageModule {
        let imageModule = ImageModule(context: level.managedObjectContext!)
        imageModule.image = image
        level.addToModules(imageModule)
        do {
            try level.managedObjectContext?.save()
        }
        catch {
            preconditionFailure("Failed to add image module.")
        }
        return imageModule
    }
    
    func character(with name: String, game: Game) -> Character? {
        (game.characters?.array as? [Character])?.first {
            $0.name == name
        }
    }
    
    func createCharacter(with name: String, game: Game) -> Character {
        let character = Character(context: game.managedObjectContext!)
        character.name = name
        game.addToCharacters(character)
        do {
            try game.managedObjectContext!.save()
        }
        catch {
            preconditionFailure("Failed to add text module.")
        }
        return character
    }
    
    func setBackgroundImage(_ data: Data, for level: Level) {
        level.backgroundImage = data
        do {
            try level.managedObjectContext?.save()
        }
        catch {
            preconditionFailure("Failed to set background image")
        }
    }
}
