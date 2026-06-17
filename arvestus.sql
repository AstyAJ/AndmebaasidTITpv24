/* =========================================================
   Andmebaasi loomine: LennujaamDBART
   Töö autor: Artjom Jegorov
   Teema: Lennujaama andmebaas SQL Serveris
   ========================================================= */
CREATE DATABASE LennujaamDBART;
GO

USE LennujaamDBART;
GO

/* =========================================================
   1. Kasutaja loomine ja õiguste määramine
   Kasutaja saab luua tabeleid ning kasutada SELECT, INSERT
   ja DELETE käske. ALTER õigust ei anta.
   ========================================================= */
CREATE USER reisijaNimi WITHOUT LOGIN;
GO

SELECT name
FROM sys.database_principals
WHERE name = 'reisijaNimi';
GO

GRANT CREATE TABLE TO reisijaNimi;
GO

GRANT SELECT, INSERT, DELETE
ON SCHEMA::dbo
TO reisijaNimi;
GO

EXECUTE AS USER = 'reisijaNimi';
GO

SELECT USER_NAME();
GO

REVERT;
GO


/* =========================================================
   2. Põhitabelite loomine
   Tabelid: Lennujaam, Lend, Reisija
   Seosed:
   - üks lennujaam võib olla seotud mitme lennuga
   - üks lend võib olla seotud mitme reisijaga
   ========================================================= */
   
CREATE TABLE Lennujaam (
    LennujaamID INT IDENTITY(1,1) PRIMARY KEY,
    LennujaamaNimi NVARCHAR(100) NOT NULL,
    Linn NVARCHAR(100) NOT NULL
);
GO

INSERT INTO Lennujaam (LennujaamaNimi, Linn)
VALUES
('Tallinna Lennujaam', 'Tallinn'),
('Tartu Lennujaam', 'Tartu'),
('Helsingi Lennujaam', 'Helsingi');


CREATE TABLE Lend (
    LendID INT IDENTITY(1,1) PRIMARY KEY,
    LennuNumber NVARCHAR(20) NOT NULL,
    Valjumisaeg DATETIME NOT NULL,
    LennujaamID INT NOT NULL,

    CONSTRAINT FK_Lend_Lennujaam
        FOREIGN KEY (LennujaamID)
        REFERENCES Lennujaam(LennujaamID)
);
GO

INSERT INTO Lend (LennuNumber, Valjumisaeg, LennujaamID)
VALUES
('BT101', '2025-06-20 10:00', 1),
('AY202', '2025-06-21 12:30', 2),
('LH303', '2025-06-22 18:00', 3);
GO


CREATE TABLE Reisija (
    ReisijaID INT IDENTITY(1,1) PRIMARY KEY,
    Nimi NVARCHAR(100) NOT NULL,
    Piletinumber NVARCHAR(50) NOT NULL,
    LendID INT NOT NULL,

    CONSTRAINT FK_Reisija_Lend
        FOREIGN KEY (LendID)
        REFERENCES Lend(LendID)
);
GO

INSERT INTO Reisija (Nimi, Piletinumber, LendID)
VALUES
('Artjom Jegorov', 'ART001', 1),
('Marko Saar', 'ART002', 1),
('Anna Kask', 'ART003', 2),
('Karl Tamm', 'ART004', 3);

/* =========================================================
   3. Testandmete lisamine
   Andmed on lisatud selleks, et kontrollida tabelite,
   seoste, vaadete ja protseduuride tööd.
   ========================================================= */
SELECT * FROM Lennujaam;
SELECT * FROM Lend;
SELECT * FROM Reisija;


/* =========================================================
   4. Logitabeli loomine
   Tabel Logi salvestab kasutaja, kuupäeva, tegevuse
   ja lennu andmed, kui tabelis Lend toimub INSERT või DELETE.
   ========================================================= */
CREATE TABLE Logi (
    LogiID INT IDENTITY(1,1) PRIMARY KEY,
    Kasutaja NVARCHAR(100),
    Kuupaev DATETIME,
    Tegevus NVARCHAR(50),
    SisestatudAndmed NVARCHAR(MAX)
);
GO

SELECT * FROM Logi;

/* =========================================================
   5. Trigger INSERT jaoks
   Kui tabelisse Lend lisatakse uus lend, siis lisatakse
   selle kohta automaatselt kirje tabelisse Logi.
   ========================================================= */
CREATE TRIGGER trg_Lend_Insert
ON Lend
AFTER INSERT
AS
BEGIN

INSERT INTO Logi (Kasutaja,Kuupaev,Tegevus,SisestatudAndmed)

SELECT
SYSTEM_USER,
GETDATE(),'INSERT',
CONCAT('LendID=', LendID,'; LennuNumber=', LennuNumber,'; Valjumisaeg=', Valjumisaeg,'; LennujaamID=', LennujaamID)

FROM inserted;

END;
GO

INSERT INTO Lend (LennuNumber,Valjumisaeg,LennujaamID)
VALUES ('SK404','2025-06-25 15:30',1);
GO

