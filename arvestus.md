# LennujaamDBART

## Autor

Artjom Jegorov

## Töö eesmärk

Selle töö eesmärk oli luua Microsoft SQL Server keskkonnas lennujaama andmebaas. Andmebaas võimaldab hallata lennujaamade, lendude, reisijate ja broneeringute andmeid. Lisaks realiseeriti kasutajate õigused, triggerid, protseduurid, vaated ning logimissüsteem.

---

# Kasutatud tehnoloogiad

* Microsoft SQL Server LocalDB
* SQL Server Management Studio (SSMS)
* GitHub

---

# Andmebaasi loomine

Esimesena loodi uus andmebaas nimega **LennujaamDBART**.

```sql
CREATE DATABASE LennujaamDBART;
GO

USE LennujaamDBART;
GO
```

# Kasutaja loomine ja õigused

Loodi kasutaja **reisijaNimi**, kellele anti piiratud õigused.

Lubatud tegevused:

* CREATE TABLE
* SELECT
* INSERT
* DELETE

Keelatud tegevused:

* ALTER

```sql
CREATE LOGIN reisijaNimi
WITH PASSWORD = 'Parool123!';
GO

CREATE USER reisijaNimi
FOR LOGIN reisijaNimi;
GO

GRANT CREATE TABLE TO reisijaNimi;
GO

GRANT SELECT, INSERT, DELETE
ON SCHEMA::dbo
TO reisijaNimi;
GO
```

### Tulemus

<img width="117" height="88" alt="{F44D4529-A370-43D7-A8B4-A9F9CC8FC6A0}" src="https://github.com/user-attachments/assets/f6961028-991c-4dbf-a880-0f51d2a45f9d" />


# Tabelite loomine

Andmebaasis loodi järgmised tabelid:

* Lennujaam
* Lend
* Reisija
* Logi
* Broneering

## Seoste skeem

<img width="532" height="388" alt="{3310971E-3A5D-43FF-8E2D-A6DD77630A89}" src="https://github.com/user-attachments/assets/700113b5-ce30-40df-9821-324cfbc34564" />


### Tabel Lennujaam
```sql
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
```
Sisaldab lennujaamade andmeid.

### Tabel Lend
```sql
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
```
Sisaldab lendude andmeid.

### Tabel Reisija
```sql
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
```
Sisaldab reisijate andmeid.

### Tulemus
```sql
SELECT * FROM Lennujaam;
SELECT * FROM Lend;
SELECT * FROM Reisija;
```
<img width="387" height="373" alt="{95CB7DE4-7DA8-46A2-B719-5140CB9EEF4E}" src="https://github.com/user-attachments/assets/01775b9f-30e7-4425-b90e-0b0bb0ff6927" />


# Testandmete lisamine

Pärast tabelite loomist lisati testandmed süsteemi töö kontrollimiseks.

Näiteks lisati:

* Tallinna Lennujaam
* Tartu Lennujaam
* Helsingi Lennujaam

ning mitu lendu ja reisijat.

### Tulemus

<img width="387" height="373" alt="{95CB7DE4-7DA8-46A2-B719-5140CB9EEF4E}" src="https://github.com/user-attachments/assets/1ede42a3-2049-4f24-8907-105433d161bc" />


# Logitabel

Loodi tabel **Logi**, kuhu salvestatakse automaatselt andmed tehtud muudatuste kohta.

Logitabel sisaldab:

* kasutaja nime
* kuupäeva
* tegevuse tüüpi
* lennu andmeid

```sql
CREATE TABLE Logi (
    LogiID INT IDENTITY(1,1) PRIMARY KEY,
    Kasutaja NVARCHAR(100),
    Kuupaev DATETIME,
    Tegevus NVARCHAR(50),
    SisestatudAndmed NVARCHAR(MAX)
);
GO
```

# Triggerid

## INSERT Trigger

Trigger käivitub automaatselt pärast uue lennu lisamist tabelisse **Lend**.

