--CREARE TABELE

-- Tabel: HOTELURI
CREATE TABLE P_Hotel (
    id_hotel INT PRIMARY KEY,
    nume VARCHAR2(50),
    judet VARCHAR2(30),
    oras VARCHAR2(30),
    nr_etaje INT,
    camere_pe_etaj INT,
    nr_angajati INT
);
-- Tabel: CAMERE
CREATE TABLE P_Camera (
    id_camera INT PRIMARY KEY,
    numar INT,
    tip_camera VARCHAR2(30),
    etaj INT,
    balcon NUMBER(1,0) CHECK (balcon IN (0,1)),
    pret NUMBER(7,2),
    id_hotel INT,
    CONSTRAINT fk_camera_hotel FOREIGN KEY (id_hotel) REFERENCES P_Hotel(id_hotel)
);
--  Tabel: OBIECTE DE INVENTAR
CREATE TABLE P_Obiecte_inventar (
    id_obiect INT PRIMARY KEY,
    nume VARCHAR2(30),
    nr_bucati INT,
    id_camera INT,
    CONSTRAINT fk_inventar_camera FOREIGN KEY (id_camera) REFERENCES P_Camera(id_camera)
);
-- Tabel: CLIENTI
CREATE TABLE P_Client (
    id_client INT PRIMARY KEY,
    nume VARCHAR2(30),
    prenume VARCHAR2(40),
    telefon VARCHAR2(10),
    email VARCHAR2(50)
);
-- Tabel: DEPARTAMENTE 
CREATE TABLE P_Departament (
    id_departament INT PRIMARY KEY,
    nume VARCHAR2(40),
    id_departament_parinte INT,
    CONSTRAINT fk_dept_parinte FOREIGN KEY (id_departament_parinte) REFERENCES P_Departament(id_departament)
);
-- Tabel: P_Tipuri_Angajat
CREATE TABLE P_Tipuri_Angajati (
    id_tip INT PRIMARY KEY,
    denumire VARCHAR2(30),
    coeficient_salarial NUMBER(5,2)
);
--  Tabel: ANGAJATI
CREATE TABLE P_Angajat (
    id_angajat INT PRIMARY KEY,
    nume VARCHAR2(30),
    prenume VARCHAR2(40),
    telefon VARCHAR2(10),
    email VARCHAR2(50),
    data_ang DATE,
    salariul NUMBER(9,2),
    adresa VARCHAR2(100),
    id_hotel INT,
    id_departament INT,
    id_tip INT,
    id_manager INT,
    CONSTRAINT fk_ang_hotel FOREIGN KEY (id_hotel) REFERENCES P_Hotel(id_hotel),
    CONSTRAINT fk_ang_dept FOREIGN KEY (id_departament) REFERENCES P_Departament(id_departament),
    CONSTRAINT fk_ang_manager FOREIGN KEY (id_manager) REFERENCES P_Angajat(id_angajat)
);
--adaugare legatura angajat - tip angajat
ALTER TABLE P_Angajat
ADD CONSTRAINT fk_ang_tip FOREIGN KEY (id_tip)
REFERENCES P_Tipuri_Angajati(id_tip);
--  Tabel: REZERVARI
CREATE TABLE P_Rezervari (
    id_rezervare INT PRIMARY KEY,
    id_client INT,
    id_camera INT,
    id_angajat INT,
    data_check_in DATE,
    data_check_out DATE,
    status VARCHAR2(20),
    CONSTRAINT fk_rez_client FOREIGN KEY (id_client) REFERENCES P_Client(id_client),
    CONSTRAINT fk_rez_camera FOREIGN KEY (id_camera) REFERENCES P_Camera(id_camera),
    CONSTRAINT fk_rez_ang FOREIGN KEY (id_angajat) REFERENCES P_Angajat(id_angajat)
);
--  Tabel: SERVICII OFERITE
CREATE TABLE P_Servicii (
    id_serviciu INT PRIMARY KEY,
    denumire VARCHAR2(50),
    tarif NUMBER(7,2),
    durata_minute INT
);
--tabela de legatura dintre servicii si rezervare -> evit relatia many to many
--o rezervare poate avea mai multe servicii
--un serviciu poate fi oferit în mai multe rezervări
-- Tabel: SERVICII REZERVARI 
CREATE TABLE P_Servicii_Rezervari (
    id_rezervare INT,
    id_serviciu INT,
    cantitate INT,
    CONSTRAINT pk_sr PRIMARY KEY (id_rezervare, id_serviciu),
    CONSTRAINT fk_sr_rez FOREIGN KEY (id_rezervare) REFERENCES P_Rezervari(id_rezervare),
    CONSTRAINT fk_sr_serv FOREIGN KEY (id_serviciu) REFERENCES P_Servicii(id_serviciu)
);
-- Tabel: PLĂȚI
CREATE TABLE P_Plati (
    id_plata INT PRIMARY KEY,
    id_rezervare INT,
    data_plata DATE,
    suma NUMBER(10,2),
    metoda_plata VARCHAR2(20),
    CONSTRAINT fk_plata_rez FOREIGN KEY (id_rezervare) REFERENCES P_Rezervari(id_rezervare)
);
-- Tabel: RECENZII
CREATE TABLE P_Recenzii (
    id_recenzie INT PRIMARY KEY,
    nr_stele INT CHECK (nr_stele BETWEEN 1 AND 5),
    data_recenzie DATE,
    descriere VARCHAR2(200),
    id_client INT,
    id_rezervare INT,
    CONSTRAINT fk_rec_client FOREIGN KEY (id_client) REFERENCES P_Client(id_client),
    CONSTRAINT fk_rec_rez FOREIGN KEY (id_rezervare) REFERENCES P_Rezervari(id_rezervare)
);
--  Tabel: MATERIALE CONSUMABILE 
CREATE TABLE P_Materiale (
    id_material INT PRIMARY KEY,
    denumire VARCHAR2(50),
    stoc INT,
    unitate_masura VARCHAR2(10),
    pret_unitar NUMBER(8,2)
);
-- Tabel: CONSUM DE MATERIALE
CREATE TABLE P_Consum_Materiale (
    id_consum INT PRIMARY KEY,
    id_hotel INT,
    id_material INT,
    data_consum DATE,
    cantitate INT,
    CONSTRAINT fk_cons_hotel FOREIGN KEY (id_hotel) REFERENCES P_Hotel(id_hotel),
    CONSTRAINT fk_cons_mat FOREIGN KEY (id_material) REFERENCES P_Materiale(id_material)
);


