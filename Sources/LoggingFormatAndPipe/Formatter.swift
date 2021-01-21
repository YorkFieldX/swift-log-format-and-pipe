//
//  Formatter.swift
//  LoggingFormatAndPipe
//
//  Created by Ian Grossberg on 7/22/19.
//

import Logging
import Foundation

/// Possible log format components
public enum LogComponent {
    /// Timestamp of log
    /// Specifying your timestamp format can be done by providing a DateFormatter through `Formatter.timestampFormatter`
    case timestamp

    /// Log level as text
    case levelText
    /// Log level as text starting with a capital letter
    case levelTextCapitalised
    /// Log level as emoji
    case levelEmoji
    /// Log level as emoji with colour circles
    case levelEmojiColour
    /// The actual message
    case message
    /// Log metadata
    case metadata
    /// The log's originating file
    case file
    /// The log's originating filename (without full path, without .ext at the end of the filename)
    case filename
    /// The log's originating filename (without full path)
    case filenameWithExtension
    /// The log's originating function
    case function
    /// The log's originating line number
    case line

    /// Literal text
    case text(String)
    /// A group of `LogComponents`, not using the specified `separator`
    case group([LogComponent])

    /// All basic log format component types
    public static var allNonmetaComponents: [LogComponent] {
        return [
            .timestamp,
            .levelText,
            .levelTextCapitalised,
            .levelEmoji,
            .levelEmojiColour,
            .message,
            .metadata,
            .file,
            .filename,
            .filenameWithExtension,
            .function,
            .line
        ]
    }
}

/// Log Formatter
public protocol Formatter {
    /// Timestamp formatter
    var timestampFormatter: DateFormatter { get }

    /// Formatter's chance to format the log
    /// - Parameter level: log level
    /// - Parameter message: actual message
    /// - Parameter prettyMetadata: optional metadata that has already been "prettified"
    /// - Parameter file: log's originating file
    /// - Parameter function: log's originating function
    /// - Parameter line: log's originating line
    /// - Returns: Result of formatting the log
    func processLog(level: Logger.Level,
                    message: Logger.Message,
                    prettyMetadata: String?,
                    file: String, function: String, line: UInt) -> String

}

extension Formatter {
    /// Common usage component formatter
    /// - Parameter _: component to format
    /// - Parameter now: log's Date
    /// - Parameter level: log level
    /// - Parameter message: actual message
    /// - Parameter prettyMetadata: optional metadata that has already been "prettified"
    /// - Parameter file: log's originating file
    /// - Parameter function: log's originating function
    /// - Parameter line: log's originating line
    /// - Returns: Result of formatting the component
    public func processComponent(_ component: LogComponent, now: Date, level: Logger.Level,
                                  message: Logger.Message,
                                  prettyMetadata: String?,
                                  file: String,
                                  function: String,
                                  line: UInt,
                                  alignLogLevels: Bool,
                                  filenameAlignment: Int,
                                  lineNumberAlignment: Int) -> String {
        switch component {
        case .timestamp:
            return self.timestampFormatter.string(from: now)
        case .levelText:
            if alignLogLevels {
                return align(text: level.rawValue, numOfChars: 8)
            }
            return level.rawValue
        case .levelTextCapitalised:
            if alignLogLevels {
                return align(text: level.rawValue.capitalized, numOfChars: 8)
            }
            return level.rawValue.capitalized
        case .levelEmoji:
            switch level {
            case .trace:
                return "🔎"
            case .debug:
                return "🐞"
            case .info:
                return "ℹ️"
            case .notice:
                return "🔔"
            case .warning:
                return "⚠️"
            case .error:
                return "❗️"
            case .critical:
                return "🔥"
            }
        case .levelEmojiColour:
            switch level {
            case .trace:
                return "⚪️"
            case .debug:
                return "🟤"
            case .info:
                return "🔵"
            case .notice:
                return "🟢"
            case .warning:
                return "🟡"
            case .error:
                return "🟠"
            case .critical:
                return "🔴"
            }
        case .message:
            return "\(message)"
        case .metadata:
            return "\(prettyMetadata.map { "\($0)" } ?? "")"
        case .file:
            return "\(file)"
        case .filename:
            return align(text: getPrettyFileName(filename: file, includeExtension: false), numOfChars: filenameAlignment)
        case .filenameWithExtension:
            return align(text: getPrettyFileName(filename: file, includeExtension: true), numOfChars: filenameAlignment)
        case .function:
            return "\(function)"
        case .line:
            return align(text: line.description, numOfChars: lineNumberAlignment)
        case .text(let string):
            return string
        case .group(let logComponents):
            return logComponents.map({ (component) -> String in
                self.processComponent(component, now: now, level: level, message: message, prettyMetadata: prettyMetadata, file: file, function: function, line: line, alignLogLevels: alignLogLevels, filenameAlignment: filenameAlignment, lineNumberAlignment: lineNumberAlignment)
            }).joined()
        }
    }
    
    private func getPrettyFileName(filename: String, includeExtension: Bool) -> String {
        let file = (filename.split(separator: "/").last ?? "Unknown").description
        if includeExtension {
            return file
        } else {
            var components = file.split(separator: ".")
            components.removeLast()
            return components.joined()
        }
    }
    
    private func align(text: String, numOfChars: Int) -> String {
        if numOfChars == -1 {
            return text
        }
        var modifiedText = text;
        while modifiedText.count < numOfChars {
            modifiedText += " "
        }
        return modifiedText
    }
}
