use autobuska_stanica

delimiter |

drop trigger if exists triger_biPolazi_sa_medjustanice |

create trigger triger_biPolazi_sa_medjustanice before insert on Polazi_sa_medjustanice
for each row
begin
	set new.broj_slobodnih_mesta = (select broj_mesta from Vozilo where id = new.vozilo_id and prevoznik_id = new.prevoznik_id);
end |

drop trigger if exists trigger_biKarta |

create trigger trigger_biKarta before insert on Karta
for each row
begin
	declare pocetna_stanica integer;
	declare krajnja_stanica integer;
	declare prevoznik integer;
	declare popust integer;
	declare povratna integer;
	
	set pocetna_stanica = (select autobuska_stanica_id from Rezervacija where id = new.rezervacija_id);
	set krajnja_stanica = (select odrediste_id from Rezervacija where id = new.rezervacija_id);
	set prevoznik = (select prevoznik_id from Rezervacija where id = new.rezervacija_id);

	set new.cena = (select cena_karte from Cena where autobuska_stanica_id1 in (pocetna_stanica, krajnja_stanica) and autobuska_stanica_id2 in (pocetna_stanica, krajnja_stanica) and prevoznik_id = prevoznik);
	
	
	
	if(new.povratna = true)
	then
		set povratna = (select popust_id from Povratna_karta where prevoznik_id = prevoznik);
		set new.cena_sa_popustom = new.cena + new.cena* (select iznos_u_procentima from Popust where id = povratna and prevoznik_id = prevoznik)/100.0;
	else
		set new.cena_sa_popustom = new.cena;	
	end if;
	
	if(new.vrsta_popusta is not null)
	then
		set popust = (select popust_id from Ostali_popusti where prevoznik_id = prevoznik and naziv_popusta = new.vrsta_popusta);
		set new.cena_sa_popustom = new.cena_sa_popustom * (select iznos_u_procentima from Popust where id = popust and prevoznik_id = prevoznik)/100.0;
	end if;
	
	begin 
		update Rezervacija
			set cena = new.cena_sa_popustom
		where id = new.rezervacija_id;
	end;
end |


drop trigger if exists triger_biRezervacija |

create trigger triger_biRezervacija before insert on Rezervacija
for each row
begin
	declare mesto integer;
	declare vreme_polaska time;
	declare vreme_dolaska time;

	set new.cena = (select cena_mesta from Cena where autobuska_stanica_id1 in (new.autobuska_stanica_id, new.odrediste_id) and autobuska_stanica_id2 in (new.autobuska_stanica_id, new.odrediste_id) and new.prevoznik_id = prevoznik_id);
	
	set mesto = (select max(broj_mesta) from Rezervacija where ruta_id = new.ruta_id); 
	
	if(mesto >= (select broj_mesta from Vozilo where id = new.vozilo_id and prevoznik_id = new.prevoznik_id))
	then
		signal sqlstate '45000' set message_text = 'Nema vise slobodnih mesta'; 
	end if;
	
	if(mesto is null)
	then
		set new.broj_mesta = 1;
	else
		set new.broj_mesta = mesto + 1;
	end if;
	
	set vreme_polaska = (select vreme_polaska_sa_perona from Polazi_sa_medjustanice where new.autobuska_stanica_id = autobuska_stanica_id and new.prevoznik_id = prevoznik_id and new.vozilo_id = vozilo_id and broj_perona = new.broj_perona and ruta_id = new.ruta_id);
	set vreme_dolaska = (select vreme_dolaska_na_peron from Polazi_sa_medjustanice where new.odrediste_id = autobuska_stanica_id and new.prevoznik_id = prevoznik_id and new.vozilo_id = vozilo_id  and ruta_id = new.ruta_id);
	
	
	update Polazi_sa_medjustanice 
		set broj_slobodnih_mesta = broj_slobodnih_mesta - 1
	where new.ruta_id = ruta_id and vreme_polaska_sa_perona >= vreme_polaska and vreme_dolaska_na_peron<vreme_dolaska;
	
end |

delimiter ;