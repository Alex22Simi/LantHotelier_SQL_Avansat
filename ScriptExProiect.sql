--3. CERERI IERARHICE
-- STRUCTURA ORGANIGRAMEI (TOP-DOWN)
--4 organigrame(arbori) pt fiecare hotel in parte
SELECT 
    LPAD(' ', LEVEL * 3) || a.nume || ' ' || a.prenume AS structura_angajati,
    a.id_angajat,
    a.id_manager,
    t.denumire AS functie,
    d.nume AS departament,
    h.nume AS hotel,
    LEVEL AS nivel_ierarhic
FROM P_Angajat a
JOIN P_Tipuri_Angajati t ON a.id_tip = t.id_tip
JOIN P_Departament d ON a.id_departament = d.id_departament
JOIN P_Hotel h ON a.id_hotel = h.id_hotel
START WITH a.id_manager IS NULL
CONNECT BY PRIOR a.id_angajat = a.id_manager
ORDER SIBLINGS BY a.nume;

--  IERARHIE DE SUS IN JOS (BOTTOM-UP)
SELECT 
    LEVEL AS nivel_ierarhic,
    CONNECT_BY_ROOT a.nume || ' ' || CONNECT_BY_ROOT a.prenume AS angajat_initial,
    a.nume || ' ' || a.prenume AS superior,
    t.denumire AS functie
FROM P_Angajat a
JOIN P_Tipuri_Angajati t ON a.id_tip = t.id_tip
CONNECT BY PRIOR a.id_manager = a.id_angajat
START WITH a.nume = 'Simionescu' AND a.prenume = 'Vasile';


-- CALEA COMPLETĂ DE LA MANAGER GENERAL LA SUBORDONAT
SELECT 
    a.id_angajat,
    a.nume || ' ' || a.prenume AS angajat,
    SYS_CONNECT_BY_PATH(a.nume || ' ' || a.prenume, ' → ') AS cale_ierarhica,
    LEVEL - 1 AS nr_sefi
FROM P_Angajat a
CONNECT BY PRIOR a.id_angajat = a.id_manager
START WITH a.id_manager IS NULL
ORDER BY cale_ierarhica;


--SUBORDONAȚII CARE AU ACEEAȘI ARIE FUNCȚIONALĂ CA MANAGERUL
SELECT *
FROM (
    SELECT 
        a.nume || ' ' || a.prenume AS angajat,
        CONNECT_BY_ROOT (a.nume || ' ' || a.prenume) AS manager_general,
        d.nume AS departament,
        CONNECT_BY_ROOT d.nume AS departament_manager,
        LEVEL AS nivel_ierarhic
    FROM P_Angajat a
    JOIN P_Departament d ON a.id_departament = d.id_departament
    CONNECT BY PRIOR a.id_angajat = a.id_manager
    START WITH a.id_manager IS NULL
)
WHERE departament = departament_manager;


--SUBORDONAȚII ÎNCEPÂND DE LA NIVELUL 2 + FUNCȚIE ANALITICĂ
SELECT *
FROM (
    SELECT 
        LEVEL AS nivel_ierarhic,
        a.nume || ' ' || a.prenume AS angajat,
        a.salariul,
        ROUND(AVG(a.salariul) OVER (PARTITION BY LEVEL), 2) AS salariu_mediu_pe_nivel
    FROM P_Angajat a
    CONNECT BY PRIOR a.id_angajat = a.id_manager
    START WITH a.id_manager IS NULL
)
WHERE nivel_ierarhic >= 2
ORDER BY nivel_ierarhic;


--EX 4 
-- interogări cu diverse tipuri de joncțiuni, subcereri, agregări (utilizate împreună, în scopul îndeplinirii de cerințe complexe)

-- Să se afișeze numărul de rezervări și venitul total obținut din plăți pentru fiecare hotel, ordonat descrescător după suma totală încasată.
SELECT 
    h.nume AS hotel,
    COUNT(r.id_rezervare) AS nr_rezervari,
    NVL(SUM(p.suma), 0) AS venit_total
FROM P_Hotel h
JOIN P_Camera c ON h.id_hotel = c.id_hotel
JOIN P_Rezervari r ON c.id_camera = r.id_camera
LEFT JOIN P_Plati p ON r.id_rezervare = p.id_rezervare
GROUP BY h.nume
ORDER BY venit_total DESC;


-- Să se afișeze clienții care au cheltuit peste media totală a tuturor clienților.
SELECT 
    c.nume || ' ' || c.prenume AS client,
    SUM(p.suma) AS total_cheltuit
FROM P_Client c
JOIN P_Rezervari r ON c.id_client = r.id_client
JOIN P_Plati p ON r.id_rezervare = p.id_rezervare
GROUP BY c.nume, c.prenume
HAVING SUM(p.suma) > (
    SELECT AVG(SUM(p2.suma))
    FROM P_Plati p2
    JOIN P_Rezervari r2 ON p2.id_rezervare = r2.id_rezervare
    GROUP BY r2.id_client
)
ORDER BY total_cheltuit DESC;


