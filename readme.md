# pb - clipboard inspection and manipulation tool

This is a Swift port of (parts of) [this project](https://github.com/rolandcrosby/pasteboard). The macOS clipboard ("pasteboard" internally, hence the name) can contain multiple data types at once, and the app you're pasting data into usually doesn't let you choose which one you want. With this tool, you can:

* see which data types are on the clipboard (`pb types`)
* filter the clipboard to data conforming to a specific type (`pb filter <type identifier>`)

For convenience, shorthand options for filtering to image data and plain text are provided as `pb image` and `pb text`, respectively. Data types are represented using Apple's [uniform type indicator](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_intro/understand_utis_intro.html) syntax.
