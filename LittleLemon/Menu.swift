import SwiftUI
import CoreData

struct Menu: View {
    @Environment(\.managedObjectContext) private var viewContext

    var onLogout: () -> Void = {}
    var onProfileTap: () -> Void = {}

    @State private var searchText = ""
    @State private var selectedCategory = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationHeader(showBackButton: false, avatarAction: onProfileTap)

                heroSection

                VStack(alignment: .leading, spacing: 12) {
                    Text("ORDER FOR DELIVERY!")
                        .font(.karla(20, weight: .black))
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
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await getMenuData()
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            Color.llGreen
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Little Lemon")
                            .font(.markaziText(64, weight: .medium))
                            .foregroundColor(.llYellow)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Chicago")
                            .font(.markaziText(40))
                            .foregroundColor(.white)
                        Text("We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.")
                            .font(.karla(18, weight: .medium))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .layoutPriority(1)

                    Image("restaurantFood")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search menu", text: $searchText)
                        .font(.karla(16))
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
                            .font(.karla(16, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                    ? Color.llGreen
                                    : Color.llCloud
                            )
                            .foregroundColor(selectedCategory == category ? .white : .llDark)
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
                    .font(.karla(18, weight: .bold))
                    .foregroundColor(.llDark)
                Text(dish.descriptionText ?? "")
                    .font(.karla(16))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Spacer()
                Text("$\(dish.price ?? "")")
                    .font(.karla(16, weight: .medium))
                    .foregroundColor(.llDark)
            }
            Spacer()
            AsyncImage(url: URL(string: dish.image ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    Color.llCloud
                case .failure:
                    Color.llCloud
                @unknown default:
                    Color.llCloud
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
