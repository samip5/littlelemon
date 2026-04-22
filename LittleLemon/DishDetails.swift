import SwiftUI
import CoreData

struct DishDetails: View {
    let dish: Dish
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(dish.title ?? "Unknown Dish")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("$\(dish.price ?? "0.00")")
                        .font(.title2)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(dish.descriptionText ?? "No description available")
                            .font(.body)
                            .lineSpacing(4)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(dish.title ?? "Dish Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        let context = PersistenceController.shared.container.viewContext
        let dish = Dish(context: context)
        dish.title = "Greek Salad"
        dish.price = "12.99"
        dish.descriptionText = "The famous greek salad of crispy lettuce, peppers, olives, our Chicago style feta cheese, garnished with crunchy garlic and rosemary croutons."
        dish.image = "https://github.com/Meta-Mobile-Developer-PC/Working-With-Data-API/blob/main/images/greekSalad.jpg?raw=true"
        
        return DishDetails(dish: dish)
    }
}
