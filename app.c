#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include <stdarg.h>
#include <errno.h>

#define QUERY_SIZE 256
#define BUFFER_SIZE 80

int main()
{
	MYSQL *konekcija;

	konekcija = mysql_init(NULL);

	if(mysql_real_connect(konekcija, "localhost", "root", "root", "autobuska_stanica", 0, NULL, 0) == NULL)
		exit(EXIT_FAILURE);
	
	mysql_close(konekcija);

	exit(EXIT_SUCCESS);	
}