Trigger salvestab:

* kasutaja
* kuupäeva
* tegevuse tüübi
* lisatud lennu andmed
```sql
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
```
### Tulemus

<img width="661" height="147" alt="{604EAADC-3770-4092-94B1-ABDC4168EF32}" src="https://github.com/user-attachments/assets/f04bc05a-7f75-4c2c-9786-790b972c8792" />


## DELETE Trigger

Trigger käivitub automaatselt pärast lennu kustutamist.

Kustutatud lennu andmed salvestatakse tabelisse **Logi**.
```sql
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
```
### Tulemus

<img width="647" height="36" alt="{468BFA87-FFAF-42DB-B960-DB805C615402}" src="https://github.com/user-attachments/assets/08e1a002-87d7-488d-a2d5-f61825dd5d54" />

# Salvestatud protseduurid

Loodi kolm protseduuri.

## LisaLennujaam

Lisab uue lennujaama.
```sql
CREATE PROCEDURE LisaLennujaam
    @Nimi NVARCHAR(100),
    @Linn NVARCHAR(100)
AS
BEGIN
    INSERT INTO Lennujaam (LennujaamaNimi, Linn)
    VALUES (@Nimi, @Linn);
END;
GO
```

<img width="285" height="104" alt="{D4E82550-B86E-4EC7-821D-6D074E6884F5}" src="https://github.com/user-attachments/assets/92fd5740-f72b-4a86-a2d7-802ca72af73c" />

## LisaLend

Lisab uue lennu.
```sql
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
```

<img width="396" height="129" alt="{7640835B-A383-449C-B485-0602D3C80DE2}" src="https://github.com/user-attachments/assets/c97a7cb3-0e28-4b3c-85ae-c9399b8c674d" />

## OtsiReisijaNimeJargi

Otsib reisijat nime järgi.
```sql
CREATE PROCEDURE OtsiReisijaNimeJargi
    @Nimi NVARCHAR(100)
AS
BEGIN
    SELECT *
    FROM Reisija
    WHERE Nimi LIKE '%' + @Nimi + '%';
END;
GO
```

<img width="305" height="113" alt="{9C811412-563E-4A0A-8628-31031DBCD05E}" src="https://github.com/user-attachments/assets/2c40c656-da82-4d2c-94cf-98ca22b38ab7" />

# Vaated

Loodi kolm vaadet.


## Vaade_Lennud_Lennujaamad

Kuvab lennud koos lennujaamade andmetega.
```sql
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
```

## Vaade_Reisijad_Lennud

Kuvab reisijad koos lendudega.
```sql
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
```

## Vaade_Reisijad_Lennujaamad

Kuvab reisijad, lennud ja lennujaamad ühes vaates.

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
```

### Tulemus

Lisa siia vaadete ekraanipilt.

![Views](screenshots/views.png)

---

# Õiguste kontroll

Kontrolliti, et kasutajal **reisijaNimi** puudub ALTER õigus.

```sql
ALTER TABLE Lend
ADD TestColumn NVARCHAR(50);
```

SQL Server tagastas veateate, mis kinnitas õiguste korrektset seadistamist.

### Tulemus

Lisa siia ALTER vea ekraanipilt.

![Permissions](screenshots/alter_error.png)

---

# Lisafunktsionaalsus

Lisati tabel **Broneering**, mis võimaldab hallata reisijate broneeringuid.

Tabel sisaldab:

* broneeringu ID
* reisija ID
* broneeringu kuupäeva
* staatust

### Tulemus

Lisa siia Broneering tabeli ekraanipilt.

![Booking](screenshots/booking.png)

---

# Kokkuvõte

Töö käigus loodi täielikult toimiv lennujaama andmebaas SQL Server keskkonnas. Realiseeriti tabelid, seosed, kasutajate õigused, triggerid, logimine, protseduurid, vaated ja lisafunktsionaalsus. Kõik nõutud ülesanded said edukalt täidetud.

