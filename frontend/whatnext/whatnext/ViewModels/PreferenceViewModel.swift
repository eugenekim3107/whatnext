import Foundation
import SwiftUI

class PreferenceViewModel: ObservableObject {
    @AppStorage("storedFDTags") private var storedFDTagsString: String = ""
    @AppStorage("storedACTags") private var storedACTagsString: String = ""
    
    @Published var ACtags: [(String, Bool)]
    @Published var FDtags: [(String, Bool)]
    private var allTags: [String]
    
    var storedFDTags: [String] {
        get {
            storedFDTagsString.isEmpty ? [] : storedFDTagsString.split(separator: ",").map(String.init).map { $0.trimmingCharacters(in: .whitespaces) }
        }
        set {
            storedFDTagsString = newValue.joined(separator: ",")
        }
    }
    
    var storedACTags: [String] {
        get {
            storedACTagsString.isEmpty ? [] : storedACTagsString.split(separator: ",").map(String.init).map { $0.trimmingCharacters(in: .whitespaces) }
        }
        set {
            storedACTagsString = newValue.joined(separator: ",")
        }
    }
    
    init(allTags: [String]) {
        // Temporarily initialize `tags` to satisfy property initialization requirements
        self.ACtags = []
        self.FDtags = []
        self.allTags = allTags
        
        // Properly initialize `tags` after all properties are initialized
        self.ACtags = allTags.map { tag in
            (tag, self.storedACTags.contains(tag))
        }
        self.FDtags = allTags.map { tag in
            (tag, self.storedFDTags.contains(tag))
        }
        
    }
    
    func updateACTagsForStoredTags() {
        self.ACtags = allTags.map { tag in
            (tag, storedACTags.contains(tag))
        }
        let concatenatedString = self.ACtags.filter { $0.1 }.map { $0.0 }.joined(separator: ",")
        storedACTagsString = concatenatedString
        let _  = print(storedACTagsString)
        
        
    }
    func updateFDTagsForStoredTags() {
        self.FDtags = allTags.map { tag in
            (tag, storedFDTags.contains(tag))
        }
        let concatenatedString = self.FDtags.filter { $0.1 }.map { $0.0 }.joined(separator: ",")
        storedFDTagsString = concatenatedString
        let _  = print(storedFDTagsString)
        let _ = print(allTags)
        
        
        
    }
    
    
    func addTagManually(_ tags: String) {
        // Append the new tag to the existing storedTagsString, separated by a comma
        storedFDTagsString = tags
    }
}

