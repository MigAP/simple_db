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
[Chicken Scheme](http://call-cc.org/) is required to compile the
program.

### Compilation with `chicken-install`
This is the preferred way because it will install automatically all
the required dependencies. To compile the program without
installing-it run:

```
chicken-install -n 
```


### Compilation with a `makefile`
First install the eggs `list-utils` and `gnuplot-pipe`, then to
compile the program using a makefile simply run:

```
make
```

## Using the interpreter
It is also possible to run the program using the `csi` interpreter:

```
csi -s main.scm -h
```

The above command prints the help of the program.

## Tests

### Using `chicken-install`
To run the unit tests: 

```
chicken-install -n -test
```

### Using `make`
To run the tests simply run the following command:

```
make test
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
