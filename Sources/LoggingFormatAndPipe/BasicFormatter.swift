//
//  BasicFormatter.swift
//  LoggingFormatAndPipe
//
//  Created by Ian Grossberg on 7/26/19.
//

import Logging
import Foundation

/// Your basic, customizable log formatter
/// `BasicFormatter` does not need any setup and will automatically include all log components
/// It can also be given a linear sequence of log components and it will build formatted logs in that order
public struct BasicFormatter: Formatter {
    /// Log format sequential specification
    public let format: [LogComponent]
    /// Log component separator
    public let separator: String?
    /// Log timestamp component formatter
    public let timestampFormatter: DateFormatter
    /// Allows you to align log level text
    public let alignLogLevels: Bool
    /// Allows you to align shortened filenames. Set to a predicted maximum filename length. Set to -1 to disable
    public let filenameAlignment: Int
    /// Allows you to align code line numbers. Set to a predicted maximum number of digits in code line numbers (e.g. 4 for line numbers up to 9999). Set to -1 to disable
    public let lineNumberAlignment: Int

    /// Default timestamp component formatter
    static public var timestampFormatter: DateFormatter {
        let result = DateFormatter()
        result.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return result
    }

    /// Default init
    /// - Parameters:
    ///   - _: Log format specification(default: `LogComponent.allNonmetaComponents`)
    ///   - separator: Log component separator (default: " ")
    ///   - alignLogLevels: Aligns the log level text (default: true)
    ///   - filenameAlignment: Aligns the shortened filename text to a specified number of characters(default: 35 characters; -1 to disable)
    ///   - lineNumberAlignment: Aligns the code line numbers to a specified number of characters(default: 3 characters; -1 to disable)
    ///   - timestampFormatter: Log timestamp component formatter (default: `BasicFormatter.timestampFormatter`)
    public init(_ format: [LogComponent] = LogComponent.allNonmetaComponents,
                separator: String = " ",
                alignLogLevels: Bool = true,
                filenameAlignment: Int = 35,
                lineNumberAlignment: Int = 3,
                timestampFormatter: DateFormatter = BasicFormatter.timestampFormatter) {
        self.format = format
        self.separator = separator
        self.timestampFormatter = timestampFormatter
        self.alignLogLevels = alignLogLevels
        self.filenameAlignment = filenameAlignment
        self.lineNumberAlignment = lineNumberAlignment
    }

    /// Our main log formatting method
    /// - Parameters:
    ///   - level: log level
    ///   - message: actual message
    ///   - prettyMetadata: optional metadata that has already been "prettified"
    ///   - file: log's originating file
    ///   - function: log's originating function
    ///   - line: log's originating line
    /// - Returns: Result of formatting the log
    public func processLog(level: Logger.Level,
                           message: Logger.Message,
                           prettyMetadata: String?,
                           file: String, function: String, line: UInt) -> String {
        let now = Date()

        return self.format.map({ (component) -> String in
            return self.processComponent(component,
                                         now: now,
                                         level: level,
                                         message: message,
                                         prettyMetadata: prettyMetadata,
                                         file: file,
                                         function: function,
                                         line: line,
                                         alignLogLevels: self.alignLogLevels,
                                         filenameAlignment: self.filenameAlignment,
                                         lineNumberAlignment: self.lineNumberAlignment)
        }).filter({ (string) -> Bool in
            return string.count > 0
        }).joined(separator: self.separator ?? "")
    }

    /// [apple/swift-log](https://github.com/apple/swift-log)'s log format
    /// 
    /// `{timestamp} {level}: {message}`
    ///
    /// *Example:*
    ///
    /// `2019-07-30T13:49:07-0400 error: Test error message`
    public static let apple = BasicFormatter(
        [
            .timestamp,
            .group([
                .levelText,
                .text(":"),
            ]),
            .message
        ]
    )
    
    public static let vapor = BasicFormatter(
        [
            .timestamp,
            .group([LogComponent.levelEmojiColour, LogComponent.text(" "), LogComponent.levelTextCapitalised]),
            .group([LogComponent.filenameWithExtension, LogComponent.text("@L"), LogComponent.line]),
            .message
        ],
        separator: " | "
    )

    /// Adorkable's go-to log format 😘
    ///
    /// `{timestamp} ▶ {level} ▶ {file}:{line} ▶ {function} ▶ {message} ▶ {metadata}`
    ///
    /// *Example:*
    ///
    /// `2019-07-30T13:49:07-0400 ▶ error ▶ /asdf/swift-log-format-and-pipe/Tests/LoggingFormatAndPipeTests/FormatterTests.swift:25 ▶ testFormatter(_:) ▶ Test error message`
    public static let adorkable = BasicFormatter(
        [
            .timestamp,
            .levelText,
            .group([
                .file,
                .text(":"),
                .line
            ]),
            .function,
            .message,
            .metadata
        ],
        separator: " ▶ "
    )
}
