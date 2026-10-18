#!/usr/bin/env swift
// Copies each sample's code out of the Gallery's pages into Sources/Samples/GeneratedSamples.swift,
// so the ⓘ on a sample shows the code that draws it. Run from the repository root (the Gallery's
// build runs it before compiling):
//
//     swift Gallery/Scripts/ExtractSamples.swift
//
// A sample is a call to one of `wrappers` with a string literal title and a trailing closure; its
// code is the closure's body, dedented. Filed by the page's file name and the title.
import Foundation

let wrappers = ["Sample", "KnobSample", "AmpPanel"]
let root = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? FileManager.default.currentDirectoryPath)
let pages = root.appendingPathComponent("Gallery/Sources/Pages")
let output = root.appendingPathComponent("Gallery/Sources/Samples/GeneratedSamples.swift")

/// The index just past the string literal opening at `start` (a `"`), and its value.
func literal(_ text: [Character], at start: Int) -> (value: String, end: Int)? {
    var index = start + 1
    var value = ""
    while index < text.count {
        switch text[index] {
        case "\\":
            guard index + 1 < text.count else { return nil }
            value.append(text[index + 1] == "n" ? "\n" : text[index + 1])
            index += 2
        case "\"":
            return (value, index + 1)
        case "\n":
            return nil
        default:
            value.append(text[index])
            index += 1
        }
    }
    return nil
}

/// The index of the bracket closing the one at `start`, skipping strings and comments.
func closing(_ text: [Character], from start: Int, open: Character, close: Character) -> Int? {
    var depth = 0
    var index = start
    while index < text.count {
        let character = text[index]
        if character == "/", index + 1 < text.count, text[index + 1] == "/" {
            index = text[index...].firstIndex(of: "\n") ?? text.count
            continue
        }
        if character == "\"" {
            if index + 2 < text.count, text[index + 1] == "\"", text[index + 2] == "\"" {
                let rest = String(text[(index + 3)...])
                guard let range = rest.range(of: "\"\"\"") else { return nil }
                index += 3 + rest.distance(from: rest.startIndex, to: range.upperBound)
                continue
            }
            guard let string = literal(text, at: index) else { return nil }
            index = string.end
            continue
        }
        if character == open { depth += 1 }
        if character == close {
            depth -= 1
            if depth == 0 { return index }
        }
        index += 1
    }
    return nil
}

/// `body` without its first and last blank lines, every line moved left by the least indentation.
func dedented(_ body: String) -> String {
    var lines = body.components(separatedBy: "\n")
    while lines.first?.trimmingCharacters(in: .whitespaces).isEmpty == true { lines.removeFirst() }
    while lines.last?.trimmingCharacters(in: .whitespaces).isEmpty == true { lines.removeLast() }
    let indent = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        .map { $0.prefix { $0 == " " }.count }
        .min() ?? 0
    return lines.map { $0.count >= indent ? String($0.dropFirst(indent)) : $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
}

/// Every sample in a page's source, by title.
func samples(in source: String) -> [(title: String, code: String)] {
    let text = Array(source)
    var found: [(String, String)] = []
    var index = 0
    while index < text.count {
        guard let name = wrappers.first(where: { matches($0 + "(\"", in: text, at: index) }) else {
            index += 1
            continue
        }
        let previous = index > 0 ? text[index - 1] : " "
        guard !(previous.isLetter || previous.isNumber || previous == "_" || previous == "."),
              let title = literal(text, at: index + name.count + 1),
              let callEnd = closing(text, from: index + name.count, open: "(", close: ")")
        else {
            index += 1
            continue
        }
        var brace = callEnd + 1
        while brace < text.count, text[brace] == " " { brace += 1 }
        if brace < text.count, text[brace] == "{", let end = closing(text, from: brace, open: "{", close: "}") {
            found.append((title.value, dedented(String(text[(brace + 1) ..< end]))))
            index = brace + 1
        } else {
            index = callEnd + 1
        }
    }
    return found
}

func matches(_ word: String, in text: [Character], at index: Int) -> Bool {
    index + word.count <= text.count && String(text[index ..< index + word.count]) == word
}

func swiftLiteral(_ code: String) -> String {
    "#\"\"\"\n" + code.components(separatedBy: "\n").map { $0.isEmpty ? "" : "        " + $0 }.joined(separator: "\n") + "\n        \"\"\"#"
}

let files = (try? FileManager.default.contentsOfDirectory(at: pages, includingPropertiesForKeys: nil)) ?? []
var entries: [(key: String, code: String)] = []
for file in files.filter({ $0.pathExtension == "swift" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
    guard let source = try? String(contentsOf: file, encoding: .utf8) else { continue }
    for sample in samples(in: source) {
        let key = "\(file.lastPathComponent)#\(sample.title)"
        if entries.contains(where: { $0.key == key }) {
            FileHandle.standardError.write(Data("error: two samples are titled \(key)\n".utf8))
            exit(1)
        }
        entries.append((key, sample.code))
    }
}

let generated = """
// Generated by Gallery/Scripts/ExtractSamples.swift from the pages' source. Don't edit: change the
// page and build (or run the script).

/// Each sample's code, filed by its page's file name and its title.
enum GeneratedSamples {
    static let code: [String: String] = [
\(entries.map { "        \(swiftLiteralKey($0.key)): \(swiftLiteral($0.code))," }.joined(separator: "\n"))
    ]
}

"""

func swiftLiteralKey(_ key: String) -> String {
    "#\"" + key + "\"#"
}

let existing = try? String(contentsOf: output, encoding: .utf8)
if existing != generated {
    try generated.write(to: output, atomically: true, encoding: .utf8)
}
print("\(entries.count) samples")
