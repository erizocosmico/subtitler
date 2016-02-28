# Subtitler
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%26%20OSX-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Cocoapod](http://img.shields.io/cocoapods/v/Subtitler.svg?style=flat)](http://cocoadocs.org/docsets/Subtitler/)

Subtitler uses the API of [OpenSubtitles.org](http://opensubtitles.org) to retrieve subtitles for your movies and tv shows. Just give a path to the file to Subtitler, everything else is handled by it.

**Note:** you will need your own user agent. More info about OpenSubtitles user agents [here](http://trac.opensubtitles.org/projects/opensubtitles/wiki/DevReadFirst).

## Example
Download subtitles in english for `/Users/foo/Desktop/MyMovie.mp4`.

```swift
import Subtitler

let s = Subtitler(lang:"en", userAgent:"OSTestUserAgent")
s.download("/Users/foo/Desktop/MyMovie.mp4") { result in
	switch result {
	case .Success(let subtitlesPath):
		// Do something with the subtitles
	case .Failure(let error):
		// Handle error
	}
}
```

#### Languages

For the languages of the subtitles, use the ISO639 code of the language.

Subtitles are downloaded to the same path where the original file is and the same name but with `.srt` extension. In this case, the result would be `/Users/foo/Desktop/MyMovie.srt`.

## Requirements 
* Mac OS X 10.10+ / iOS 8.0+
* Xcode 7
* libz

## Install with CocoaPods

Use this in your `Podfile`!

```ruby
use_frameworks!

target 'MyApp' do
	pod 'Subtitler', '0.2.0'
end
```

## License

Subtitler is released under the MIT license.
