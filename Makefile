DIR	= mysql-C
PROGS	= app
CFLAGS	= -g -Wall `mysql_config --cflags --libs`

.PHONY: all create insert beauty dist progs

progs: $(PROGS)

all: create insert $(PROGS)

create:
	mysql -u root -proot -D mysql <create.sql

insert:
	mysql -u root -proot -D mysql <insert.sql
	
beauty:
	-indent $(PROGS).c

clean:
	-rm -f *~ $(PROGS)
	
dist: beauty clean
	-tar -czv -C .. -f ../$(DIR).tar.gz $(DIR)
	
