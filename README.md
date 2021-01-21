# LoggingFormatAndPipe Emoji & Pretty FileName Mod
I made this little mod to allow for better logging on Swift Vapor Backend. This would not have been possible without the original project (https://github.com/Adorkable/swift-log-format-and-pipe)

List of changes/added components:
level --> levelText : Log level as text
level --> levelTextCapitalised : Log level as text starting with a capital letter
level --> levelEmoji : Log level as emoji
level --> levelEmojiColour : Log level as emoji (colour circles)
file --> filename : The log's originating filename (without full path, without .ext at the end of the filename)
file --> filenameWithExtension : The log's originating filename (without full path)

Using the changes above, you can get your logs looking like this
```
2021-01-22T01:48:30+1100 | 🔵 Info | main.swift:22 | Testing Info
2021-01-22T01:48:30+1100 | 🟢 Notice | main.swift:23 | Testing Notice
2021-01-22T01:48:30+1100 | 🟡 Warning | main.swift:24 | Testing Error
2021-01-22T01:48:30+1100 | 🟠 Error | main.swift:25 | Testing Error
2021-01-22T01:48:30+1100 | 🔴 Critical | main.swift:26 | Testing Critical
```

by using this configuration

```swift
LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter(
            [
                .timestamp,
                .group([LogComponent.levelEmojiColour, LogComponent.text(" "), LogComponent.levelTextCapitalised]),
                .group([LogComponent.filenameWithExtension, LogComponent.text(":"), LogComponent.line]),
                .message
            ],
            separator: " | "
        ),
        pipe: LoggerTextOutputStreamPipe.standardOutput
    )
```
or like this

```
2021-01-22T01:49:55+1100 | ℹ️ Info | main.swift:22 | Testing Info
2021-01-22T01:49:55+1100 | 🔔 Notice | main.swift:23 | Testing Notice
2021-01-22T01:49:55+1100 | ⚠️ Warning | main.swift:24 | Testing Error
2021-01-22T01:49:55+1100 | ❗️ Error | main.swift:25 | Testing Error
2021-01-22T01:49:55+1100 | 🔥 Critical | main.swift:26 | Testing Critical
```

using this configuration

```swift
LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter(
            [
                .timestamp,
                .group([LogComponent.levelEmoji, LogComponent.text(" "), LogComponent.levelTextCapitalised]),
                .group([LogComponent.filenameWithExtension, LogComponent.text(":"), LogComponent.line]),
                .message
            ],
            separator: " | "
        ),
        pipe: LoggerTextOutputStreamPipe.standardOutput
    )
```

To use this in your Vapor 4 application, you need to add this repository in your package.swift, and edit main.swift file

```swift
.package(url: "https://github.com/YorkFieldX/swift-log-format-and-pipe", from: "0.1.2"),
```


```swift
LoggingSystem.bootstrap({ str in
    return LoggingFormatAndPipe.Handler(
        formatter: BasicFormatter(
            //Your configuration goes here
        ),
        pipe: LoggerTextOutputStreamPipe.standardOutput
    )
})
```

Don't forget
```swift
import LoggingFormatAndPipe
```

For any more information or customisation options please refer to the original readme below.

Have fun :)

# LoggingFormatAndPipe
**LoggingFormatAndPipe** provides a [Swift Logging API](https://github.com/apple/swift-log) Handler which allows you to customized both your log messages' formats as well as their destinations.

If you don't like the default log format change it to one you would like. If you want one destination to be formatted differently than your other destination you can with ease. Or send the same format to multiple destinations!

<p align="center">
    <a href="#installation">Installation</a> | <a href="#getting-started">Getting Started</a> | <a href="http://adorkable.github.io/swift-log-format-and-pipe/">Documentation</a>
</p>

## Installation

### SwiftPM

To use the **LoggingFormatAndPipe** library in your project add the following in your `Package.swift`:

```swift
.package(url: "https://github.com/adorkable/swift-log-format-and-pipe.git", .from("0.1.2")),
```


## Getting Started

`LoggingFormatAndPipe.Handler` expects both a `Formatter` and a `Pipe`

```swift
let logger = Logger(label: "example") { _ in 
    return LoggingFormatAndPipe.Handler(
        formatter: ...,
        pipe: ...
    )
}
```

*Example:*

```swift
let logger = Logger(label: "example") { _ in 
	return LoggingFormatAndPipe.Handler(
		formatter: BasicFormatter.adorkable,
		pipe: LoggerTextOutputStreamPipe.standardOutput
	)
}
```

## Formatting
There are a number of ways of customizing the format but are generally composed of a combination of `LogComponents`:

* `.timestamp` - Timestamp of log
* `.level` - Log level
* `.message` - The actual message
* `.metadata` - Log metadata
* `.file` - The log's originating file
* `.line` - The log's originating line number in the file
* `.function` - The log's originating function
* `.text(String)` - Static text
* `.group([LogComponents])` - Formatters may separate specified `LogComponents` in various ways as per their format, `.group` tells the Formatter to combine the `LogComponents` without using its separation

### BasicFormatter
`BasicFormatter` allows you to specify a sequence of `LogComponents` and a separator string and automatically processes them into a single line for each new log message. 

It includes already setup static instances:

* `.apple` - [apple/swift-log](https://github.com/apple/swift-log) format

  `{timestamp} {level}: {message}`

  *Example:*
  
  `2019-07-30T13:49:07-0400 error: Test error message`
* `.adorkable` - Adorkable's standard format 😘 

  `{timestamp} ▶ {level} ▶ {file}:{line} ▶ {function} ▶ {message} ▶ {metadata}`

  *Example:*
  
  `2019-07-30T13:49:07-0400 ▶ error ▶ /asdf/swift-log-format-and-pipe/Tests/LoggingFormatAndPipeTests/FormatterTests.swift:25 ▶ testFormatter(_:) ▶ Test error message`

#### Customizing a BasicFormatter
If none of these work you can customize your own instance!

Suppose you want a special short log format with a timestamp, the level, the file it originated in, and the message itself:

```swift
let myFormat = BasicFormatter(
	[
		.timestamp, 
		.level,
		.file,
		.message
	]
)
```

To change the separator from a single space specify the separator parameter:

```swift
let myFormat = BasicFormatter(
	...,
	separator: "|"
)
```

Note that `BasicFormatter` will not add an empty string and separator for a `nil` metadata.  

To change the timestamp from the default:

```swift
let myDateFormat = DateFormatter()
myDateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
let myFormat = BasicFormatter(
	...,
	timestampFormatter: myDateFormat
)
```

### Implementing Formatter
You can also create your own `Formatter` conforming object by implementing:

* `var timestampFormatter: DateFormatter { get }`
* `func processLog(level: Logger.Level,
                    message: Logger.Message,
                    prettyMetadata: String?,
                    file: String, function: String, line: UInt) -> String`
                    
More formatters to come!

## Piping
Pipes specify where your formatted log lines end up going to. Included already are:

* `LoggerTextOutputStreamPipe.standardOutput` - log lines to `stdout`
* `LoggerTextOutputStreamPipe.standardError` - log lines to `stderr`

More pipes to come!

### Implementing Pipe 
You can also create your own `Pipe` conforming object by implementing:

* `func handle(_ formattedLogLine: String)`

Easy!

Now you've got your use-case formatted log lines traveling this way and then, what a charm 🖤

## API Documentation
For more insight into the library API documentation is found in the repo [here](http://adorkable.github.io/swift-log-format-and-pipe/)
