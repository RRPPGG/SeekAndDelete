# SeekAndDelete
SeekAndDelete was written as a simple to use tool for cleaning your computer.

This is why it is a PowerShell script, not a C++/C#/Python program.

There is no need to build or install anything, just download the file and use.

## Usage
Place SeekAndDelete.ps1 file into a directory where you want to look for duplicated files.

Be carefull, more files means longer execution time.

## Advanced usage
Running from command line allows you to use several additional options:

-rootdir "path"         - run analyzys in given directory instead of script directory

-filetype ".extension"  - analyze only files with given extension

-ignoreName             - ignore names

-ignoreSize             - ignore sizes

-ignoreDate             - ignore modification dates

-directorymode          - look for directories only, enables ignoreName and ignoreDate, ignores filetype

Notice that you can't ignore name, size and date at the same time.

## Contact
Rafał Gajewski
rpga@op.pl
