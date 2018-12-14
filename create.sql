SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP DATABASE IF EXISTS `autobuska_stanica` ;
CREATE DATABASE `autobuska_stanica` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `autobuska_stanica` ;

-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Autobuska_stanica`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Autobuska_stanica` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Autobuska_stanica` (
  `id` INT NOT NULL,
  `naziv` VARCHAR(45) NOT NULL,
  `grad` VARCHAR(45) NOT NULL,
  `broj_telefona` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Peron`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Peron` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Peron` (
  `broj_perona` INT NOT NULL,
  `autobuska_stanica_id` INT NOT NULL,
  `slobodan` TINYINT(1) NOT NULL,
  PRIMARY KEY (`broj_perona`, `autobuska_stanica_id`),
  INDEX `fk_Peron_Autobuska_stanica_idx` (`autobuska_stanica_id` ASC),
  CONSTRAINT `fk_Peron_Autobuska_stanica`
    FOREIGN KEY (`autobuska_stanica_id`)
    REFERENCES `autobuska_stanica`.`Autobuska_stanica` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Ruta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Ruta` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Ruta` (
  `id` INT NOT NULL,
  `dan_polaska` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Prevoznik`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Prevoznik` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Prevoznik` (
  `id` INT NOT NULL,
  `naziv` VARCHAR(45) NOT NULL,
  `e_mail` VARCHAR(45) NULL,
  `broj_telefona` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Vozac`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Vozac` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Vozac` (
  `maticni_broj` INT NOT NULL,
  `ime` VARCHAR(45) NOT NULL,
  `prezime` VARCHAR(45) NOT NULL,
  `broj_telefona` VARCHAR(45) NOT NULL,
  `prevoznik_id` INT NOT NULL,
  PRIMARY KEY (`maticni_broj`),
  INDEX `fk_Vozac_Prevoznik1_idx` (`prevoznik_id` ASC),
  CONSTRAINT `fk_Vozac_Prevoznik1`
    FOREIGN KEY (`prevoznik_id`)
    REFERENCES `autobuska_stanica`.`Prevoznik` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Vozilo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Vozilo` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Vozilo` (
  `id` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  `broj_mesta` INT NOT NULL,
  `tip` VARCHAR(45) NOT NULL,
  INDEX `fk_Vozilo_Prevoznik1_idx` (`prevoznik_id` ASC),
  PRIMARY KEY (`id`, `prevoznik_id`),
  CONSTRAINT `fk_Vozilo_Prevoznik1`
    FOREIGN KEY (`prevoznik_id`)
    REFERENCES `autobuska_stanica`.`Prevoznik` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Vozi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Vozi` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Vozi` (
  `vozac_maticni_broj` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  `vozilo_id` INT NOT NULL,
  PRIMARY KEY (`prevoznik_id`, `vozilo_id`),
  INDEX `fk_Vozi_Vozilo1_idx` (`prevoznik_id` ASC, `vozilo_id` ASC),
  CONSTRAINT `fk_Vozi_Vozac1`
    FOREIGN KEY (`vozac_maticni_broj`)
    REFERENCES `autobuska_stanica`.`Vozac` (`maticni_broj`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Vozi_Vozilo1`
    FOREIGN KEY (`prevoznik_id` , `vozilo_id`)
    REFERENCES `autobuska_stanica`.`Vozilo` (`prevoznik_id` , `id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Polazi_sa_medjustanice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Polazi_sa_medjustanice` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Polazi_sa_medjustanice` (
  `dan` VARCHAR(10) NOT NULL,
  `vreme_dolaska_na_peron` TIME NOT NULL,
  `vreme_polaska_sa_perona` TIME NULL,
  `broj_slobodnih_mesta` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  `vozilo_id` INT NOT NULL,
  `broj_perona` INT NOT NULL,
  `autobuska_stanica_id` INT NOT NULL,
  `ruta_id` INT NOT NULL,
  PRIMARY KEY (`prevoznik_id`, `vozilo_id`, `broj_perona`, `autobuska_stanica_id`, `ruta_id`),
  INDEX `fk_Polazi_sa_stanice_Peron1_idx` (`broj_perona` ASC, `autobuska_stanica_id` ASC),
  INDEX `fk_Polazi_sa_stanice_Polazak1_idx` (`ruta_id` ASC),
  CONSTRAINT `fk_Polazi_sa_stanice_Vozi1`
    FOREIGN KEY (`prevoznik_id` , `vozilo_id`)
    REFERENCES `autobuska_stanica`.`Vozi` (`prevoznik_id` , `vozilo_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Polazi_sa_stanice_Peron1`
    FOREIGN KEY (`broj_perona` , `autobuska_stanica_id`)
    REFERENCES `autobuska_stanica`.`Peron` (`broj_perona` , `autobuska_stanica_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Polazi_sa_stanice_Polazak1`
    FOREIGN KEY (`ruta_id`)
    REFERENCES `autobuska_stanica`.`Ruta` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Rezervacija`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Rezervacija` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Rezervacija` (
  `id` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  `vozilo_id` INT NOT NULL,
  `broj_perona` INT NOT NULL,
  `autobuska_stanica_id` INT NOT NULL,
  `ruta_id` INT NOT NULL,
  `odrediste_id` INT NOT NULL,
  `broj_mesta` INT NOT NULL,
  `cena` DECIMAL(7,2) NOT NULL,
  `preuzeta` TINYINT(1) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Rezervacija_Polazi_sa_stanice1_idx` (`prevoznik_id` ASC, `vozilo_id` ASC, `broj_perona` ASC, `autobuska_stanica_id` ASC, `ruta_id` ASC),
  INDEX `fk_Rezervacija_Autobuska_stanica1_idx` (`odrediste_id` ASC),
  CONSTRAINT `fk_Rezervacija_Polazi_sa_stanice1`
    FOREIGN KEY (`prevoznik_id` , `vozilo_id` , `broj_perona` , `autobuska_stanica_id` , `ruta_id`)
    REFERENCES `autobuska_stanica`.`Polazi_sa_medjustanice` (`prevoznik_id` , `vozilo_id` , `broj_perona` , `autobuska_stanica_id` , `ruta_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Rezervacija_Autobuska_stanica1`
    FOREIGN KEY (`odrediste_id`)
    REFERENCES `autobuska_stanica`.`Autobuska_stanica` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Karta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Karta` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Karta` (
  `broj_karte` INT NOT NULL,
  `rezervacija_id` INT NOT NULL,
  `povratna` TINYINT(1) NOT NULL,
  `cena` DECIMAL NOT NULL,
  `vrsta_popusta` VARCHAR(45) NULL,
  `cena_sa_popustom` DECIMAL NOT NULL,
  PRIMARY KEY (`broj_karte`, `rezervacija_id`),
  INDEX `fk_Karta_Rezervacija1_idx` (`rezervacija_id` ASC),
  CONSTRAINT `fk_Karta_Rezervacija1`
    FOREIGN KEY (`rezervacija_id`)
    REFERENCES `autobuska_stanica`.`Rezervacija` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Popust`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Popust` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Popust` (
  `id` INT NOT NULL,
  `iznos_u_procentima` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  PRIMARY KEY (`id`, `prevoznik_id`),
  INDEX `fk_Popust_Prevoznik1_idx` (`prevoznik_id` ASC),
  CONSTRAINT `fk_Popust_Prevoznik1`
    FOREIGN KEY (`prevoznik_id`)
    REFERENCES `autobuska_stanica`.`Prevoznik` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Povratna_karta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Povratna_karta` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Povratna_karta` (
  `popust_id` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  `vazi_dana` INT NOT NULL,
  PRIMARY KEY (`popust_id`, `prevoznik_id`),
  CONSTRAINT `fk_Povratna_karta_Popust1`
    FOREIGN KEY (`popust_id` , `prevoznik_id`)
    REFERENCES `autobuska_stanica`.`Popust` (`id` , `prevoznik_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Ostali_popusti`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Ostali_popusti` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Ostali_popusti` (
  `popust_id` INT NOT NULL,
  `prevoznik_id` INT NOT NULL,
  `naziv_popusta` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`popust_id`, `prevoznik_id`),
  CONSTRAINT `fk_Ostali_popusti_Popust1`
    FOREIGN KEY (`popust_id` , `prevoznik_id`)
    REFERENCES `autobuska_stanica`.`Popust` (`id` , `prevoznik_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `autobuska_stanica`.`Cena`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `autobuska_stanica`.`Cena` ;

CREATE TABLE IF NOT EXISTS `autobuska_stanica`.`Cena` (
  `autobuska_stanica_id1` INT NOT NULL,
  `autobuska_stanica_id2` INT NOT NULL,
  `prevoznik_id` INT NULL,
  `cena_karte` DECIMAL(7,2) NOT NULL,
  `cena_mesta` DECIMAL(7,2) NOT NULL,
  PRIMARY KEY (`autobuska_stanica_id1`, `autobuska_stanica_id2`, `prevoznik_id`),
  INDEX `fk_Cena_karte_Autobuska_stanica2_idx` (`autobuska_stanica_id2` ASC),
  INDEX `fk_Cena_karte_Prevoznik1_idx` (`prevoznik_id` ASC),
  CONSTRAINT `fk_Cena_karte_Autobuska_stanica1`
    FOREIGN KEY (`autobuska_stanica_id1`)
    REFERENCES `autobuska_stanica`.`Autobuska_stanica` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Cena_karte_Autobuska_stanica2`
    FOREIGN KEY (`autobuska_stanica_id2`)
    REFERENCES `autobuska_stanica`.`Autobuska_stanica` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Cena_karte_Prevoznik1`
    FOREIGN KEY (`prevoznik_id`)
    REFERENCES `autobuska_stanica`.`Prevoznik` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE(`autobuska_stanica_id1`, `autobuska_stanica_id2`, `prevoznik_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
