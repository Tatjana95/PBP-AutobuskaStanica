#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mysql.h>
#include <stdarg.h>
#include <errno.h>

#define QUERY_SIZE 256
#define MAX_SIZE 45

int idStanice(char stanica[], char user[], char pas[]);

int main(int argc, char** argv)
{
	MYSQL *konekcija;
	MYSQL_RES *rezultat;
	MYSQL_ROW red;
	MYSQL_FIELD *polje;
	 
	FILE* f; //pomicni fajl za demonstriranje rada trigera
	
	char query[QUERY_SIZE];
	char dan[11];
	char pocetna_stanica[MAX_SIZE];
	char krajnja_stanica[MAX_SIZE];

	int poc_id, kraj_id;
	char info;
	
	int rezer_id;
	
	f = fopen("rad_trigera.txt", "a");
	
	konekcija = mysql_init(NULL);

	if(argc < 3)
		exit(EXIT_FAILURE);
	
	if(mysql_real_connect(konekcija, "localhost", argv[1], argv[2], "autobuska_stanica", 0, NULL, 0) == NULL)
		exit(EXIT_FAILURE);
	
	printf("\n");

	printf("Stanice: \n");
	
	//Spisak stanica u bazi
	sprintf(query, "select naziv, grad, broj_telefona from Autobuska_stanica");
	
	if(mysql_query(konekcija, query) != 0)
	{
		exit(EXIT_FAILURE);
	}
	rezultat = mysql_use_result(konekcija);
	
	polje = mysql_fetch_field(rezultat);
	
	printf("%s\t%s\t%s\n", polje[0].name, polje[1].name, polje[2].name);
	
	while((red = mysql_fetch_row(rezultat)) != 0)
		printf("%s\t%s\t%s\n", red[0], red[1], red[2]);
	
	printf("\n\n");
	
	mysql_free_result (rezultat);
	
	printf("Unesite dan kada zelite da putujete\n");
	scanf("%s", dan);
	printf("Unesite pocetnu stanicu\n");
	scanf("%s", pocetna_stanica);
	printf("Unesite krajnju stanicu\n");
	scanf("%s", krajnja_stanica);
	
	//Nalazi id pocetne i krajnje stanice
	poc_id = idStanice(pocetna_stanica, argv[1], argv[2]);
	kraj_id = idStanice(krajnja_stanica, argv[1], argv[2]);

	if(poc_id == 0 || kraj_id == 0)
		exit(EXIT_FAILURE);
	
	//Informacije o polascima
	sprintf(query, "select psm.ruta_id, psm.vreme_polaska_sa_perona as vreme_polaska, broj_perona, p.naziv as prevoznik from Polazi_sa_medjustanice psm join Prevoznik p on psm.prevoznik_id = p.id where dan = \"%s\" and psm.autobuska_stanica_id = %d and psm.vreme_polaska_sa_perona is not null and exists(select * from Polazi_sa_medjustanice psm1 where psm1.ruta_id = psm.ruta_id and psm.vreme_polaska_sa_perona < psm1.vreme_dolaska_na_peron and psm1.autobuska_stanica_id = %d) order by vreme_polaska_sa_perona", dan, poc_id, kraj_id);  
	
	if(mysql_query(konekcija, query) != 0)
	{
		exit(EXIT_FAILURE);
	}
	rezultat = mysql_use_result(konekcija);
	
	polje = mysql_fetch_field(rezultat);
	
	printf("%s\t%s\t%s\t%s\n", polje[0].name, polje[1].name, polje[2].name, polje[3].name);
	
	while((red = mysql_fetch_row(rezultat)) != 0)
		printf("%s\t%s\t%s\t%s\n", red[0], red[1], red[2], red[3]);
	
	printf("\nAko zelite informacije o cenama karte pritisnite unesite Y, inace unesite N\n");
	scanf("\n%c", &info);
	
	while(info=='Y')
	{
		printf("Unesite id rute\n"); 
		int ruta;
		scanf("%d", &ruta);
		
		//Informacije o cenama
		sprintf(query, "select distinct cena_karte, cena_mesta from Polazi_sa_medjustanice psm join Cena c on psm.prevoznik_id = c.prevoznik_id where ruta_id = %d and autobuska_stanica_id1 in(%d, %d) and autobuska_stanica_id2 in (%d, %d)", ruta, poc_id, kraj_id, poc_id, kraj_id);
	
		if(mysql_query(konekcija, query) != 0)
		{
			exit(EXIT_FAILURE);
		}
		rezultat = mysql_use_result(konekcija);
		
		polje = mysql_fetch_field(rezultat);
		
		printf("%s\t%s\n", polje[0].name, polje[1].name);
		
		while((red = mysql_fetch_row(rezultat)) != 0)
			printf("%s\t\t%s\n", red[0], red[1]);
		
		printf("\n");
		
		mysql_free_result (rezultat);
		
		printf("Ako vas zanima cena za jos neki polazak unesite Y, inace unesite N\n");
		scanf("\n%c", &info);
	}
	
	printf("Ukoliko zelite da rezervisete kartu ili mesto nesite Y, inace unesite N\n");
	scanf("\n%c", &info);
	
	if(info == 'Y')
	{
		
		int karta_id, polazak, vozilo, prev, peron;

		//Pronalazi najmanji slobodan id rezervacije
		sprintf(query, "select coalesce(max(id), 0) from Rezervacija");
		
		if(mysql_query(konekcija, query) != 0)
		{
			exit(EXIT_FAILURE);
		}
	 
		rezultat = mysql_use_result(konekcija);
		
		red = mysql_fetch_row(rezultat);
		rezer_id = atoi(red[0]) + 1;
		mysql_free_result(rezultat);
		
		printf("Ukoliko zelite da rezervisete mesto unesite M, a ukoliko zelite da rezervisete i kartu unesite K\n");
		scanf("\n%c", &info);
		
		if(info == 'M' || info == 'K')
		{
			printf("Unesite id_rute za polazak koji zelite\n");
			scanf("%d", &polazak);
			
			
			//Deo koda koji sluzi za demonstriranje rada trigera za unosenje u tabelu Rezervacija
			fprintf(f, "Pre unosa u tabelu Rezervacija\n");
			sprintf(query, "select broj_slobodnih_mesta, autobuska_stanica_id from Polazi_sa_medjustanice where ruta_id = %d order by vreme_polaska_sa_perona", polazak);
			if(mysql_query(konekcija, query) != 0)
			{
				exit(EXIT_FAILURE);
			}
			rezultat = mysql_use_result(konekcija);
			
			polje = mysql_fetch_field(rezultat);
			
			fprintf(f, "%s\t%s\n", polje[0].name, polje[1].name);
			while((red = mysql_fetch_row(rezultat)) != 0)			
				fprintf(f,"%s\t\t%s\n", red[0], red[1]);

			mysql_free_result(rezultat);
			// Kraj dela koda za demonstriranje unosenja u tabelu Rezervacija
			
			//Pronalazi id prevoznika, vozila, i broj perona
			sprintf(query, "select prevoznik_id, vozilo_id, broj_perona from Polazi_sa_medjustanice where ruta_id = %d and autobuska_stanica_id = %d", polazak, poc_id);
			
			if(mysql_query(konekcija, query) != 0)
				exit(EXIT_FAILURE);
			
			rezultat = mysql_use_result(konekcija);
			if((red = mysql_fetch_row(rezultat)) == NULL)
				exit(EXIT_FAILURE);

			prev = atoi(red[0]);
			vozilo = atoi(red[1]);
			peron = atoi(red[2]);
			
			mysql_free_result(rezultat);
			
			//Unosi podatke o rezervaciji
			sprintf(query, "insert into Rezervacija values(%d, %d, %d, %d, %d, %d, %d, 0, 0, false)", rezer_id, prev, vozilo, peron, poc_id, polazak, kraj_id);
			if(mysql_query(konekcija, query) != 0)
				exit(EXIT_FAILURE);
			
			
			//Deo koda koji sluzi za demonstriranje rada trigera za unosenje u tabelu Rezervacija
			fprintf(f, "Nakon unosa u tabelu Rezervacija\n");
			fprintf(f, "Tabela Polazi_sa_medjustanice\n");
			sprintf(query, "select broj_slobodnih_mesta, autobuska_stanica_id from Polazi_sa_medjustanice where ruta_id = %d order by vreme_polaska_sa_perona", polazak);
			if(mysql_query(konekcija, query) != 0)
			{
				exit(EXIT_FAILURE);
			}
			rezultat = mysql_use_result(konekcija);
			
			polje = mysql_fetch_field(rezultat);
			
			fprintf(f, "%s\t%s\n", polje[0].name, polje[1].name);
			while((red = mysql_fetch_row(rezultat)) != 0)			
				fprintf(f,"%s\t\t%s\n", red[0], red[1]);

			mysql_free_result(rezultat);
			
			fprintf(f, "Tabela Rezervacija\n");
			sprintf(query, "select broj_mesta, cena from Rezervacija where id = %d", rezer_id);
			if(mysql_query(konekcija, query) != 0)
			{
				exit(EXIT_FAILURE);
			}
			rezultat = mysql_use_result(konekcija);
			
			polje = mysql_fetch_field(rezultat);
			
			fprintf(f, "%s\t%s\n", polje[0].name, polje[1].name);
			red = mysql_fetch_row(rezultat);			
			fprintf(f,"%s\t\t%s\n", red[0], red[1]);

			mysql_free_result(rezultat);
			// Kraj dela koda za demonstriranje unosenja u tabelu Rezervacija
			
		}
		else
			printf("Uneli ste nevalidne podatke\n");
		
		if(info == 'K')
		{
			char popust[MAX_SIZE];
			int povratna;
			
			//Broj karte
			sprintf(query, "select coalesce(max(broj_karte), 0) from Karta where rezervacija_id = %d", rezer_id);
	
			if(mysql_query(konekcija, query) != 0)
				exit(EXIT_FAILURE);
	 
			rezultat = mysql_use_result(konekcija);
	
			red = mysql_fetch_row(rezultat);
			karta_id = atoi(red[0]) + 1;
			mysql_free_result(rezultat);
			
			
			printf("Ako zelite povratnu kartu unesite Y, inace unesite N\n");
			scanf("\n%c", &info);
			if(info == 'Y')
				povratna = 1;
			else
				povratna = 0;
			
			printf("Ako ostvarujete pravo na neki od popusta unesite Y, inace unesite N\n");
			scanf("\n%c", &info);
	
			//Unosi podatke o Karti
			if(info == 'Y')
			{
				printf("Unesite naziv popusta koji ostvarujete\n");
				scanf("%s", popust);
				sprintf(query, "insert into Karta values(%d, %d, %d, 0, \"%s\", 0)",karta_id, rezer_id, povratna, popust );
			}
			else
				sprintf(query, "insert into Karta values(%d, %d, %d, 0, null, 0)",karta_id, rezer_id, povratna);
			
			if(mysql_query(konekcija, query) != 0)
				exit(EXIT_FAILURE);
			
			
			
			//Deo koda koji sluzi za demonstriranje rada trigera za unosenje u tabelu Karta
			fprintf(f, "Nakon unosa u tabelu Karta\n");
			sprintf(query, "select k.cena as cena_karte, k.cena_sa_popustom, r.cena as rezervacija_cena from Karta k join Rezervacija r on r.id = k.rezervacija_id where k.broj_karte = %d and k.rezervacija_id = %d", karta_id, rezer_id);
			if(mysql_query(konekcija, query) != 0)
			{
				exit(EXIT_FAILURE);
			}
			rezultat = mysql_use_result(konekcija);
			
			polje = mysql_fetch_field(rezultat);
			
			fprintf(f, "%s\t%s\t%s\n", polje[0].name, polje[1].name, polje[2].name);
			
			red = mysql_fetch_row(rezultat);
			fprintf(f,"%s\t\t%s\t\t%s\n", red[0], red[1], red[2]);
			mysql_free_result(rezultat);
			// Kraj dela koda za demonstriranje unosenja u tabelu Karta
			
		}
		printf("\n\nVasa rezervacija je uspesno zabelezena\n");
		
		//Ceni karte i broj mesta
		sprintf(query, "select cena, broj_mesta from Rezervacija where id = %d", rezer_id);
		
		if(mysql_query(konekcija, query) != 0)
				exit(EXIT_FAILURE);
		
		rezultat = mysql_use_result(konekcija);
		red = mysql_fetch_row(rezultat);
		
		printf("\nCena Vase karte/mesta je %s, a vase sediste je %s\n", red[0], red[1]);
		mysql_free_result(rezultat);  
	}
	
	mysql_close(konekcija);

	printf("Srecan put!!! :D");
	
	exit(EXIT_SUCCESS);	
}

int idStanice(char stanica[], char user[], char pas[])
{
	char query[QUERY_SIZE];
	MYSQL *kon;
	MYSQL_RES *rez;
	MYSQL_ROW red;
	
	kon = mysql_init(NULL);
	if(mysql_real_connect(kon, "localhost", user, pas, "autobuska_stanica", 0, NULL, 0) == NULL)
		exit(EXIT_FAILURE);
	
	sprintf(query, "select id from Autobuska_stanica where naziv = \"%s\"", stanica);
	
	if(mysql_query(kon, query) != 0)
		printf("Greska\n");
	 
	rez = mysql_use_result(kon);
	red = mysql_fetch_row(rez);
	
	if(red == NULL)
		return 0;
	
	//mysql_free_result(rez);
	
	return atoi(red[0]);
}
