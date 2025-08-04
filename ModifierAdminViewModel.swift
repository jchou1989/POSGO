import Foundation

class ModifierAdminViewModel: ObservableObject {
    @Published var sizes: [SizeOption] = []
    @Published var toppings: [ToppingOption] = []
    @Published var newSizeLabel = ""
    @Published var newSizePrice = ""
    @Published var newToppingLabel = ""
    @Published var newToppingPrice = ""
    @Published var editingSize: SizeOption?
    @Published var editingTopping: ToppingOption?
    @Published var errorMessage: String = ""
    
    func loadModifiers() async {
        do {
            async let sizesTask = SupabaseService.fetchSizeOptions()
            async let toppingsTask = SupabaseService.fetchToppingOptions()
            sizes = try await sizesTask
            toppings = try await toppingsTask
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addSize() async throws {
        guard let price = Double(newSizePrice) else {
            throw NSError(domain: "Invalid price", code: 0)
        }
        try await SupabaseService.addSizeOption(label: newSizeLabel, price: price)
        newSizeLabel = ""
        newSizePrice = ""
        await loadModifiers()
    }
    
    func addTopping() async throws {
        guard let price = Double(newToppingPrice) else {
            throw NSError(domain: "Invalid price", code: 0)
        }
        try await SupabaseService.addToppingOption(label: newToppingLabel, price: price)
        newToppingLabel = ""
        newToppingPrice = ""
        await loadModifiers()
    }
    
    func updateSize(id: UUID, label: String, price: Double) async throws {
        try await SupabaseService.updateSizeOption(id: id, label: label, price: price)
        await loadModifiers()
    }
    
    func updateTopping(id: UUID, label: String, price: Double) async throws {
        try await SupabaseService.updateToppingOption(id: id, label: label, price: price)
        await loadModifiers()
    }
    
    func deleteSize(id: UUID) async throws {
        try await SupabaseService.deleteSizeOption(id: id)
        await loadModifiers()
    }
    
    func deleteTopping(id: UUID) async throws {
        try await SupabaseService.deleteToppingOption(id: id)
        await loadModifiers()
    }
}