-- Să se afișeze angajatul sau angajații care au procesat cel mai mare număr de rezervări.
SELECT 
    a.nume || ' ' || a.prenume AS angajat,
    COUNT(r.id_rezervare) AS nr_rezervari
FROM P_Angajat a
JOIN P_Rezervari r ON a.id_angajat = r.id_angajat
GROUP BY a.nume, a.prenume
HAVING COUNT(r.id_rezervare) = (
    SELECT MAX(COUNT(r2.id_rezervare))
    FROM P_Rezervari r2
    GROUP BY r2.id_angajat
);

--Să se afișeze serviciile oferite (ex: SPA, room service etc.), numărul de utilizări și venitul generat de fiecare, în ordine descrescătoare după venit.
SELECT 
    s.denumire AS serviciu,
    COUNT(sr.id_rezervare) AS nr_utilizari,
    SUM(s.tarif * sr.cantitate) AS venit_total
FROM P_Servicii s
JOIN P_Servicii_Rezervari sr ON s.id_serviciu = sr.id_serviciu
GROUP BY s.denumire
HAVING SUM(s.tarif * sr.cantitate) > 0
ORDER BY venit_total DESC;


--Să se afișeze primele 3 hoteluri cu cel mai mare număr de clienți unici.
SELECT *
FROM (
    SELECT 
        h.nume AS hotel,
        COUNT(DISTINCT r.id_client) AS clienti_unici
    FROM P_Hotel h
    JOIN P_Camera c ON h.id_hotel = c.id_hotel
    JOIN P_Rezervari r ON c.id_camera = r.id_camera
    GROUP BY h.nume
    ORDER BY clienti_unici DESC
)
WHERE ROWNUM <= 3;


--Să se afișeze angajații care au un salariu peste media hotelului în care lucrează, împreună cu:
--numele hotelului și al departamentului,
--salariul lor,
--salariul maxim din departamentul respectiv,
--și salariul minim din hotel.
SELECT 
    a.nume || ' ' || a.prenume AS angajat,
    d.nume AS departament,
    h.nume AS hotel,
    a.salariul,
    (SELECT MAX(a2.salariul)
     FROM P_Angajat a2
     WHERE a2.id_departament = a.id_departament) AS salariul_maxim_departament,
    (SELECT MIN(a3.salariul)
     FROM P_Angajat a3
     WHERE a3.id_hotel = a.id_hotel) AS salariul_minim_hotel
FROM P_Angajat a
JOIN P_Departament d ON a.id_departament = d.id_departament
JOIN P_Hotel h ON a.id_hotel = h.id_hotel
WHERE a.salariul > (
    SELECT AVG(a4.salariul)
    FROM P_Angajat a4
    WHERE a4.id_hotel = a.id_hotel
)
ORDER BY h.nume, d.nume, a.salariul DESC;



--Să se afișeze angajații care au generat un venit total din plăți mai mare decât media generală a veniturilor realizate de toți angajații, indicând:
--hotelul și departamentul lor,
--numărul de rezervări gestionate,
--venitul total și venitul mediu per rezervare.

SELECT 
    a.nume || ' ' || a.prenume AS angajat,
    h.nume AS hotel,
    d.nume AS departament,
    COUNT(r.id_rezervare) AS nr_rezervari,
    NVL(SUM(p.suma), 0) AS venit_total,
    ROUND(
        NVL(SUM(p.suma), 0) / NULLIF(COUNT(r.id_rezervare), 0),
        2
    ) AS venit_mediu_pe_rezervare
FROM P_Angajat a
JOIN P_Hotel h ON a.id_hotel = h.id_hotel
JOIN P_Departament d ON a.id_departament = d.id_departament
LEFT JOIN P_Rezervari r ON a.id_angajat = r.id_angajat
LEFT JOIN P_Plati p ON r.id_rezervare = p.id_rezervare
GROUP BY a.nume, a.prenume, h.nume, d.nume
HAVING NVL(SUM(p.suma), 0) > (
    SELECT AVG(total_venit)
    FROM (
        SELECT NVL(SUM(p2.suma), 0) AS total_venit
        FROM P_Rezervari r2
        LEFT JOIN P_Plati p2 ON r2.id_rezervare = p2.id_rezervare
        GROUP BY r2.id_angajat
    )
)
ORDER BY venit_total DESC;



--ex 5
--functii analitice

--Clasamentul angajaților după salariu în fiecare hotel
SELECT 
    h.nume AS hotel,
    a.nume || ' ' || a.prenume AS angajat,
    a.salariul,
    RANK() OVER (PARTITION BY h.id_hotel ORDER BY a.salariul DESC) AS pozitie_salariu
