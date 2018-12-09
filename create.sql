drop database if exists autobuska_stanica;

create database autobuska_stanica;

use autobuska_stanica;

drop table if exists Autobuska_stanica;

create table if not exists Autobuska_stanica (
	id int not null,
	naziv varchar(45) not null,
	grad varchar(45) not null,
	broj_telefona varchar(20) not null,
	primary key (id)
);

drop table if exists Peron;

create table if not exists Peron(
	broj_perona int not null,
	slobodan boolean not null,
	Autobuska_stanica_id int not null,
	primary key(broj_perona, Autobuska_stanica_id),
	constraint fk_Peron_Autobuska_stanica foreign key(Autobuska_stanica_id)
		references Autobuska_stanica(id)
		on delete cascade
		on update cascade
);

drop table if exists Prevoznik;

create table if not exists Prevoznik(
	id int not null,
	naziv varchar(45) not null,
	email varchar(45) not null,
	broj_telefona varchar(20) not null,
	primary key(id)
);

drop table if exists Vozac;

create table if not exists Vozac(
	maticni_broj int not null,
	ime varchar(45) not null,
	prezime varchar(45) not null,
	broj_telefona varchar(20) not null,
	Prevoznik_id int not null,
	primary key (maticni_broj),
	constraint fk_Vozac_Prevoznik foreign key(Prevoznik_id)
		references Prevoznik(id)
		on delete cascade
		on update cascade
);

drop table if exists Vozilo;

create table if not exists Vozilo(
	id int not null,
	Prevoznik_id int not null,
	broj_mesta int not null,
	tip varchar(45) not null,
	primary key(id, Prevoznik_id),
	constraint fk_Vozilo_Prevoznik foreign key(Prevoznik_id)
		references Prevoznik(id)
		on delete cascade
		on update cascade
);

drop table if exists Vozi;

create table if not exists Vozi(
	Vozac_maticni_broj int not null,
	Prevoznik_id int not null,
	Vozilo_id int not null,
	primary key(Prevoznik_id, Vozilo_id),
	constraint fk_Vozi_Vozilo foreign key(Prevoznik_id, Vozilo_id)
		references Vozilo(Prevoznik_id, id)
		on delete cascade
		on update cascade,
	constraint fk_Vozi_Vozac foreign key(Vozac_maticni_broj)
		references Vozac(maticni_broj)
		on delete cascade
		on update cascade
);

drop table if exists Polazi_sa_sanice;

create table if not exists Polazi_sa_sanice(
	datum date not null,
	vreme_dolaska_na_peron time not null,
	vreme_polaska_sa_perona time,
	broj_slobodnih_mesta int unsigned not null,
	Prevoznik_id int not null,
	Vozilo_id int not null,
	Broj_perona int not null,
	Autobuska_stanica_id int not null,
	Polazak_id int not null,
	primary key (Prevoznik_id, Vozilo_id, Broj_perona, Autobuska_stanica_id, Polazak_id),
	constraint fk_Polazi_Vozi foreign key(Prevoznik_id, Vozilo_id)
		references Vozi(Prevoznik_id, Vozilo_id)
		on delete cascade
		on update cascade,
	constraint fk_Polazi_Peron foreign key(Broj_perona, Autobuska_stanica_id)
		references Peron(broj_perona, Autobuska_stanica_id)
		on delete cascade
		on update cascade
);

drop table if exists Rezervacija;

create table if not exists Rezervacija(
	id_rezervacije int not null,
	Prevoznik_id int not null,
	Vozilo_id int not null,
	Broj_perona int not null,
	Autobuska_stanica_id int not null,
	Polazak_id int not null,
	odrediste int not null,
	broj_mesta int not null,
	preuzeta boolean not null,
	primary key(id_rezervacije),
	constraint fk_Rezervacija_Polazi foreign key(Prevoznik_id, Vozilo_id, Broj_perona, Autobuska_stanica_id, Polazak_id)
		references Polazi_sa_sanice(Prevoznik_id, Vozilo_id, Broj_perona, Autobuska_stanica_id, Polazak_id)
		on delete cascade 
		on update cascade,
	constraint fk_Rezervacija_Autobuska_stanica foreign key(odrediste)
		references Autobuska_stanica(id)
		on delete cascade
		on update cascade
);

drop table if exists Karta;

create table if not exists Karta(
	broj_karte int not null,
	Rezervacija_id int not null,
	povratna boolean not null,
	cena decimal(7, 2) not null,
	vrsta_popusta varchar(45),
	cena_sa_popustom decimal(7, 2) not null,
	primary key(broj_karte, Rezervacija_id),
	constraint fk_Karta_Rezervacija foreign key(Rezervacija_id)
		references Rezervacija(id_rezervacije)
		on delete cascade
		on update cascade
);

drop table if exists Mesto;

create table if not exists Mesto(
	Rezervacija_id int not null,
	cena decimal(7, 2) not null,
	primary key(Rezervacija_id),
	constraint fk_Mesto_Rezervacija foreign key(Rezervacija_id)
		references Rezervacija(id_rezervacije)
		on delete cascade
		on update cascade
);

drop table if exists Cena;

create table if not exists Cena(
	Autobuska_stanica_id int not null,
	Autobuska_stanica_id1 int not null,
	Prevoznik_id int not null,
	cena_karte decimal(7, 2) not null,
	cena_mesta decimal(7, 2) not null,
	primary key(Autobuska_stanica_id, Autobuska_stanica_id1, Prevoznik_id),
	constraint fk_Cena_Autobuska_stanica foreign key(Autobuska_stanica_id)
		references Autobuska_stanica(id)
		on delete cascade
		on update cascade,
	constraint fk_Cena_Autobuska_stanica1 foreign key(Autobuska_stanica_id1)
		references Autobuska_stanica(id)
		on delete cascade
		on update cascade,
	unique(Autobuska_stanica_id, Autobuska_stanica_id1)
);

drop table if exists Popust;

create table if not exists Popust(
	id int not null,
	Prevoznik_id int not null,
	iznos_u_procentima int not null,
	primary key(id, Prevoznik_id),
	constraint fk_Popust_Prevoznik foreign key(Prevoznik_id)
		references Prevoznik(id)
		on delete cascade
		on update cascade
);

drop table if exists Povratna_karta;

create table if not exists Povratna_karta(
	Popust_id int not null,
	Prevoznik_id int not null,
	vazi_dana int not null,
	primary key(Popust_id, Prevoznik_id),
	constraint fk_Povratna_karta_Popust foreign key(Popust_id, Prevoznik_id)
		references Popust(id, Prevoznik_id)
		on delete cascade
		on update cascade
);

drop table if exists Ostali_popusti;

create table if not exists Ostali_popusti(
	Popust_id int not null, 
	Prevoznik_id int not null,
	naziv_popusta varchar(45) not null,
	primary key(Popust_id, Prevoznik_id),
	constraint fk_Ostali_popusti_Popust foreign key(Popust_id, Prevoznik_id)
		references Popust(id, Prevoznik_id)
		on delete cascade
		on update cascade
);