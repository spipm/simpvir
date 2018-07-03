### Self-replicating binary infecting Mach-O files

#### Description

This is a simple binary that searches for two binary files - *simp* and *sAmp* - and tries to infect them with itself ("virus").


#### Functionality

* Searches the two files in the current directory
* Checks if they are 'marked' with a signature
* If not, gets LC_MAIN offset
* Adds bytecode above other binary, changes offset
* Mark file
* Now the other binary is infected and will run the virus code first and then continue with the original code
* When virus code is run, it waits for a UDP packet on port 31337, and passes the content to execve if it contains a triggerword



#### Action

![Replicating binary](https://raw.githubusercontent.com/DutchGraa/simpvir/master/screenshot/simpInfection.png "It works")

#### Resources used

Virus basics

https://cranklin.wordpress.com/2016/12/26/how-to-create-a-virus-using-the-assembly-language/

NASM

http://cs.lmu.edu/~ray/notes/nasmtutorial/

Syscalls

https://opensource.apple.com/source/xnu/xnu-1504.3.12/bsd/kern/syscalls.master

Assembly optimization

https://modexp.wordpress.com/2016/04/03/x64-shellcodes-bsd/

Mach-o file format

https://lowlevelbits.org/parsing-mach-o-files/

https://github.com/aidansteele/osx-abi-macho-file-format-reference

