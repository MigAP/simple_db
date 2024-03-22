## Introduction
This is just a toy project for me to practice Scheme, and put into
practice some of the things I learned reading the [Little
Schemer](https://mitpress.mit.edu/9780262560993/the-little-schemer/)
and
[SICP](https://mitpress.mit.edu/9780262510875/structure-and-interpretation-of-computer-programs/).


It is a simple CLI database for storing URLs. Each entry in the
database has a title, url, a list of tags and a description.

An example database is given in the repository with the file
[db-example](./db-example.scm). Some other code examples are
available in [code-examples](./code-examples.scm).

## Compilation

[Chicken Scheme](http://call-cc.org/) is required to run the
program. To compile the program simply run:

```
make
```

It is also possible to run the program using the `csi` interpreter:

```
csi -s main.scm -h
```

The above command prints the help of the program.

## Tests
To run the tests simply run the following command:

```
make tests
```
## Examples

### Get Help
Prints help information on how to use the program:

```
./sdb -h
```

### Get all the tags from the database
Prints all the titles of the database:

```
./sdb -l db-example.scm -g tags
```

### Search inside the database
Searches for all the entries that have at least the tag prompted by
the user. For example, enter "search" to have all the entries that
have at least the tag search.

```
./sdb -l db-example.scm -s tags-or
```

### Plot tags statistics

```
./sdb -l db-example.scm -p
```

### Export the database to tsv

```
./sdb -l db-example.scm -e tsv
```
