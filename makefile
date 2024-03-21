all: sdb

sdb: main.scm db-utils.scm cli.scm plot.scm db-example.scm 
	csc -o sdb main.scm 

test: 
	csi -s unit-tests.scm

clear:
	rm sdb 
