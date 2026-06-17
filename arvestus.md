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

Sisaldab lennujaamade andmeid.

### Tabel Lend

Sisaldab lendude andmeid.

### Tabel Reisija

Sisaldab reisijate andmeid.

### Tulemus

Lisa siia tabelite ekraanipilt.

![Tables](screenshots/tables.png)

---

# Testandmete lisamine

Pärast tabelite loomist lisati testandmed süsteemi töö kontrollimiseks.

Näiteks lisati:

* Tallinna Lennujaam
* Tartu Lennujaam
* Helsingi Lennujaam

ning mitu lendu ja reisijat.

### Tulemus

Lisa siia testandmete ekraanipilt.

![Data](screenshots/test_data.png)

---

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
```

---

# Triggerid

## INSERT Trigger

Trigger käivitub automaatselt pärast uue lennu lisamist tabelisse **Lend**.

Trigger salvestab:

* kasutaja
* kuupäeva
* tegevuse tüübi
* lisatud lennu andmed

### Tulemus

Lisa siia INSERT triggeri ekraanipilt.

![Insert Trigger](screenshots/insert_trigger.png)

---

## DELETE Trigger

Trigger käivitub automaatselt pärast lennu kustutamist.

Kustutatud lennu andmed salvestatakse tabelisse **Logi**.

### Tulemus

Lisa siia DELETE triggeri ekraanipilt.

![Delete Trigger](screenshots/delete_trigger.png)

---

# Salvestatud protseduurid

Loodi kolm protseduuri.

## LisaLennujaam

Lisab uue lennujaama.

## LisaLend

Lisab uue lennu.

## OtsiReisijaNimeJargi

Otsib reisijat nime järgi.

### Tulemus

Lisa siia protseduuride käivitamise ekraanipilt.

![Procedures](screenshots/procedures.png)

---

# Vaated

Loodi kolm vaadet.

## Vaade_Lennud_Lennujaamad

Kuvab lennud koos lennujaamade andmetega.

## Vaade_Reisijad_Lennud

Kuvab reisijad koos lendudega.

## Vaade_Reisijad_Lennujaamad

Kuvab reisijad, lennud ja lennujaamad ühes vaates.

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

