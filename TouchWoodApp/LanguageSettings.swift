import SwiftUI

struct LanguageSettings: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    
    let languages = [
        ("en", "English", "英语"),
        ("zh-Hans", "简体中文", "中文"),
        ("zh-Hant", "繁體中文", "台灣中文"),
        ("zh-HK", "繁體中文", "香港中文")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("language", comment: "Language settings title"))
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(languages, id: \.0) { language in
                    LanguageRow(
                        code: language.0,
                        nativeName: language.1,
                        localName: language.2,
                        isSelected: selectedLanguage == language.0
                    ) {
                        selectedLanguage = language.0
                        changeLanguage(to: language.0)
                    }
                    
                    if language.0 != languages.last?.0 {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private func changeLanguage(to languageCode: String) {
        // Set the app language preference
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Restart the app to apply language change
        exit(0)
    }
}

struct LanguageRow: View {
    let code: String
    let nativeName: String
    let localName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(nativeName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(localName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LanguageSettings()
}
