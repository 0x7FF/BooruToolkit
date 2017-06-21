# e621TagOrganizer
#### modular e621 library organizer written in Bash

This is a bash script that I wrote to organize my local e621 library. I needed something that was extension-agnostic, lightweight and easy to modify, and thus TagOrganizer was born.

Out of the box this app supports Windows 10 (using Bash on Windows) and Linux, but you can easily modify it to support anything else, for example MacOS or third-party tagging software.

If that's not enough for you, this script is incredibly easy to extend upon.

[Forum thread on e621](https://e621.net/forum/show/233498)

## Features
* Can be used with e926.net to avoid filters.
* Easily add your own functions that can do literally anything.
* Everything is broken into functions, code is easy to read and understand.
* Soft-link tagging is zero-maintenance and doesn't require extra software.
* Doesn't touch the original files, no backups required.

## Installation

`$ git clone https://github.com/0x7FF/e621TagOrganizer.git`

`$ bash e621TagOrganizer/TagOrganizer.sh`

## Usage

Run the script and follow instructions. To skip the menu and just update use argument --update

### Custom methods
Function "proc" is iteratively run for every file and every tag in that file. As soon as it's called, you have access to source path, destination path, full name, MD5 and a tag, all available as standard bash variables.

Please consult MODIFY for instructions on creating your own methods.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Added some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request.

## Known bugs

- [ ] Recursive mode is not supported on Windows yet.

## License

TagOrganizer uses MIT license, for more information please consult LICENSE.