SELECT * FROM Logi;

/* =========================================================
   6. Trigger DELETE jaoks
   Kui tabelist Lend kustutatakse lend, siis salvestatakse
   kustutatud lennu andmed tabelisse Logi.
   ========================================================= */

CREATE TRIGGER trg_Lend_Delete
ON Lend
AFTER DELETE
AS
BEGIN

INSERT INTO Logi
    (
        Kasutaja,
        Kuupaev,
        Tegevus,
        SisestatudAndmed
    )

    SELECT
        SYSTEM_USER,
        GETDATE(),
        'DELETE',

        CONCAT(
            'LendID=', LendID,
            '; LennuNumber=', LennuNumber,
            '; Valjumisaeg=', Valjumisaeg,
            '; LennujaamID=', LennujaamID
        )

    FROM deleted;

END;
GO

DELETE FROM Lend
WHERE LennuNumber = 'SK404';
GO

SELECT * FROM Logi;


/* =========================================================
   7. Salvestatud protseduurid
   Protseduurid lihtsustavad uute lennujaamade ja lendude
   lisamist ning reisija otsimist nime järgi.
   ========================================================= */

CREATE PROCEDURE LisaLennujaam
    @Nimi NVARCHAR(100),
    @Linn NVARCHAR(100)
AS
BEGIN
    INSERT INTO Lennujaam (LennujaamaNimi, Linn)
    VALUES (@Nimi, @Linn);
END;
GO

CREATE PROCEDURE LisaLend
    @LennuNumber NVARCHAR(20),
    @Valjumisaeg DATETIME,
    @LennujaamID INT
AS
BEGIN
    INSERT INTO Lend (LennuNumber, Valjumisaeg, LennujaamID)
    VALUES (@LennuNumber, @Valjumisaeg, @LennujaamID);
END;
GO

CREATE PROCEDURE OtsiReisijaNimeJargi
    @Nimi NVARCHAR(100)
AS
BEGIN
    SELECT *
    FROM Reisija
    WHERE Nimi LIKE '%' + @Nimi + '%';
END;
GO


EXEC LisaLennujaam 'Riia Lennujaam', 'Riia';
EXEC LisaLend 'FR555', '2025-06-30 09:45', 4;
EXEC OtsiReisijaNimeJargi 'Artjom';
GO

/* =========================================================
   8. Vaadete loomine
   Vaated ühendavad vähemalt kaks tabelit ja muudavad
   andmete vaatamise lihtsamaks.
   ========================================================= */
CREATE VIEW Vaade_Lennud_Lennujaamad AS
SELECT 
    L.LendID,
    L.LennuNumber,
    L.Valjumisaeg,
    LJ.LennujaamaNimi,
    LJ.Linn
FROM Lend L
JOIN Lennujaam LJ ON L.LennujaamID = LJ.LennujaamID;
GO

CREATE VIEW Vaade_Reisijad_Lennud AS
SELECT 
    R.ReisijaID,
    R.Nimi,
    R.Piletinumber,
    L.LennuNumber,
    L.Valjumisaeg
FROM Reisija R
JOIN Lend L ON R.LendID = L.LendID;
GO

CREATE VIEW Vaade_Reisijad_Lennujaamad AS
SELECT 
    R.Nimi,
    R.Piletinumber,
    L.LennuNumber,
    LJ.LennujaamaNimi,
    LJ.Linn
FROM Reisija R
JOIN Lend L ON R.LendID = L.LendID
JOIN Lennujaam LJ ON L.LennujaamID = LJ.LennujaamID;
GO


SELECT * FROM Vaade_Lennud_Lennujaamad;
SELECT * FROM Vaade_Reisijad_Lennud;
SELECT * FROM Vaade_Reisijad_Lennujaamad;
GO

/* =========================================================
   9. ALTER õiguse kontroll
   See kontroll peab andma vea, sest kasutajale reisijaNimi
   ei ole antud ALTER õigust.
   ========================================================= */

EXECUTE AS USER = 'reisijaNimi';
GO

ALTER TABLE Lend ADD TestColumn NVARCHAR(50);
GO

REVERT;
GO

USE LennujaamDBART;
GO

/* =========================================================
   10. Lisafunktsionaalsus
   Tabel Broneering võimaldab salvestada reisijate broneeringuid.
   ========================================================= */

CREATE TABLE Broneering (
    BroneeringID INT IDENTITY(1,1) PRIMARY KEY,
    ReisijaID INT NOT NULL,
    BroneeringuKuupaev DATETIME DEFAULT GETDATE(),
    Staatus NVARCHAR(50) DEFAULT 'Aktiivne',

    CONSTRAINT FK_Broneering_Reisija
        FOREIGN KEY (ReisijaID)
        REFERENCES Reisija(ReisijaID)
);
GO

INSERT INTO Broneering (ReisijaID)
VALUES (1);

SELECT * FROM Broneering;
GO
