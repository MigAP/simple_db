all: sdb

sdb: main.scm db-utils.scm cli.scm plot.scm db-example.scm 
	csc -o sdb main.scm 

test: 
	csi -s ./tests/run.scm

clear:
	rm sdb 
