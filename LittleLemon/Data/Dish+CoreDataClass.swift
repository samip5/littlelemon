import Foundation
import CoreData

@objc(Dish)
public class Dish: NSManagedObject { }

extension Dish {
    static func exists(title: String, _ context: NSManagedObjectContext) -> Bool {
        let request = Dish.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    static func createDishesFrom(menuItems: [MenuItem],
                                 _ context: NSManagedObjectContext) {
        for item in menuItems {
            if !exists(title: item.title, context) {
                let dish = Dish(context: context)
                dish.title = item.title
                dish.image = item.image
                dish.price = item.price
                dish.descriptionText = item.description
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving dishes to CoreData: \(error)")
        }
    }
}
