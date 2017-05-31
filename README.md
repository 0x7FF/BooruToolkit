# e621TagOrganizer
#### modular e621 library organizer written in Bash


This is a bash script that I wrote to organize my local e621 library. I needed something that was extension-agnostic, lightweight and easy to modify, and thus TagOrganizer was born.

Out of the box this app supports Windows 10 (using Bash on Windows) and Linux, but you can easily modify it to support anything else, for example MacOS or third-party tagging software.

Since this app is extensible, you can do tagging the way you want to. I've added a template as well as a short manual on how to implement your own modules.

## Features
* Can be used with e926.net to avoid firewalls
* Easy to modify and extend upon
* Soft-link tagging is zero-maintenance and zero-wasted-space
* Doesn't touch the original files, no backups required

## Installation

`$ git clone https://github.com/0x7FF/e621TagOrganizer.git`

`$ bash e621TagOrganizer/TagOrganizer.sh`

## Usage

### Linux:
* install curl, xmllint, diff, recode, md5sum and sed (you will be prompted to install them if any of these are missing)
* Run the script
* When asked, specify where your files are stored (keep in mind that this script is not recursive by default) and where to create folders with tagged images

### Bash on Windows:
* install curl, xmllint, diff, recode, md5sum and sed (you will be prompted to install them if any of these are missing)
* edit function `output_windows` to include your own folders instead of defaults (this will be fixed in the next release)
* When asked, specify where your files are stored (keep in mind that this script is not recursive by default) and where to create folders with tagged images

You'll probably have to input them manually, so keep in mind that all of your drives reside in /mnt/*driveletter*

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Added some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request.

## History

### TagOrganizer 2.0
Public release, added support for Linux distributions, configuration and more modular design.

### TagOrganizer 1.2
Deprecated, only worked with Bash on Windows and only used hard-coded values. Scary stuff.

## Credits

This program has been written in it's entirety by Ray Volkov (me). Certain features of this app have been made possible by applications like curl, xmllint, diff, recode, md5sum and sed, all of which belong to their original authors.

## License

TagOrganizer uses MIT license, for more information please consult LICENSE.
