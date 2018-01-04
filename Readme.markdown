# HSTracker+

HSTracker+ is an enhanced fork of the original [Hearthstone](http://www.playhearthstone.com/) deck tracker for macOS 10.10+.

[![Build Status](https://travis-ci.org/ifeherva/HSTracker.svg?branch=master)](https://travis-ci.org/ifeherva/HSTracker)

## Features
### Enhanced Deck Tracker
![Deck Tracker](https://github.com/ifeherva/HSTracker/blob/master/hstracker.jpg)


Is Blizzard okay with this ?
[Yes](https://twitter.com/bdbrode/status/511151446038179840)

Is it against the TOS ?
[No](https://twitter.com/CM_Zeriyah/status/589171381381672960)

## Versions
[Complete changelog is here](versions.markdown)

## Contribution
Feel free to fork and pull-request, as well as filling [new issues](https://github.com/ifeherva/HSTracker/issues)

In order to compile, you have to

- Clone the code.  Make a fork on github!

        git clone https://github.com/ifeherva/HSTracker.git

- Get / update swift dependencies using [Carthage](https://github.com/Carthage/Carthage/blob/master/README.md#installing-carthage)

        carthage update --platform osx

- Install [SwiftLint](https://github.com/realm/SwiftLint/blob/master/README.md#installation), example using Homebrew:

        brew install swiftlint

- Open the project in XCode and build
  - If you run into code signing errors, go to the "Build Settings" and change the signing enitity and certificate to your profile. HSTracker _must_ be code signed in order to function properly. 

## Donations
Donations are always appreciated

[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=36UMDJV9NDB7Y)

## License

HSTracker is released under the [MIT license](LICENSE).
