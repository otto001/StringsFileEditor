//
//  Document.swift
//  StringsFileEditor
//
//  Created by Matteo Ludwig on 06.01.23.
//

import Foundation


struct Document {

    private(set) var languages = Set<LanguageCode>()
    private(set) var entries = [Key: Translations]()
    private(set) var orderedKeys = [Key]()
    private(set) var baseUrl: URL?
    private var fileUrls = [LanguageCode: URL]()
    
    init() {
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
        self.baseUrl = url
        
        var entries = [Key: Translations]()
        
        for fileUrl in stringFiles {
            guard let language = LanguageCode(fromUrl: fileUrl),
                  let contents = try? String(contentsOf: fileUrl) else {
                continue
            }
            self.fileUrls[language] = fileUrl
            self.languages.insert(language)
            
            let stringLines = contents.split(separator: "\n")
            
            for stringLine in stringLines {
                guard stringLine.starts(with: "\""), let line = Line(fromStringsLine: String(stringLine)) else { continue }
                
                entries[line.key, default: Translations()][language] = line.translations
            }
        }
        
        self.entries = entries
        self.updateKeys()
    }
    
    mutating func updateKeys() {
        orderedKeys = entries.keys.sorted { a, b in
            return a < b
        }
    }
    
    mutating func setTranslation(key: String, language: LanguageCode, translation: String) {
        guard languages.contains(language) else { return }
        
        let needToUpdateKeys = entries[key] == nil
        
        entries[key, default: Translations()][language] = translation
        
        if needToUpdateKeys {
            updateKeys()
        }
    }
    
    mutating func setTranslations(key: String, translations: Translations) {
        let needToUpdateKeys = entries[key] == nil
        
        for language in languages {
            let translation = translations[language] ?? key
            entries[key, default: Translations()][language] = translation
        }
        
        if needToUpdateKeys {
            updateKeys()
        }
    }
    
    mutating func removeKey(key: String) {
        entries.removeValue(forKey: key)
        updateKeys()
    }
    
    func save() {
        for language in languages {
            save(language: language)
        }
    }
    
    private func save(language: LanguageCode) {
        guard let url = self.fileUrls[language] else { return }
        
        var fileContent = orderedKeys.compactMap { (key: Key) -> String? in
            guard let translation = entries[key]?[language] else { return nil }
            return Line(key: key, translations: translation).formatted
        }.joined(separator: "\n")
        
        fileContent.insert(contentsOf: Document.fileHeader, at: fileContent.startIndex)
        
        try? fileContent.data(using: .utf8)?.write(to: url)
    }
}

extension Document {
    
    struct LanguageCode: Identifiable, Hashable, Equatable, Comparable {
        static func < (lhs: Document.LanguageCode, rhs: Document.LanguageCode) -> Bool {
            return lhs.string < rhs.string
        }
        
        var id: String { string }
        let string: String
        
        init(string: String) {
            self.string = string
        }
        
        init?(fromUrl url: URL) {
            guard let match = url.absoluteString.firstMatch(of: /\/(\w+)\.lproj/) else { return nil }
            self.string = String(match.1)
        }
    }
    
    typealias Key = String
    typealias Translations = [LanguageCode: String]
    
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

extension Document {
    static let fileHeader: String = """
//
// Created with StringsFileEditor (https://github.com/otto001/StringsFileEditor)
//


"""
}
