import SwiftUI
import CoreData

struct Menu: View {
    @Environment(\.managedObjectContext) private var viewContext

    var onLogout: () -> Void = {}

    @State private var searchText = ""
    @State private var selectedCategory = ""
    @State private var navigateToProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationHeader(
                    showBackButton: false,
                    avatarAction: { navigateToProfile = true }
                )

                heroSection

                VStack(alignment: .leading, spacing: 12) {
                    Text("ORDER FOR DELIVERY!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top, 16)

                    categoryFilters

                    Divider()
                }
                .padding(.horizontal)

                FetchedObjects(
                    predicate: buildPredicate(),
                    sortDescriptors: buildSortDescriptors()
                ) { (dishes: [Dish]) in
                    List(dishes) { dish in
                        NavigationLink(destination: DishDetails(dish: dish)) {
                            DishRow(dish: dish)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                UserProfile(onLogout: onLogout)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await getMenuData()
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            Color(red: 0.29, green: 0.37, blue: 0.35)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Little Lemon")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.0))
                        Text("Chicago")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                            .font(.callout)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search menu", text: $searchText)
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(["Starters", "Mains", "Desserts", "Drinks"], id: \.self) { category in
                    Button {
                        selectedCategory = selectedCategory == category ? "" : category
                    } label: {
                        Text(category)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                    ? Color(red: 0.29, green: 0.37, blue: 0.35)
                                    : Color(UIColor.systemGray5)
                            )
                            .foregroundColor(selectedCategory == category ? .white : .black)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Fetch helpers

    private func buildPredicate() -> NSPredicate {
        var predicates: [NSPredicate] = []

        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", searchText))
        }

        if !selectedCategory.isEmpty {
            predicates.append(NSPredicate(format: "category CONTAINS[cd] %@", selectedCategory))
        }

        return predicates.isEmpty
            ? NSPredicate(value: true)
            : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    private func buildSortDescriptors() -> [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \Dish.title, ascending: true)]
    }

    // MARK: - Data

    func getMenuData() async {
        let request = Dish.fetchRequest()
        let existing = (try? viewContext.fetch(request)) ?? []
        let needsRefresh = existing.isEmpty || existing.contains(where: { $0.category == nil || $0.category!.isEmpty })
        guard needsRefresh else { return }

        guard let url = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json") else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fullMenu = try JSONDecoder().decode(MenuList.self, from: data)
            await MainActor.run {
                PersistenceController.shared.clear()
                Dish.createDishesFrom(menuItems: fullMenu.menu, viewContext)
            }
        } catch {
            print("Error fetching menu data: \(error)")
        }
    }
}

// MARK: - Dish Row

struct DishRow: View {
    let dish: Dish

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(dish.title ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(dish.descriptionText ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Spacer()
                Text("$\(dish.price ?? "")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            Spacer()
            AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    Color(UIColor.systemGray5)
                case .failure:
                    Color(UIColor.systemGray5)
                @unknown default:
                    Color(UIColor.systemGray5)
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    Menu()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
