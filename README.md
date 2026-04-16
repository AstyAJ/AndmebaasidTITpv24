# AndmebaasidTITpv24
andmebaasidega seotud SQL kood ja konspektid
## Põhimõisted
- andmebaas - struktureeritud andmete kogum
- tabel = olem - сущность - entity
- veerg = väli - поле/столбец
- rida = kirje - записи
- andmebaasi haldussüstem - tarkvara, millega abil saab luua andmebaas: mariaDB / XAMPP, SQL SERVER management Studio.
  <img width="235" height="250" alt="{2A2F7640-C635-4C0F-A942-3CFA0268669E}" src="https://github.com/user-attachments/assets/c9d10a01-6d07-435e-be61-24f2d0b821d7" />

- primaarne võti - PRIMARY KEY - veerg(tavaliselt id nimega), unikaalne identifikaator, mis eristab iga kirje.
- välisvõti - FOREIGN KEY -FK- veerg, mis loob seos teise tabeli primaarvõtmega.
- päring - QUERY - запрос
- 
## Andmetüübid
```
1. Numbrilised: INT, SmallINT, float, decimal(5,2)
2. Tekst/sümbolised: varchar(255), char (5), TEXT
3. Loogilised: boolean, true/false, bit, bool
4. Kuupäeva: date, time, datetime
```
## SQL - structure Query Language - struktureeritud päringu keel
- Tabeli loomine
```sql
--tabeli loomine
CREATE TABLE opilane(
opilaneID int Primary Key identity(1,1),--automaatselt täidab numbritega
eesnimi varchar(25),
perenimi varchar(30) NOT NULL,
synniaeg DATE,
stip bit,
mobiil varchar(13),
aadress TEXT,
keskmineHinne decimal(2,1)); --(2--kokku, 1--peale komat nt 4.5)
```
- Tabeli avamine
```
SELECT * FROM opilane;
```
- Andmete sisestamine tabelisse
```sql
--tabeli täitmine
INSERT INTO opilane
VALUES ('Artjom','Jegorov', '2003-04-11',1,'+37258322805','Tallinn', 4.5)

INSERT INTO opilane(perenimi, eesnimi, keskmineHinne)
VALUES ('Kulberg', 'Marek', 4.9),
('Kuzmin', 'Aleksei', 5.0),
('Jegorov', 'Ruslan', 3.2),
('Filin', 'Dmitri', 4.1);
```

