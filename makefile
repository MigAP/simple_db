all: sdb

sdb: main.scm db-utils.scm cli.scm plot.scm db-example.scm 
	csc -o sdb main.scm 

tests: 
	csi -s unit-tests.scm

clear:
	rm sdb 
