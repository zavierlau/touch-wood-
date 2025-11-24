import SwiftUI
import PhotosUI

struct CustomRitualSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    
    private let icons = ["star.fill", "heart.fill", "moon.fill", "sun.max.fill", "leaf.fill", "flame.fill", "bolt.fill", "snowflake"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ritual Details") {
                    TextField("Ritual Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .blue)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Custom Image") {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label(selectedImage == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage = uiImage
                            }
                        }
                    }
                }
            }
            .navigationTitle("Custom Ritual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCustomRitual()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCustomRitual() {
        let ritual = Ritual(context: viewContext)
        ritual.id = UUID()
        ritual.name = name
        ritual.ritualDescription = description
        ritual.icon = selectedIcon
        ritual.isCustom = true
        ritual.isFavorite = false
        ritual.createdAt = Date()
        
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            ritual.customImageData = imageData
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving custom ritual: \(error)")
        }
    }
}

struct AddRitualButton: View {
    @State private var showingCustomRitualSheet = false
    
    var body: some View {
        Button(action: { showingCustomRitualSheet = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .sheet(isPresented: $showingCustomRitualSheet) {
            CustomRitualSheet()
        }
    }
}
