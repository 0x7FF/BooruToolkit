# e621TagOrganizer
#### modular e621 library organizer written in Bash


This is a bash script that I wrote to organize my local e621 library. I needed something that was extension-agnostic, lightweight and easy to modify, and thus TagOrganizer was born.

Out of the box this app supports Windows 10 (using Bash on Windows) and Linux, but you can easily modify it to support anything else, for example MacOS or third-party tagging software.

Since this app is extensible, you can do tagging the way you want to. I've added a template as well as a short manual on how to implement your own modules.

## Features
* Can be used with e926.net to avoid filters
* Easily add your own methods for tagging
* Everything is broken into functions, code is easy to read and understand.
* Soft-link tagging is zero-maintenance and doesn't require extra software
* Doesn't touch the original files, no backups required (though you should always back your things up, don't get the wrong idea!)

## Installation

`$ git clone https://github.com/0x7FF/e621TagOrganizer.git`

`$ bash e621TagOrganizer/TagOrganizer.sh`

## Usage

### Linux ln:
* install curl, xmllint, diff, recode, md5sum and sed (you will be prompted to install them if any are missing)
* Run the script
* When asked, specify where your files are stored and where to create folders with tagged images

### Bash on Windows (mklink):
* install curl, xmllint, diff, recode, md5sum and sed (you will be prompted to install them if any are missing)
* Run the script
* When asked, specify where your files are stored and where to create folders with tagged images

### TMSU
* install curl, xmllint, diff, recode, md5sum and sed (you will be prompted to install them if any are missing)
* run `tmsu init ~` if you haven't done so already
* Run the script
* When asked, specify where your files are stored.

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

- [ ] File deletion isn't handled yet, expect dead links in your tag folders if you delete an image.
- [ ] Recursive mode is not supported on Windows yet.

## History

### TagOrganizer 2.2
Recursive mode is now live! as well as some minor code enhancements.

### TagOrganizer 2.1
Added TMSU support and recursive mode.

### TagOrganizer 2.0
Public release, added support for Linux distributions, configuration and more modular design.

### TagOrganizer 1.2
Deprecated, only worked with Bash on Windows and only used hard-coded values. Scary stuff.

## Credits

This program has been written in it's entirety by me. Certain features of this app have been made possible by applications like curl, xmllint, diff, recode, md5sum and sed, all of which belong to their original authors.

## License

TagOrganizer uses MIT license, for more information please consult LICENSE.