FROM P_Angajat a
JOIN P_Hotel h ON a.id_hotel = h.id_hotel
ORDER BY h.nume, pozitie_salariu;



--Numărul de angajați cu salarii apropiate (±1000) față de fiecare angajat
SELECT 
    a.nume || ' ' || a.prenume AS angajat,
    a.salariul,
    COUNT(a.id_angajat) OVER (
        ORDER BY a.salariul 
        RANGE BETWEEN 1000 PRECEDING AND 1000 FOLLOWING
    ) AS nr_angajati_interval
FROM P_Angajat a
ORDER BY a.salariul;


--Clasamentul angajaților după salariu în cadrul fiecărui departament 
SELECT 
    d.nume AS departament,
    a.nume || ' ' || a.prenume AS angajat,
    a.salariul,
    RANK() OVER (PARTITION BY d.id_departament ORDER BY a.salariul DESC) AS pozitie_departament
FROM P_Angajat a
JOIN P_Departament d ON a.id_departament = d.id_departament
ORDER BY d.nume, pozitie_departament;


--Suma cumulată a plăților per hotel
SELECT 
    h.nume AS hotel,
    p.data_plata,
    SUM(p.suma) OVER (
        PARTITION BY h.id_hotel 
        ORDER BY p.data_plata 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS suma_cumulata
FROM P_Plati p
JOIN P_Rezervari r ON p.id_rezervare = r.id_rezervare
JOIN P_Camera c ON r.id_camera = c.id_camera
JOIN P_Hotel h ON c.id_hotel = h.id_hotel
ORDER BY h.nume, p.data_plata;


--Angajatul cel mai bine și cel mai slab plătit din fiecare departament
SELECT
    d.nume AS departament,
    (SELECT a1.nume || ' ' || a1.prenume
     FROM P_Angajat a1
     WHERE a1.id_departament = d.id_departament
       AND a1.salariul = (SELECT MAX(a2.salariul)
                          FROM P_Angajat a2
                          WHERE a2.id_departament = d.id_departament)
     FETCH FIRST 1 ROWS ONLY) AS angajat_maxim,
    (SELECT MAX(a3.salariul)
     FROM P_Angajat a3
     WHERE a3.id_departament = d.id_departament) AS salariu_maxim,
    (SELECT a4.nume || ' ' || a4.prenume
     FROM P_Angajat a4
     WHERE a4.id_departament = d.id_departament
       AND a4.salariul = (SELECT MIN(a5.salariul)
                          FROM P_Angajat a5
                          WHERE a5.id_departament = d.id_departament)
     FETCH FIRST 1 ROWS ONLY) AS angajat_minim,
    (SELECT MIN(a6.salariul)
     FROM P_Angajat a6
     WHERE a6.id_departament = d.id_departament) AS salariu_minim
FROM P_Departament d
ORDER BY d.nume;



--Compararea salariilor consecutive din cadrul aceluiași hotel
SELECT 
    h.nume AS hotel,
    a.nume || ' ' || a.prenume AS angajat,
    a.salariul,
    LAG(a.salariul, 1, 0) OVER (PARTITION BY h.id_hotel ORDER BY a.salariul DESC) AS salariu_precedent,
    LEAD(a.salariul, 1, 0) OVER (PARTITION BY h.id_hotel ORDER BY a.salariul DESC) AS salariu_urmator,
    a.salariul - LAG(a.salariul, 1, 0) OVER (PARTITION BY h.id_hotel ORDER BY a.salariul DESC) AS diferenta_fata_de_precedent
FROM P_Angajat a
JOIN P_Hotel h ON a.id_hotel = h.id_hotel
ORDER BY h.nume, a.salariul DESC;


--Să se afișeze procentul poziției fiecărui angajat în ierarhia totală a salariilor și distribuția cumulativă a acestora.
SELECT 
    a.nume || ' ' || a.prenume AS angajat,
    a.salariul,
    ROUND(PERCENT_RANK() OVER (ORDER BY a.salariul), 3) AS percent_rank,
    ROUND(CUME_DIST() OVER (ORDER BY a.salariul), 3) AS distributie_cumulata
FROM P_Angajat a
ORDER BY a.salariul;


--Să se afișeze angajații care au un salariu peste media departamentului lor, afișând și media respectivă calculată dinamic.
SELECT 
    a.nume || ' ' || a.prenume AS angajat,
    d.nume AS departament,
    a.salariul,
    ROUND(AVG(a.salariul) OVER (PARTITION BY a.id_departament), 2) AS medie_departament
FROM P_Angajat a
JOIN P_Departament d ON a.id_departament = d.id_departament
WHERE a.salariul > (
    SELECT AVG(a2.salariul)
    FROM P_Angajat a2
    WHERE a2.id_departament = a.id_departament
)
ORDER BY d.nume, a.salariul DESC;















