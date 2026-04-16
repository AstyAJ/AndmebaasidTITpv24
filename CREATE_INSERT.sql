CREATE DATABASE TITpv24jegorov;

--ab kustutamine 
DROP DATABASE StenEricKoit;

use TITpv24jegorov;
--tabeli loomine
CREATE TABLE opilane(
opilaneID int Primary Key identity(1,1),--automaatselt täidab numbritega/tekstiga
eesnimi varchar(25),
perenimi varchar(30) NOT NULL,
synniaeg DATE,
stip bit,
mobiil varchar(13),
aadress TEXT,
keskmineHinne decimal(2,1)); --(2--kokku, 1--peale komat nt 4.5)

SELECT * FROM opilane;

--tabeli täitmine
INSERT INTO opilane
VALUES ('Artjom','Jegorov', '2003-04-11',1,'+37258322805','Tallinn', 4.5)

INSERT INTO opilane(perenimi, eesnimi, keskmineHinne)
VALUES ('Kulberg', 'Marek', 4.9),
('Kuzmin', 'Aleksei', 5.0),
('Jegorov', 'Ruslan', 3.2),
('Filin', 'Dmitri', 4.1);

--andmete uuendamine tabelis
UPDATE opilane SET stip=1, aadress='Tallinn';

UPDATE opilane SET stip=1, aadress='Tartu' WHERE opilaneID=5;

--kustutamine 
--tabeli kustutamine
DROP TABLE opilane;
--andmete kustutamine tabelist
DELETE FROM opilane WHERE opilaneID=2;
SELECT * FROM opilane;

--FOREIGN KEY
CREATE TABLE opetamine(
opitamineID int PRIMARY KEY identity(1,1),
kuupaev DATE,
oppeaine varchar(30),
opilaneID int,
FOREIGN KEY (opilaneID) REFERENCES opilane(opilaneID),
hinne int CHECK(hinne<=5));

SELECT * FROM opetamine;
SELECT * FROM opilane;
--täidame tabeli
INSERT INTO opetamine
VALUES ('2026-04-16', 'andmebaasid',5, 3)


--PRIMARY KEY
CREATE TABLE opetaja(
opetajaID int PRIMARY KEY identity(1,1),
nimi varchar(25),
epost varchar(50),
ruum char(4));

SELECT * FROM opetaja;

INSERT INTO opetaja
VALUES ('Irina','irina@tthk.ee','E10')

--FOREIGN KEY
CREATE TABLE tund(
tundID int PRIMARY KEY identity (1,1),
kuupaev DATE,
tundinimi varchar(30),
opetajaID int,
FOREIGN KEY (opetajaID) REFERENCES opetaja(opetajaID),
opetamineID int,
FOREIGN KEY (opetamineID) REFERENCES opetamine(opetamineID) 
)



SELECT * FROM tund

INSERT INTO tund
VALUES ('2026-04-16','Andmebaasid',1)
