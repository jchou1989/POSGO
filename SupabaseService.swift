import Foundation
import Supabase
import PostgREST

// MARK: - Data Models
struct SizeUpdate: Codable {
    let label: String
    let price: Double
}

struct ToppingUpdate: Codable {
    let label: String
    let price: Double
}

struct NewMenuItem: Codable {
    let name: String
    let price: Double
    let category_id: UUID
}

struct MenuItemUpdate: Codable {
    let name: String
    let price: Double
    let category_id: UUID
}

struct SizeInsert: Codable {
    let label: String
    let price: Double
}

struct ToppingInsert: Codable {
    let label: String
    let price: Double
}

// MARK: - Service Class
class SupabaseService {
    
    // MARK: - Error Handling
    enum ServiceError: Error {
        case invalidData
        case networkError
        case notFound
    }
    
    // MARK: - Order Operations
    static func submitOrder(order: Order) async throws {
        do {
            try await supabase
                .from("orders")
                .insert(order)
                .execute()
        } catch {
            print("❌ Order submission failed: \(error)")
            throw ServiceError.networkError
        }
    }
    
    // MARK: - Category Operations
    static func fetchCategories() async throws -> [MenuCategory] {
        do {
            let response: PostgrestResponse<[MenuCategory]> = try await supabase
                .from("menu_categories")
                .select()
                .execute()
            return response.value
        } catch {
            print("❌ Failed to fetch categories: \(error)")
            throw ServiceError.networkError
        }
    }
    
    static func addCategory(name: String) async throws {
        do {
            try await supabase
                .from("menu_categories")
                .insert(["name": name])
                .execute()
        } catch {
            print("❌ Failed to add category: \(error)")
            throw ServiceError.networkError
        }
    }

    static func updateCategory(id: UUID, newName: String) async throws {
        do {
            try await supabase
                .from("menu_categories")
                .update(["name": newName])
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to update category: \(error)")
            throw ServiceError.networkError
        }
    }

    static func deleteCategory(id: UUID) async throws {
        do {
            try await supabase
                .from("menu_categories")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to delete category: \(error)")
            throw ServiceError.networkError
        }
    }

    // MARK: - Menu Item Operations
    static func fetchMenuItems(for categoryId: UUID) async throws -> [MenuItem] {
        do {
            let response: PostgrestResponse<[MenuItem]> = try await supabase
                .from("menu_items")
                .select()
                .eq("category_id", value: categoryId)
                .execute()
            return response.value
        } catch {
            print("❌ Failed to fetch menu items: \(error)")
            throw ServiceError.networkError
        }
    }

    static func addMenuItem(name: String, price: Double, categoryId: UUID) async throws {
        do {
            let newItem = NewMenuItem(name: name, price: price, category_id: categoryId)
            try await supabase
                .from("menu_items")
                .insert(newItem)
                .execute()
        } catch {
            print("❌ Failed to add menu item: \(error)")
            throw ServiceError.networkError
        }
    }

    static func updateMenuItem(id: UUID, name: String, price: Double, categoryId: UUID) async throws {
        do {
            let updateData = MenuItemUpdate(name: name, price: price, category_id: categoryId)
            try await supabase
                .from("menu_items")
                .update(updateData)
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to update menu item: \(error)")
            throw ServiceError.networkError
        }
    }

    static func deleteMenuItem(id: UUID) async throws {
        do {
            try await supabase
                .from("menu_items")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to delete menu item: \(error)")
            throw ServiceError.networkError
        }
    }

    // MARK: - Modifier Operations
    static func fetchSizeOptions() async throws -> [SizeOption] {
        do {
            let response: PostgrestResponse<[SizeOption]> = try await supabase
                .from("sizes")
                .select()
                .execute()
            return response.value
        } catch {
            print("❌ Failed to fetch size options: \(error)")
            throw ServiceError.networkError
        }
    }

    static func fetchToppingOptions() async throws -> [ToppingOption] {
        do {
            let response: PostgrestResponse<[ToppingOption]> = try await supabase
                .from("toppings")
                .select()
                .execute()
            return response.value
        } catch {
            print("❌ Failed to fetch topping options: \(error)")
            throw ServiceError.networkError
        }
    }

    static func addSizeOption(label: String, price: Double) async throws {
        do {
            let newSize = SizeInsert(label: label, price: price)
            try await supabase
                .from("sizes")
                .insert(newSize)
                .execute()
        } catch {
            print("❌ Failed to add size option: \(error)")
            throw ServiceError.networkError
        }
    }

    static func addToppingOption(label: String, price: Double) async throws {
        do {
            let newTopping = ToppingInsert(label: label, price: price)
            try await supabase
                .from("toppings")
                .insert(newTopping)
                .execute()
        } catch {
            print("❌ Failed to add topping option: \(error)")
            throw ServiceError.networkError
        }
    }

    static func updateSizeOption(id: UUID, label: String, price: Double) async throws {
        do {
            let updateData = SizeUpdate(label: label, price: price)
            try await supabase
                .from("sizes")
                .update(updateData)
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to update size option: \(error)")
            throw ServiceError.networkError
        }
    }

    static func updateToppingOption(id: UUID, label: String, price: Double) async throws {
        do {
            let updateData = ToppingUpdate(label: label, price: price)
            try await supabase
                .from("toppings")
                .update(updateData)
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to update topping option: \(error)")
            throw ServiceError.networkError
        }
    }

    static func deleteSizeOption(id: UUID) async throws {
        do {
            try await supabase
                .from("sizes")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to delete size option: \(error)")
            throw ServiceError.networkError
        }
    }

    static func deleteToppingOption(id: UUID) async throws {
        do {
            try await supabase
                .from("toppings")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("❌ Failed to delete topping option: \(error)")
            throw ServiceError.networkError
        }
    }
}
