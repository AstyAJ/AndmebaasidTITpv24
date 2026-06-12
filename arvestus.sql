CREATE LOGIN reisijaNimi
WITH PASSWORD = '1234',
     CHECK_POLICY = OFF;

USE LennujaamDB;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'Reisija';


SELECT * FROM dbo.Reisija;
DROP TABLE dbo.Reisija;

CREATE USER reisijaNimi
FOR LOGIN reisijaNimi;

GRANT CREATE TABLE TO reisijaNimi;

GRANT SELECT TO reisijaNimi;

GRANT INSERT ON Reisija TO reisijaNimi;
GRANT DELETE ON Reisija TO reisijaNimi;

GRANT INSERT ON Lend TO reisijaNimi;
GRANT DELETE ON Lend TO reisijaNimi;

DENY ALTER ON OBJECT::Reisija TO reisijaNimi;
DENY ALTER ON OBJECT::Lend TO reisijaNimi;









CREATE DATABASE LennujaamDB;

use LennujaamDB;

CREATE TABLE Lennujaam(
LennujaamID int Primary key identity(1,1),
LennujaamaNimi Varchar(100) NOT NULL,
Linn Varchar(100) NOT NULL)

SELECT * FROM Lennujaam;

INSERT INTO Lennujaam
VALUES ('Dubai International Airport','Dubai'),
('London Heathrow Airport','London'),
('Tokyo Haneda Airport','Tokyo'),
('John F. Kennedy Airport','USA'),
('Paris Charles de Gaulle Airport','Paris'),
('Beijing Capital Airport','Pekin');

CREATE TABLE Lend(
LendID INT PRIMARY KEY identity (1,1),
LennuNumber Varchar(20) NOT NULL,
Valjumisaeg DATETIME NOT NULL,
LennujaamID INT NOT NULL,
FOREIGN KEY(LennujaamID)
	REFERENCES Lennujaam(LennujaamID));

CREATE TABLE Reisija(
ReisijaID INT PRIMARY KEY identity (1,1),
Nimi Varchar(100) NOT NULL,
Piletinumber Varchar(50) NOT NULL,
LendID INT NOT NULL,
FOREIGN KEY (LendID)
	REFERENCES Lend(LendID));

SELECT * FROM Reisija;

DROP TABLE Reisija;

sp_help Reisija;

INSERT INTO Reisija (ReisijaID, Nimi, Piletinumber, LendID)
VALUES (1, 'Ivan Ivanov', 'К421', 1);

REVOKE ALTER ON DATABASE::LennujaamDB FROM reisijaNimi;

CREATE TABLE logi (
id INT PRIMARY KEY IDENTITY (1,1),
kasutaja Varchar(100),
kuupaev DATETIME,
sisestatudAndmed TEXT);

CREATE TRIGGER lend_delete
AFTER DELETE ON Lend
FOR EACH ROW
INSERT INTO logi (kasutaja,kuupaev,sisestatudAndmed)
VALUES (reisijaID,NOW(),CONCAT('Kustutatu lend ID:', OLD.ID));

CREATE TRIGGER lend_insert
AFTER INSERT ON Lend
FOR EACH ROW
INSERT INTO logi (kasutaja, kuupaev, sisestatudAndmed)
VALUES (reisijaID, NOW(), CONCAT('Lisati lend ID:', NEW.id));

INSERT INTO logi (...)
VALUES (
    reisijaID,
    NOW(),
    CONCAT('Lend: ', NEW.id, ' Lennujaam: ', NEW.lennujaam_id)
);
