-- CERERE 1: STRUCTURA ORGANIGRAMEI (TOP-DOWN)
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




-- CERERE 2: IERARHIE DE SUS IN JOS (BOTTOM-UP)
SELECT 
    LEVEL AS nivel_ierarhic,
    CONNECT_BY_ROOT a.nume || ' ' || CONNECT_BY_ROOT a.prenume AS angajat_initial,
    a.nume || ' ' || a.prenume AS superior,
    t.denumire AS functie
FROM P_Angajat a
JOIN P_Tipuri_Angajati t ON a.id_tip = t.id_tip
CONNECT BY PRIOR a.id_manager = a.id_angajat
START WITH a.nume = 'Simionescu' AND a.prenume = 'Vasile';



-- CERERE 3: CALEA COMPLETĂ DE LA MANAGER GENERAL LA SUBORDONAT
SELECT 
    a.id_angajat,
    a.nume || ' ' || a.prenume AS angajat,
    SYS_CONNECT_BY_PATH(a.nume || ' ' || a.prenume, ' → ') AS cale_ierarhica,
    LEVEL - 1 AS nr_sefi
FROM P_Angajat a
CONNECT BY PRIOR a.id_angajat = a.id_manager
START WITH a.id_manager IS NULL
ORDER BY cale_ierarhica;


-- CERERE 4: SUBORDONAȚII CARE AU ACEEAȘI ARIE FUNCȚIONALĂ CA MANAGERUL
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


-- CERERE 5: SUBORDONAȚII ÎNCEPÂND DE LA NIVELUL 2 + FUNCȚIE ANALITICĂ
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