--POPULARE TABELE

-- adaug datele in tebela P_Tipuri_Angajati
INSERT INTO P_Tipuri_Angajati VALUES (1, 'Manager General', 3.0);
INSERT INTO P_Tipuri_Angajati VALUES (2, 'Receptioner', 1.8);
INSERT INTO P_Tipuri_Angajati VALUES (3, 'Camerista', 1.2);
INSERT INTO P_Tipuri_Angajati VALUES (4, 'Bucatar', 2.0);
INSERT INTO P_Tipuri_Angajati VALUES (5, 'Personal Curatenie', 1.1);
INSERT INTO P_Tipuri_Angajati VALUES (6, 'Ajutor Bucatar', 1.0);
INSERT INTO P_Tipuri_Angajati VALUES (7, 'Ajutor Camerista', 0.9);
INSERT INTO P_Tipuri_Angajati VALUES (8, 'Ajutor Receptioner', 1.1);
-- adaug datele in tebela P_Departament
INSERT INTO P_Departament VALUES (1, 'Conducere', NULL);
INSERT INTO P_Departament VALUES (2, 'Receptie', 1);
INSERT INTO P_Departament VALUES (3, 'Curatenie', 1);
INSERT INTO P_Departament VALUES (4, 'Restaurant', 1);
INSERT INTO P_Departament VALUES (5, 'Mentenanta', 1);
--adaug datele in tebela P_Hotel
insert into P_Hotel(id_hotel, nume, judet, oras, nr_angajati)
values (1, 'Hotel Central Calimanesti', 'Valcea', 'Calimanesti', 89);
insert into P_Hotel(id_hotel, nume, judet, oras, nr_angajati)
values (2, 'Hotel Cozia', 'Valcea', 'Calimanesti', 193);
insert into P_Hotel(id_hotel, nume, judet, oras, nr_angajati)
values (3, 'Hotel Caciulata', 'Valcea', 'Calimanesti', 143);
insert into P_Hotel(id_hotel, nume, judet, oras, nr_angajati)
values (4, 'Hotel Oltul', 'Valcea', 'Calimanesti', 155);
--adaug datele in tebela P_Camera
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (104, 4, 'double', 1, 0, 300, 1);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (319, 19, 'family', 3, 1, 450, 1);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (1020, 20, 'single', 5, 0, 150, 2);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (1325, 25, 'double', 8, 0, 300, 2);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (1522, 22, 'family', 2, 1, 450, 3);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (1909, 9, 'single', 6, 1, 150, 3);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (2412, 12, 'single', 4, 1, 150, 4);
insert into p_Camera(id_camera, numar, tip_camera, etaj, balcon, pret, id_hotel)
values (2721, 21, 'double', 7, 0, 300, 4);
INSERT INTO P_Camera VALUES (105, 5, 'single', 1, 1, 180, 1);
INSERT INTO P_Camera VALUES (107, 7, 'double', 1, 0, 300, 1);
INSERT INTO P_Camera VALUES (2215, 15, 'family', 2, 1, 480, 1);
INSERT INTO P_Camera VALUES (3105, 5, 'single', 3, 0, 170, 1);
INSERT INTO P_Camera VALUES (509, 9, 'double', 5, 1, 310, 1);
INSERT INTO P_Camera VALUES (1021, 21, 'single', 6, 0, 160, 2);
INSERT INTO P_Camera VALUES (1224, 24, 'family', 8, 1, 470, 2);
INSERT INTO P_Camera VALUES (115, 15, 'double', 2, 0, 290, 2);
INSERT INTO P_Camera VALUES (1012, 12, 'single', 4, 1, 150, 2);
INSERT INTO P_Camera VALUES (1123, 23, 'double', 7, 0, 310, 2);
INSERT INTO P_Camera VALUES (1505, 5, 'single', 1, 0, 160, 3);
INSERT INTO P_Camera VALUES (1610, 10, 'family', 4, 1, 480, 3);
INSERT INTO P_Camera VALUES (1715, 15, 'double', 5, 0, 290, 3);
INSERT INTO P_Camera VALUES (1820, 20, 'family', 6, 1, 460, 3);
INSERT INTO P_Camera VALUES (1917, 17, 'single', 7, 0, 150, 3);
--adaug datele in tabela P_Obiecte_inventar
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (1104, 'masa', 1, 104);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (2319, 'scaun', 4, 319);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (31020, 'pat', 1, 1020);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (21325, 'scaun', 2, 1325);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (31522, 'pat', 3, 1522);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (11909, 'masa', 1, 1909);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (22412, 'scaun', 1, 2412);
insert into p_Obiecte_inventar(id_obiect, nume, nr_bucati, id_camera)
values (32721, 'pat', 2, 2721);
INSERT INTO P_Obiecte_inventar VALUES (1105, 'masa', 1, 105);
INSERT INTO P_Obiecte_inventar VALUES (2105, 'scaun', 2, 105);
INSERT INTO P_Obiecte_inventar VALUES (3105, 'pat', 1, 105);
INSERT INTO P_Obiecte_inventar VALUES (12215, 'masa', 1, 2215);
INSERT INTO P_Obiecte_inventar VALUES (22215, 'scaun', 4, 2215);
INSERT INTO P_Obiecte_inventar VALUES (32215, 'pat', 2, 2215);
INSERT INTO P_Obiecte_inventar VALUES (1115, 'masa', 1, 115);
INSERT INTO P_Obiecte_inventar VALUES (2115, 'scaun', 3, 115);
INSERT INTO P_Obiecte_inventar VALUES (3115, 'pat', 1, 115);
INSERT INTO P_Obiecte_inventar VALUES (11505, 'masa', 1, 1505);
INSERT INTO P_Obiecte_inventar VALUES (21505, 'scaun', 2, 1505);
INSERT INTO P_Obiecte_inventar VALUES (31505, 'pat', 1, 1505);
INSERT INTO P_Obiecte_inventar VALUES (11820, 'masa', 1, 1820);
INSERT INTO P_Obiecte_inventar VALUES (21820, 'scaun', 4, 1820);
INSERT INTO P_Obiecte_inventar VALUES (31820, 'pat', 3, 1820);
--adaug datele in tabela P_Client
insert into P_Client(id_client, nume, prenume, telefon, email)
values(1, 'Popescu', 'Cosmin-Andrei', '0754237819', 'popescucosmin@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(2, 'Neacsu', 'David-Andrei', '0789094452', 'neacsudavid@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(3, 'Trascau', 'Teodor-Bogdan', '0734556789', 'trascaubogdan@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(4, 'Ghiur', 'Stefan-Daniel', '0767892310', 'ghiurdaniel@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(5, 'Heghiu', 'Ionut-Alexandru','0734267899', 'hegiuionut@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(6, 'Simionescu', 'Mihai-Alin', '0756781234', 'simionescualin@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(7, 'Dinita', 'Cosmina-Niccola', '0789553314', 'dinitacosmina@gmail.com');
insert into P_Client(id_client, nume, prenume, telefon, email)
values(8, 'Badea', 'Ionut-Gabriel', '0767906641', 'badeaionut@gmail.com');
INSERT INTO P_Client VALUES (9, 'Radu', 'Ion', '0761231111', 'raduion@gmail.com');
INSERT INTO P_Client VALUES (10, 'Popa', 'Laura', '0745667899', 'popalaura@gmail.com');
INSERT INTO P_Client VALUES (11, 'Ilie', 'Robert', '0734111122', 'ilierobert@gmail.com');
INSERT INTO P_Client VALUES (12, 'Preda', 'Marian', '0767332255', 'predamarian@gmail.com');
INSERT INTO P_Client VALUES (13, 'Lazar', 'Florin', '0734233455', 'lazarflorin@gmail.com');
INSERT INTO P_Client VALUES (14, 'Pavel', 'Andreea', '0789223344', 'pavelandreea@gmail.com');
INSERT INTO P_Client VALUES (15, 'Costache', 'George', '0755990099', 'costachegeorge@gmail.com');
INSERT INTO P_Client VALUES (16, 'Tudor', 'Ioana', '0745784567', 'tudorioana@gmail.com');
INSERT INTO P_Client VALUES (17, 'Manole', 'Cristian', '0734777788', 'manolecristian@gmail.com');
INSERT INTO P_Client VALUES (18, 'Matei', 'Raluca', '0734223344', 'mateiraluca@gmail.com');
INSERT INTO P_Client VALUES (19, 'Zamfir', 'Alexandru', '0789334444', 'zamfiralex@gmail.com');
INSERT INTO P_Client VALUES (20, 'Stoica', 'Madalina', '0765333333', 'stoicamada@gmail.com');
INSERT INTO P_Client VALUES (21, 'Iacob', 'Mihnea', '0734556677', 'iacobmihnea@gmail.com');
INSERT INTO P_Client VALUES (22, 'Georgescu', 'Elena', '0755223344', 'georgescuelena@gmail.com');
INSERT INTO P_Client VALUES (23, 'Oprea', 'Daniel', '0789445566', 'opreadaniel@gmail.com');
--adaug datele in tebela P_Angajat
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (111, 'Ionescu', 'Mihai', '0712341234', 'ionescumihai@gmail.com',
        TO_DATE('2020-12-06', 'YYYY-MM-DD'), 2500, 'Jiblea',
        1, 1, 1, NULL); 
-- Manager general Hotel 1
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (112, 'Petre', 'Mario-Alexandru', '0712344434', 'petremario@gmail.com',
        TO_DATE('2019-07-07', 'YYYY-MM-DD'), 4500, 'Calimanesti',
        1, 2, 2, 111);
-- Receptioner, subordonat lui Ionescu Mihai (hotel 1)
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (211, 'Simion', 'Andrei', '0734890766', 'simionandrei@gmail.com',
        TO_DATE('2021-02-20', 'YYYY-MM-DD'), 2900, 'Salatrucel',
        2, 2, 2, NULL);
-- Receptioner Hotel 2 (manager direct pentru angajatii hotelului 2)
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (212, 'Mihai', 'Gabriel', '0752371211', 'mihaigabriel@gmail.com',
        TO_DATE('2010-03-19', 'YYYY-MM-DD'), 4000, 'Radacinesti',
        2, 4, 4, 211);
-- Bucătar subordonat lui Simion Andrei
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (311, 'Spulber', 'Adrian', '0734890099', 'spulberadrian@gmail.com',
        TO_DATE('2022-11-10', 'YYYY-MM-DD'), 4100, 'Focsani',
        3, 2, 2, NULL);
-- Receptioner Hotel 3
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (312, 'Nicu', 'Razvan', '0767332416', 'nicurazvan@gmail.com',
        TO_DATE('2019-08-06', 'YYYY-MM-DD'), 2200, 'Calimanesti',
        3, 3, 3, 311);
-- Camerist subordonat lui Spulber Adrian
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (411, 'Florescu', 'Dragomir', '0789554433', 'florescudragomir@gmail.com',
        TO_DATE('2020-05-01', 'YYYY-MM-DD'), 2900, 'Jiblea',
        4, 4, 4, NULL);
-- Bucătar Hotel 4
INSERT INTO P_Angajat (
    id_angajat, nume, prenume, telefon, email, data_ang, salariul, adresa,
    id_hotel, id_departament, id_tip, id_manager
)
VALUES (412, 'Simionescu', 'Vasile', '0789095632', 'simionescuvasile@gmail.com',
        TO_DATE('2000-12-12', 'YYYY-MM-DD'), 3800, 'Calimanesti',
        4, 5, 5, 411);
-- Personal curățenie subordonat lui Florescu Dragomir
INSERT INTO P_Angajat VALUES (113, 'Dinu', 'Andrei', '0712349988', 'dinuandrei@gmail.com', TO_DATE('2021-01-10','YYYY-MM-DD'), 2400, 'Jiblea', 1, 3, 3, 111);
INSERT INTO P_Angajat VALUES (114, 'Marinescu', 'Alina', '0723459988', 'marinescualina@gmail.com', TO_DATE('2022-02-02','YYYY-MM-DD'), 2000, 'Calimanesti', 1, 5, 5, 111);
INSERT INTO P_Angajat VALUES (115, 'Cristea', 'Vlad', '0734999988', 'cristeavlad@gmail.com', TO_DATE('2020-03-03','YYYY-MM-DD'), 3100, 'Calimanesti', 1, 4, 4, 111);
INSERT INTO P_Angajat VALUES (213, 'Iordache', 'Roxana', '0755123789', 'iordacherox@gmail.com', TO_DATE('2020-06-06','YYYY-MM-DD'), 2100, 'Cozia', 2, 3, 3, 211);
INSERT INTO P_Angajat VALUES (214, 'Dobre', 'Vasile', '0755337899', 'dobrevasile@gmail.com', TO_DATE('2019-05-09','YYYY-MM-DD'), 2300, 'Cozia', 2, 5, 5, 211);
INSERT INTO P_Angajat VALUES (313, 'Enache', 'Maria', '0734111122', 'enachemaria@gmail.com', TO_DATE('2023-02-01','YYYY-MM-DD'), 2400, 'Calimanesti', 3, 3, 3, 311);
INSERT INTO P_Angajat VALUES (314, 'Neagu', 'Cristina', '0755001122', 'neagucristina@gmail.com', TO_DATE('2018-11-10','YYYY-MM-DD'), 2600, 'Calimanesti', 3, 5, 5, 311);
INSERT INTO P_Angajat VALUES (413, 'Marin', 'Alexandra', '0789551212', 'marinalexandra@gmail.com', TO_DATE('2017-10-01','YYYY-MM-DD'), 2400, 'Jiblea', 4, 3, 3, 411);
INSERT INTO P_Angajat VALUES (414, 'Dragomir', 'Paul', '0789551213', 'dragomirpaul@gmail.com', TO_DATE('2022-08-11','YYYY-MM-DD'), 2100, 'Calimanesti', 4, 5, 5, 411);
INSERT INTO P_Angajat VALUES (
    116, 'Stan', 'Ioana', '0734561234', 'stanioana@gmail.com',
    TO_DATE('2023-03-10', 'YYYY-MM-DD'), 1800, 'Calimanesti',
    1, 2, 8, 112
);

-- Subordonat lui Cristea Vlad (Bucătar)
INSERT INTO P_Angajat VALUES (
    117, 'Dumitru', 'Alin', '0756341234', 'dumitrualin@gmail.com',
    TO_DATE('2023-07-12', 'YYYY-MM-DD'), 1700, 'Calimanesti',
    1, 4, 6, 115
);

-- Subordonat lui Marinescu Alina (Cameristă)
INSERT INTO P_Angajat VALUES (
    118, 'Pop', 'Elena', '0767345678', 'popelena@gmail.com',
    TO_DATE('2023-05-05', 'YYYY-MM-DD'), 1600, 'Calimanesti',
    1, 3, 7, 114
);
-- Subordonat lui Mihai Gabriel (Bucătar)
INSERT INTO P_Angajat VALUES (
    215, 'Barbu', 'Stefania', '0767771234', 'barbustefania@gmail.com',
    TO_DATE('2020-04-15','YYYY-MM-DD'), 1750, 'Cozia',
    2, 4, 6, 212
);

-- Subordonat lui Iordache Roxana (Cameristă)
INSERT INTO P_Angajat VALUES (
    216, 'Matei', 'Carmen', '0756555432', 'mateicarmen@gmail.com',
    TO_DATE('2023-09-20', 'YYYY-MM-DD'), 1600, 'Cozia',
    2, 3, 7, 213
);

-- Subordonat lui Simion Andrei (Receptioner)
INSERT INTO P_Angajat VALUES (
    217, 'Iliescu', 'Robert', '0789551122', 'iliescurobert@gmail.com',
    TO_DATE('2022-01-10', 'YYYY-MM-DD'), 1800, 'Cozia',
    2, 2, 8, 211
);
INSERT INTO P_Angajat VALUES (
    315, 'Predoiu', 'Teodora', '0756112233', 'predoiuteodora@gmail.com',
    TO_DATE('2023-06-01', 'YYYY-MM-DD'), 1600, 'Calimanesti',
    3, 3, 7, 312
);

-- Subordonat lui Enache Maria (Cameristă)
INSERT INTO P_Angajat VALUES (
    316, 'Stoica', 'Diana', '0756332244', 'stoicadiana@gmail.com',
    TO_DATE('2023-07-14', 'YYYY-MM-DD'), 1650, 'Calimanesti',
    3, 3, 7, 313
);

-- Subordonat lui Spulber Adrian (Receptioner)
INSERT INTO P_Angajat VALUES (
    317, 'Lazar', 'Ionut', '0766222233', 'lazarionut@gmail.com',
    TO_DATE('2022-02-02', 'YYYY-MM-DD'), 1850, 'Calimanesti',
    3, 2, 8, 311
);
INSERT INTO P_Angajat VALUES (
    415, 'Toma', 'Irina', '0789223456', 'tomairina@gmail.com',
    TO_DATE('2021-03-22','YYYY-MM-DD'), 1700, 'Calimanesti',
    4, 3, 7, 412
);

-- Subordonat lui Dragomir Paul (Curățenie)
INSERT INTO P_Angajat VALUES (
    416, 'Sandu', 'Marius', '0789444567', 'sandumarius@gmail.com',
    TO_DATE('2020-06-13','YYYY-MM-DD'), 1600, 'Calimanesti',
    4, 5, 5, 414
);

-- Subordonat lui Florescu Dragomir (Manager General)
INSERT INTO P_Angajat VALUES (
    417, 'Nastase', 'Andreea', '0789226677', 'nastaseandreea@gmail.com',
    TO_DATE('2023-08-08','YYYY-MM-DD'), 1750, 'Calimanesti',
    4, 2, 8, 411
);
--adaug datele in tabela P_Rezervari
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1111, 1, 104, 111,to_date(trim('2022-07-22'), 'YYYY-MM-DD'), to_date(trim('2022-07-27'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1112, 2, 319, 112,to_date(trim('2022-08-20'), 'YYYY-MM-DD'), to_date(trim('2022-08-25'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1113, 3, 1020, 211,to_date(trim('2021-01-21'), 'YYYY-MM-DD'), to_date(trim('2021-01-29'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1114, 4, 1325, 212,to_date(trim('2023-07-22'), 'YYYY-MM-DD'), to_date(trim('2023-07-28'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1115, 5, 1522, 311,to_date(trim('2023-07-27'), 'YYYY-MM-DD'), to_date(trim('2023-08-02'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1116, 6, 1909, 312,to_date(trim('2023-08-01'), 'YYYY-MM-DD'), to_date(trim('2023-08-09'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1117, 7, 2412, 411,to_date(trim('2023-09-09'), 'YYYY-MM-DD'), to_date(trim('2023-09-14'), 'YYYY-MM-DD'));
insert into P_Rezervari(id_rezervare, id_client, id_camera, id_angajat, data_check_in, data_check_out)
values(1118, 8, 2721, 412,to_date(trim('2023-10-02'), 'YYYY-MM-DD'), to_date(trim('2023-10-10'), 'YYYY-MM-DD'));
INSERT INTO P_Rezervari VALUES (1119, 9, 105, 112, TO_DATE('2023-10-15','YYYY-MM-DD'), TO_DATE('2023-10-20','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1120, 10, 2215, 112, TO_DATE('2023-08-10','YYYY-MM-DD'), TO_DATE('2023-08-16','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1121, 11, 1021, 211, TO_DATE('2023-09-01','YYYY-MM-DD'), TO_DATE('2023-09-07','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1122, 12, 1610, 311, TO_DATE('2023-07-05','YYYY-MM-DD'), TO_DATE('2023-07-11','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1123, 13, 1715, 311, TO_DATE('2023-06-10','YYYY-MM-DD'), TO_DATE('2023-06-15','YYYY-MM-DD'), 'anulata');
INSERT INTO P_Rezervari VALUES (1124, 14, 1917, 312, TO_DATE('2023-05-02','YYYY-MM-DD'), TO_DATE('2023-05-06','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1125, 15, 115, 211, TO_DATE('2023-03-11','YYYY-MM-DD'), TO_DATE('2023-03-17','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1126, 16, 1123, 211, TO_DATE('2023-03-20','YYYY-MM-DD'), TO_DATE('2023-03-26','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1127, 17, 1820, 311, TO_DATE('2023-04-10','YYYY-MM-DD'), TO_DATE('2023-04-15','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1128, 18, 1505, 312, TO_DATE('2023-06-22','YYYY-MM-DD'), TO_DATE('2023-06-28','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1129, 19, 509, 112, TO_DATE('2023-09-02','YYYY-MM-DD'), TO_DATE('2023-09-09','YYYY-MM-DD'), 'finalizata');
INSERT INTO P_Rezervari VALUES (1130, 20, 1224, 212, TO_DATE('2023-09-18','YYYY-MM-DD'), TO_DATE('2023-09-25','YYYY-MM-DD'), 'finalizata');
--adaug datele in tabela P_Recenzii
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11111, 4, to_date(trim('2022-07-28'), 'YYYY-MM-DD'), 'foarte multumit', 1, 1111);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11112, 2, to_date(trim('2022-08-26'), 'YYYY-MM-DD'), 'slab', 2, 1112);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11113, 1, to_date(trim('2021-01-30'), 'YYYY-MM-DD'), 'foarte slab', 3, 1113);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11114, 3, to_date(trim('2023-07-29'), 'YYYY-MM-DD'), 'multumit', 4, 1114);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11115, 3, to_date(trim('2023-08-03'), 'YYYY-MM-DD'), 'multumit', 5, 1115);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11116, 1, to_date(trim('2023-08-10'), 'YYYY-MM-DD'), 'foarte slab', 6, 1116);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11117, 4, to_date(trim('2021-10-11'), 'YYYY-MM-DD'), 'foarte multumit', 7, 1117);
insert into P_Recenzii(id_recenzie, nr_stele, data_recenzie, descriere, id_client, id_rezervare)
values(11118, 4, to_date(trim('2023-10-11'), 'YYYY-MM-DD'), 'foarte multumit', 8, 1118);
INSERT INTO P_Recenzii VALUES (11119, 4, TO_DATE('2023-10-21','YYYY-MM-DD'), 'foarte multumit', 9, 1119);
INSERT INTO P_Recenzii VALUES (11120, 3, TO_DATE('2023-08-17','YYYY-MM-DD'), 'multumit', 10, 1120);
INSERT INTO P_Recenzii VALUES (11121, 2, TO_DATE('2023-09-08','YYYY-MM-DD'), 'slab', 11, 1121);
INSERT INTO P_Recenzii VALUES (11122, 4, TO_DATE('2023-07-12','YYYY-MM-DD'), 'foarte multumit', 12, 1122);
INSERT INTO P_Recenzii VALUES (11123, 1, TO_DATE('2023-06-16','YYYY-MM-DD'), 'foarte slab', 13, 1123);
INSERT INTO P_Recenzii VALUES (11124, 3, TO_DATE('2023-05-07','YYYY-MM-DD'), 'multumit', 14, 1124);
INSERT INTO P_Recenzii VALUES (11125, 4, TO_DATE('2023-03-18','YYYY-MM-DD'), 'foarte multumit', 15, 1125);
INSERT INTO P_Recenzii VALUES (11126, 2, TO_DATE('2023-03-27','YYYY-MM-DD'), 'slab', 16, 1126);
INSERT INTO P_Recenzii VALUES (11127, 4, TO_DATE('2023-04-16','YYYY-MM-DD'), 'foarte multumit', 17, 1127);
INSERT INTO P_Recenzii VALUES (11128, 3, TO_DATE('2023-06-29','YYYY-MM-DD'), 'multumit', 18, 1128);
--adaug datele in tabela P_Servicii
INSERT INTO P_Servicii VALUES (1, 'Room Service', 50, 30);
INSERT INTO P_Servicii VALUES (2, 'Spa & Wellness', 200, 90);
INSERT INTO P_Servicii VALUES (3, 'Piscina Interioara', 80, 60);
INSERT INTO P_Servicii VALUES (4, 'Mic Dejun Inclus', 40, 45);
INSERT INTO P_Servicii VALUES (5, 'Masaj Relaxare', 150, 60);
--adaug datele in tabela P_Servicii_Rezervari
INSERT INTO P_Servicii_Rezervari VALUES (1111, 1, 1); -- room service
INSERT INTO P_Servicii_Rezervari VALUES (1111, 4, 2); -- mic dejun
INSERT INTO P_Servicii_Rezervari VALUES (1112, 2, 1); -- spa
INSERT INTO P_Servicii_Rezervari VALUES (1113, 4, 1); -- mic dejun
INSERT INTO P_Servicii_Rezervari VALUES (1114, 3, 1); -- piscina
INSERT INTO P_Servicii_Rezervari VALUES (1115, 1, 2); -- room service
INSERT INTO P_Servicii_Rezervari VALUES (1116, 5, 1); -- masaj
INSERT INTO P_Servicii_Rezervari VALUES (1118, 2, 1); -- spa
--adaug datele in tabela P_Plăti
INSERT INTO P_Plati VALUES (1, 1111, TO_DATE('2022-07-27', 'YYYY-MM-DD'), 1500, 'Card');
INSERT INTO P_Plati VALUES (2, 1112, TO_DATE('2022-08-25', 'YYYY-MM-DD'), 2200, 'Cash');
INSERT INTO P_Plati VALUES (3, 1113, TO_DATE('2021-01-29', 'YYYY-MM-DD'), 1200, 'Transfer');
INSERT INTO P_Plati VALUES (4, 1114, TO_DATE('2023-07-28', 'YYYY-MM-DD'), 2100, 'Card');
INSERT INTO P_Plati VALUES (5, 1115, TO_DATE('2023-08-02', 'YYYY-MM-DD'), 2500, 'Card');
INSERT INTO P_Plati VALUES (6, 1116, TO_DATE('2023-08-09', 'YYYY-MM-DD'), 1700, 'Cash');
INSERT INTO P_Plati VALUES (7, 1117, TO_DATE('2023-09-14', 'YYYY-MM-DD'), 2400, 'Transfer');
INSERT INTO P_Plati VALUES (8, 1118, TO_DATE('2023-10-10', 'YYYY-MM-DD'), 2600, 'Card');
INSERT INTO P_Plati VALUES (9, 1119, TO_DATE('2023-10-20','YYYY-MM-DD'), 1600, 'Card');
INSERT INTO P_Plati VALUES (10, 1120, TO_DATE('2023-08-16','YYYY-MM-DD'), 1800, 'Transfer');
INSERT INTO P_Plati VALUES (11, 1121, TO_DATE('2023-09-07','YYYY-MM-DD'), 1400, 'Cash');
INSERT INTO P_Plati VALUES (12, 1122, TO_DATE('2023-07-11','YYYY-MM-DD'), 1700, 'Card');
INSERT INTO P_Plati VALUES (13, 1123, TO_DATE('2023-06-15','YYYY-MM-DD'), 0, 'Anulata');
INSERT INTO P_Plati VALUES (14, 1124, TO_DATE('2023-05-06','YYYY-MM-DD'), 1200, 'Card');
INSERT INTO P_Plati VALUES (15, 1125, TO_DATE('2023-03-17','YYYY-MM-DD'), 2000, 'Card');
INSERT INTO P_Plati VALUES (16, 1126, TO_DATE('2023-03-26','YYYY-MM-DD'), 2100, 'Transfer');
INSERT INTO P_Plati VALUES (17, 1127, TO_DATE('2023-04-15','YYYY-MM-DD'), 2300, 'Card');
INSERT INTO P_Plati VALUES (18, 1128, TO_DATE('2023-06-28','YYYY-MM-DD'), 1500, 'Cash');
--adaug datele in tabela P_Materiale
INSERT INTO P_Materiale VALUES (1, 'Detergent Curatenie', 100, 'litri', 15);
INSERT INTO P_Materiale VALUES (2, 'Lenjerii', 200, 'buc', 80);
INSERT INTO P_Materiale VALUES (3, 'Prosoape', 300, 'buc', 25);
INSERT INTO P_Materiale VALUES (4, 'Sapun', 500, 'buc', 3);
INSERT INTO P_Materiale VALUES (5, 'Hartie igienica', 1000, 'buc', 2);
--adaug datele in tabela P_Consum_Materiale
INSERT INTO P_Consum_Materiale VALUES (1, 1, 1, TO_DATE('2023-07-01', 'YYYY-MM-DD'), 10);
INSERT INTO P_Consum_Materiale VALUES (2, 1, 3, TO_DATE('2023-07-02', 'YYYY-MM-DD'), 15);
INSERT INTO P_Consum_Materiale VALUES (3, 2, 2, TO_DATE('2023-07-03', 'YYYY-MM-DD'), 20);
INSERT INTO P_Consum_Materiale VALUES (4, 3, 5, TO_DATE('2023-07-04', 'YYYY-MM-DD'), 50);
INSERT INTO P_Consum_Materiale VALUES (5, 4, 1, TO_DATE('2023-07-05', 'YYYY-MM-DD'), 5);
INSERT INTO P_Consum_Materiale VALUES (6, 1, 2, TO_DATE('2023-08-01','YYYY-MM-DD'), 12);
INSERT INTO P_Consum_Materiale VALUES (7, 2, 3, TO_DATE('2023-08-02','YYYY-MM-DD'), 25);
INSERT INTO P_Consum_Materiale VALUES (8, 3, 4, TO_DATE('2023-08-03','YYYY-MM-DD'), 60);
INSERT INTO P_Consum_Materiale VALUES (9, 4, 5, TO_DATE('2023-08-04','YYYY-MM-DD'), 80);
INSERT INTO P_Consum_Materiale VALUES (10, 4, 2, TO_DATE('2023-08-05','YYYY-MM-DD'), 20);
