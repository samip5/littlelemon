import SwiftUI
import CoreData

struct Menu: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Dish.title, ascending: true)])
    private var dishes: FetchedResults<Dish>
    
    @State private var hasLoadedData = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Little Lemon")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Chicago")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                List {
                    ForEach(dishes) { dish in
                        NavigationLink(destination: DishDetails(dish: dish)) {
                            HStack {
                                Text("\(dish.title ?? "") - $\(dish.price ?? "")")
                                Spacer()
                                AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                    case .failure:
                                        Image(systemName: "photo")
                                            .frame(width: 100, height: 100)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                        }
                    }
                }
            }
            .padding()
            .task {
                if !hasLoadedData {
                    await getMenuData()
                    hasLoadedData = true
                }
            }
        }
    }
    
    func getMenuData() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json") else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fullMenu = try JSONDecoder().decode(MenuList.self, from: data)
            
            await MainActor.run {
                for item in fullMenu.menu {
                    if !Dish.exists(title: item.title, viewContext) {
                        let dish = Dish(context: viewContext)
                        dish.title = item.title
                        dish.image = item.image
                        dish.price = item.price
                        dish.descriptionText = item.description
                    }
                }
                try? viewContext.save()
            }
        } catch {
            print("Error fetching menu data: \(error)")
        }
    }
}

#Preview {
    Menu()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
