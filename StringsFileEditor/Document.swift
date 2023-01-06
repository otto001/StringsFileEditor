//
//  Document.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import Foundation


struct Document {

    var languages = [String]()
    private(set) var entries: [Key: Translations]
    private(set) var keys: [Key]
    private var fileURLs = [String: URL]()
    
    init(entries: [Key: Translations] = [:]) {
        self.entries = entries
        self.keys = []
        self.updateKeys()
    }
    
    init(fromDirectory url: URL) {
        var stringFiles = [URL]()

        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! && fileURL.pathExtension == "strings" {
                        stringFiles.append(fileURL)
                    }
                } catch {
                    print(error, fileURL)
                }
            }
        }
        
        var dict = [String: [Line]]()
        
        let regex = /\/(\w+)\.lproj/
        
        for fileURL in stringFiles {
            guard let contents = try? String(contentsOf: fileURL) else {
                continue
            }

            
            let filePath = fileURL.absoluteString
            guard let match = filePath.firstMatch(of: regex) else { continue }
            let langCode = String(match.1)
            
            var lines = [Line]()
            
            let stringLines = contents.split(separator: "\n")
            
            for stringLine in stringLines {
                guard stringLine.starts(with: "\""), let line = Line(fromStringsLine: String(stringLine)) else { continue }
                
                lines.append(line)
            }
            
            dict[langCode] = lines
            
            self.fileURLs[langCode] = fileURL
            self.languages.append(langCode)
        }
        
        var entries = [Key: Translations]()
        for (countryCode, lines) in dict {
            for line in lines {
                // This line is not readable and i don't care
                entries[line.key, default: Translations()][countryCode] = line.translations
            }
        }
        
        self.entries = entries
        self.keys = []
        self.updateKeys()
    }
    
    mutating func updateKeys() {
        keys = entries.keys.sorted { a, b in
            return a < b
        }
    }
    
    mutating func setTranslation(key: String, langCode: String, translation: String) {
        let countPrev = entries.count
        entries[key, default: Translations()][langCode] = translation
        if entries.count != countPrev {
            updateKeys()
        }
    }
    
    mutating func removeKey(key: String) {
        entries.removeValue(forKey: key)
        updateKeys()
    }
    
    func save() {
        for language in languages {
            save(langCode: language)
        }
    }
    
    private func save(langCode: String) {
        guard let url = self.fileURLs[langCode] else { return }
        var lines = [Line]()
        
        for key in keys {
            guard let Translations = self.entries[key]?[langCode] else { continue }
            lines.append(.init(key: key, translations: Translations))
        }
        
        let fileContent = lines.map(\.formatted).joined(separator: "\n")
        try? fileContent.data(using: .utf8)?.write(to: url)
    }
}

extension Document {
    typealias Key = String
    typealias Translations = [String: String]
    
    struct Line {
        let key: String
        let translations: String
        
        var formatted: String {
            return "\"\(key)\" = \"\(translations)\";\n"
        }
        
        init(key: String, translations: String) {
            self.key = key
            self.translations = translations
        }
        
        init?(fromStringsLine line: String) {
            let splitLine = line.split(separator: "=", maxSplits: 1)
            guard splitLine.count == 2 else { return nil }
            
            let trimCharacterSet = CharacterSet(charactersIn: " ;\"")
            
            self.key = splitLine[0].trimmingCharacters(in: trimCharacterSet)
            self.translations = splitLine[1].trimmingCharacters(in: trimCharacterSet)
        }
    }
}
