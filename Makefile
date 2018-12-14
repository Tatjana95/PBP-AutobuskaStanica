CC	= gcc
CCLIBS	= -I/usr/include/mysql/ -lmysqlclient
CCFLAGS = -Wall -Wextra
PROGRAM	= app
OBJ	= app.o
	

%.o: %.c
	$(CC) -c -o $@ $< $(CCLIBS) $(CCFLAGS)


$(PROGRAM): $(OBJ)
	$(CC) -o $@ $^ $(CCLIBS) $(CCFLAGS)
	cat create.sql triggers.sql insert.sql | mysql -u "root" -p

.PHONY: clean

clean:
	rm -f src/*.swp *.swp *~ src/*~ *.o
