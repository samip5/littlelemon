import Foundation
import CoreData

func fetchAndConvertMenuItems() async throws {
    let url = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let fullMenu = try JSONDecoder().decode(MenuList.self, from: data)
    let menuItems = fullMenu.menu
    
    // Get the managed object context from the persistence controller
    let context = PersistenceController.shared.container.viewContext
    
    // Create dishes from menu items
    Dish.createDishesFrom(menuItems: menuItems, context)
}
