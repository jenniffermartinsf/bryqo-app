import SwiftUI

// MARK: - Highlight Token

struct HighlightToken {
    enum Kind {
        case keyword, string, number, comment, plain

        var color: Color {
            switch self {
            case .keyword:  return Color(hex: 0xCBA6F7)
            case .string:   return Color(hex: 0xA6E3A1)
            case .number:   return Color(hex: 0xFAB387)
            case .comment:  return Color(hex: 0x6C7086)
            case .plain:    return Color(hex: 0xCDD6F4)
            }
        }
    }

    let text: String
    let kind: Kind
}

// MARK: - Syntax Highlighter

struct CodeHighlighter {
    private let keywords: Set<String>

    init(language: CodeLanguage) {
        self.keywords = language.keywords
    }

    func tokens(for code: String) -> [HighlightToken] {
        var result: [HighlightToken] = []
        var index = code.startIndex

        while index < code.endIndex {
            let ch = code[index]
            let nextIndex = code.index(after: index)

            // Single-line comment: # (Python) or // (JS/Swift)
            let isHashComment = ch == "#"
            let isSlashComment = ch == "/" && nextIndex < code.endIndex && code[nextIndex] == "/"
            if isHashComment || isSlashComment {
                let start = index
                while index < code.endIndex && code[index] != "\n" {
                    index = code.index(after: index)
                }
                result.append(HighlightToken(text: String(code[start..<index]), kind: .comment))
                continue
            }

            // String literal: " or '
            if ch == "\"" || ch == "'" {
                let quote = ch
                let start = index
                index = code.index(after: index)
                while index < code.endIndex && code[index] != quote && code[index] != "\n" {
                    if code[index] == "\\" && code.index(after: index) < code.endIndex {
                        index = code.index(after: index)
                    }
                    index = code.index(after: index)
                }
                if index < code.endIndex { index = code.index(after: index) }
                result.append(HighlightToken(text: String(code[start..<index]), kind: .string))
                continue
            }

            // Number
            if ch.isNumber {
                let start = index
                while index < code.endIndex && (code[index].isNumber || code[index] == ".") {
                    index = code.index(after: index)
                }
                result.append(HighlightToken(text: String(code[start..<index]), kind: .number))
                continue
            }

            // Identifier or keyword
            if ch.isLetter || ch == "_" {
                let start = index
                while index < code.endIndex && (code[index].isLetter || code[index].isNumber || code[index] == "_") {
                    index = code.index(after: index)
                }
                let word = String(code[start..<index])
                result.append(HighlightToken(text: word, kind: keywords.contains(word) ? .keyword : .plain))
                continue
            }

            // Any other character (operators, punctuation, whitespace, newlines)
            result.append(HighlightToken(text: String(ch), kind: .plain))
            index = code.index(after: index)
        }

        return result
    }
}

// MARK: - CodeLanguage Keywords

extension CodeLanguage {
    var keywords: Set<String> {
        switch self {
        case .python:
            return ["def", "return", "if", "else", "elif", "for", "while", "in", "not",
                    "and", "or", "True", "False", "None", "import", "from", "class",
                    "print", "len", "range", "lambda", "with", "as", "try", "except",
                    "pass", "break", "continue", "yield", "global", "del", "raise", "type"]
        case .swift:
            return ["func", "return", "if", "else", "for", "while", "let", "var", "true",
                    "false", "nil", "class", "struct", "enum", "import", "print", "guard",
                    "in", "switch", "case", "default", "break", "continue", "throw", "throws",
                    "try", "catch", "async", "await", "init", "self", "super", "override", "final"]
        case .javascript:
            return ["function", "return", "if", "else", "for", "while", "const", "let",
                    "var", "true", "false", "null", "undefined", "console", "class",
                    "new", "this", "typeof", "import", "export", "default", "async",
                    "await", "switch", "case", "break", "continue", "try", "catch"]
        case .generic:
            return []
        }
    }
}

// MARK: - CodeSnippetView

struct CodeSnippetView: View {
    let snippet: CodeSnippet

    private static let codeBG     = Color(hex: 0x1E1E2E)
    private static let headerBG   = Color(hex: 0x181825)
    private static let borderColor = Color(hex: 0x313244)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().background(Self.borderColor)
            codeBody
        }
        .background(Self.codeBG)
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                .stroke(Self.borderColor, lineWidth: 1)
        }
    }

    private var header: some View {
        HStack {
            Text(snippet.language.rawValue)
                .bryqoFont(12, weight: .semibold, design: .monospaced)
                .foregroundStyle(Color(hex: 0x6C7086))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Self.borderColor)
                .clipShape(Capsule())
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Self.headerBG)
    }

    private var codeBody: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            highlightedText
                .bryqoFont(14, design: .monospaced)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }
    }

    private var highlightedText: Text {
        var combined = AttributedString()
        for token in CodeHighlighter(language: snippet.language).tokens(for: snippet.code) {
            var part = AttributedString(token.text)
            part.foregroundColor = UIColor(token.kind.color)
            combined += part
        }
        return Text(combined)
    }
}
