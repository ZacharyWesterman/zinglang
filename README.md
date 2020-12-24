# Testing ground for flex + bison grammar parsing.

The program calc expects the file to parse as argument; pass `-` to read
the standard input.

You may pass `-p` to activate the parser debug traces, and `-s` to activate
the scanner's.

---

## Current behavior
* The only data type allowed is real numbers. No strings, characters, pointers, etc.
* No conditional logic or jumping exists.
* The following operations are allowed in an expression (in ascending precedence):
	* `A + B` or `A - B`
	* `A * B` or `A / B` or `A \ B` (integer division) or `A % B` (remainder)
	* `- A` (negate)
	* `( A )`
* Anything within double quotes is text to print to stdout. Supported escape codes are `\"` and `\n`.
* Any expression preceded by an `@` symbol will be printed to stdout.
* By default, a newline is appended to every print. append a `;` to suppress this.
* Input a variable

Example input file:
```
"value in: ";
? value
value := (value + 3) * 4 / 3
"new value: ";
@ value
```
