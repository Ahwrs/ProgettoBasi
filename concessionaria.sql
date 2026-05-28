--------------------------------
-- CREAZIONE TABELLE DATABASE --
--------------------------------

CREATE TABLE CLIENTE(

	Codice_Fiscale VARCHAR(16) PRIMARY KEY,
	Nome VARCHAR(20) NOT NULL,
	Cognome VARCHAR(20) NOT NULL,
	Data_Nascita DATE NOT NULL,
	Telefono VARCHAR(20) NOT NULL
);

CREATE TABLE MOTORE(
    
    Codice_Motore VARCHAR(20) PRIMARY KEY,
    Cilindrata INT NOT NULL CHECK (Cilindrata > 0),
    Frazionamento VARCHAR(20) NOT NULL,
    Alimentazione VARCHAR(20) NOT NULL
);

CREATE TABLE MODELLO(

	Denominazione_Commerciale VARCHAR(20),
	Codice_Telaio VARCHAR(20),
	Anno_Prima_Produzione INT NOT NULL 
		CHECK (Anno_Prima_Produzione BETWEEN 1886 AND EXTRACT(YEAR FROM CURRENT_DATE)),

	PRIMARY KEY (Denominazione_Commerciale, Codice_Telaio)
);

CREATE TABLE VEICOLO(

	VIN VARCHAR(20) PRIMARY KEY,
	Anno_Immatricolazione INT NOT NULL
		CHECK (Anno_Immatricolazione BETWEEN 1886 AND EXTRACT(YEAR FROM CURRENT_DATE)),
	
	Denominazione_Commerciale VARCHAR(20) NOT NULL,
    Codice_Telaio VARCHAR(20) NOT NULL,

    FOREIGN KEY (Denominazione_Commerciale, Codice_Telaio)
    REFERENCES MODELLO(Denominazione_Commerciale, Codice_Telaio)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE VEICOLO_USATO(

	VIN VARCHAR(20) PRIMARY KEY REFERENCES VEICOLO(VIN) 
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	
	Data_Ultima_Revisione DATE NOT NULL 
		CHECK (Data_Ultima_Revisione BETWEEN '1886-01-01' AND CURRENT_DATE),
	
	Numero_Proprietari INT NOT NULL CHECK (Numero_Proprietari > 0)
);

CREATE TABLE VEICOLO_NUOVO(

	VIN VARCHAR(20) PRIMARY KEY REFERENCES VEICOLO(VIN) 
		ON DELETE RESTRICT
		ON UPDATE CASCADE,

	Garanzia INT NOT NULL CHECK (Garanzia > 0)
);

CREATE TABLE OPTIONAL(

	Codice_Optional VARCHAR(20) PRIMARY KEY,
	Nome VARCHAR(20) NOT NULL,
	Categoria VARCHAR(20) NOT NULL
);

CREATE TABLE DIPENDENTE(

	Matricola VARCHAR(5) PRIMARY KEY,
	Nome VARCHAR(20) NOT NULL,
	Cognome VARCHAR(20) NOT NULL,
	Data_Assunzione DATE NOT NULL CHECK (Data_Assunzione <= CURRENT_DATE),
	Stipendio INT NOT NULL CHECK (Stipendio > 0)
);

CREATE TABLE MECCANICO(

	Matricola VARCHAR(5) PRIMARY KEY REFERENCES DIPENDENTE(Matricola)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	Specializzazione VARCHAR(20) NOT NULL,
	Livello_Aziendale VARCHAR(20) NOT NULL
);

CREATE TABLE VENDITORE(

	Matricola VARCHAR(5) PRIMARY KEY REFERENCES DIPENDENTE(Matricola)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	Percentuale_Commissione DECIMAL(10, 2) NOT NULL 
		CHECK (Percentuale_Commissione BETWEEN 0 AND 100)
);

CREATE TABLE ACQUISTO(

    Veicolo VARCHAR(20) PRIMARY KEY REFERENCES VEICOLO(VIN)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    Data_Acquisto DATE NOT NULL 
        CHECK (Data_Acquisto BETWEEN '1886-01-01' AND CURRENT_DATE),

    Cliente VARCHAR(16) NOT NULL REFERENCES CLIENTE(Codice_Fiscale)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    Venditore VARCHAR(5) NOT NULL REFERENCES VENDITORE(Matricola)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    Prezzo DECIMAL(10, 2) NOT NULL CHECK (Prezzo > 0)
);

CREATE TABLE INTERVENTO(

    Veicolo VARCHAR(20) REFERENCES VEICOLO(VIN)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
	Numero_Intervento INT,
    Data_Intervento DATE NOT NULL,
    Costo DECIMAL(10,2) NOT NULL CHECK (Costo > 0),
    Ore_Manodopera INT NOT NULL CHECK (Ore_Manodopera > 0),
    Meccanico VARCHAR(5) NOT NULL
        REFERENCES MECCANICO(Matricola)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    PRIMARY KEY (Veicolo, Numero_Intervento)       
);

CREATE OR REPLACE FUNCTION Check_Data_Intervento()
RETURNS TRIGGER AS $$
DECLARE
    Anno_IMTR INT;
BEGIN

    SELECT Anno_Immatricolazione
    INTO Anno_IMTR
    FROM VEICOLO
    WHERE VIN = NEW.Veicolo;

    IF EXTRACT(YEAR FROM NEW.Data_Intervento) < Anno_IMTR THEN
        RAISE EXCEPTION 'Data intervento non valida';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Check_Data_Intervento_TRG
BEFORE INSERT ON INTERVENTO
FOR EACH ROW
EXECUTE FUNCTION Check_Data_Intervento();

CREATE OR REPLACE FUNCTION Num_Progressivo_Intervento()
RETURNS TRIGGER AS $$
DECLARE
    Ultimo INT;
BEGIN

    PERFORM 1
    FROM INTERVENTO
    WHERE Veicolo = NEW.Veicolo
    FOR UPDATE;

    SELECT COALESCE(MAX(Numero_Intervento), 0)
    INTO Ultimo
    FROM INTERVENTO
    WHERE Veicolo = NEW.Veicolo;

    NEW.Numero_Intervento := Ultimo + 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Num_Progressivo
BEFORE INSERT ON INTERVENTO
FOR EACH ROW
EXECUTE FUNCTION Num_Progressivo_Intervento();

CREATE TABLE RICAMBIO(
	
	OEM VARCHAR(20) PRIMARY KEY,
	Nome VARCHAR(100) NOT NULL,
	Prezzo_Unitario DECIMAL(10,2) NOT NULL CHECK (Prezzo_Unitario > 0)
);

CREATE TABLE EQUIPAGGIA(

	Optional VARCHAR(20) REFERENCES OPTIONAL(Codice_Optional)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
	
	Veicolo VARCHAR(20) REFERENCES VEICOLO_NUOVO(VIN)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	PRIMARY KEY (Optional, Veicolo)
);

CREATE TABLE UTILIZZA(

    Ricambio VARCHAR(20) REFERENCES RICAMBIO(OEM)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    Veicolo VARCHAR(20) NOT NULL,
    Numero_Intervento INT NOT NULL,
    
    Quantita INT NOT NULL CHECK (Quantita > 0),

    PRIMARY KEY (Ricambio, Veicolo, Numero_Intervento),

    FOREIGN KEY (Veicolo, Numero_Intervento) 
        REFERENCES INTERVENTO( Veicolo, Numero_Intervento)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE MOTORIZZATO_DA(

	Codice_Telaio VARCHAR(20),
	Denominazione_Commerciale VARCHAR(20),
	Motore VARCHAR(20),
	Potenza INT CHECK(Potenza > 0),

	PRIMARY KEY (Codice_Telaio, Denominazione_Commerciale, Motore),

	FOREIGN KEY (Codice_Telaio, Denominazione_Commerciale)
	REFERENCES MODELLO(Codice_Telaio, Denominazione_Commerciale)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	FOREIGN KEY (Motore) REFERENCES MOTORE(Codice_Motore)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);



------------------------------
-- POPOLAMENTO DATI TABELLE --
------------------------------

INSERT INTO MOTORE (Codice_Motore, Cilindrata, Frazionamento, Alimentazione)
VALUES
    ('N47', 1995, 'I4', 'Diesel'),
    ('B58', 2998, 'I6', 'Benzina'),
    ('S65', 3999, 'V8', 'Benzina'),
    ('M57', 2993, 'I6', 'Diesel'),
    ('B57', 2993, 'I6', 'Diesel'),
    ('S85', 4998, 'V10', 'Benzina'),
    ('S55', 2979, 'I6', 'Benzina'),
    ('N43', 1995, 'I4', 'Benzina'),
    ('S58', 2993, 'I6', 'Benzina');

INSERT INTO MODELLO (Codice_Telaio, Denominazione_Commerciale, Anno_Prima_Produzione) VALUES
    ('E87', '116d', 2009),
    ('E60', 'M5', 2004),
    ('E92', '320d', 2006),
    ('E90', '320d', 2005),
    ('E92', '335d', 2007),
    ('E90', 'M3', 2007),
    ('F20', '118d', 2012),
    ('F82', 'M4 Competition', 2016),
    ('F20', 'M140i', 2016),
    ('G30', 'M550d', 2017),
    ('G82', 'M4 Competition', 2020),
    ('G20', 'M340i', 2019),
    ('G80', 'M3 Competition', 2020),
    ('E87', '120i', 2007),
    ('E90', '320i', 2005);

INSERT INTO OPTIONAL (Codice_Optional, Categoria, Nome) VALUES
    ('2NH', 'Meccanica', 'Freni M Sport'),
    ('2VF', 'Meccanica', 'Assetto Adattivo M'),
    ('2VL', 'Meccanica', 'Sterzo Sportivo'),
    ('2T4', 'Meccanica', 'Diff. M Performance'),
    ('760', 'Estetica', 'Shadow Line Lucida'),
    ('712', 'Interni', 'Sedili M Alcantara'),
    ('710', 'Interni', 'Volante Sportivo M'),
    ('688', 'Comfort', 'Harman Kardon Audio'),
    ('552', 'Tecnologia', 'Fari LED Adattivi'),
    ('6WA', 'Tecnologia', 'Display Esteso'),
    ('609', 'Tecnologia', 'Navigatore Pro');

INSERT INTO RICAMBIO (OEM, Nome, Prezzo_Unitario) VALUES
    ('11318510014', 'Kit Catena N47', 349.99),
    ('11247841703', 'Bronzine V10 S85', 599.00),
	('83212365946', 'Olio 5W30 Longlife', 22.50),
    ('83212405097', 'Olio 0W30 M-Power', 26.00),
    ('83212365950', 'Olio 5W40 M-Sport', 24.50),
    ('83212219736', 'Olio 10W60 Racing', 28.00),
    ('11427953129', 'Filtro Olio', 18.00),
    ('13717797465', 'Filtro Aria', 35.00),
    ('64119237555', 'Filtro Abitacolo', 45.00),
    ('13328582272', 'Filtro Carburante', 55.00),
    ('12120037582', 'Candela High Spark', 15.00),
    ('34116792223', 'Dischi Freno Ant.', 250.00),
    ('34116871542', 'Pastiglie Ant. M', 145.00),
    ('11517586925', 'Pompa Acqua', 180.00),
    ('21207603248', 'Kit Frizione', 450.00);

INSERT INTO DIPENDENTE (Matricola, Nome, Cognome, Data_Assunzione, Stipendio) VALUES
    ('MAT01', 'Marco', 'Rizzo', '2018-05-10', 2500.00),
    ('MAT02', 'Luca', 'Bianchi', '2019-03-15', 2000.00),
    ('MAT03', 'Fabio', 'Neri', '2020-01-20', 2100.00),
    ('MAT04', 'Anna', 'Verdi', '2021-06-01', 2400.00),
    ('MAT05', 'Giulia', 'Conti', '2017-09-12', 2600.00),
    ('MAT06', 'Paolo', 'Galli', '2022-02-28', 1900.00),
    ('MAT07', 'Elena', 'Costa', '2016-11-05', 2800.00),
    ('MAT08', 'Andrea', 'Moretti', '2023-04-10', 1800.00),
    ('MAT09', 'Sara', 'Fontana', '2020-08-25', 2200.00),
    ('MAT10', 'Luigi', 'Romano', '2015-01-10', 3000.00);

INSERT INTO CLIENTE (Codice_Fiscale, Nome, Cognome, Data_Nascita, Telefono) VALUES
    ('RSSMRA85A01F205Z', 'Mario', 'Rossi', '1985-01-12', '3331111111'),
    ('BRNLRA90B02F205X', 'Laura', 'Bruni', '1990-02-24', '3332222222'),
    ('GLLGNN75C03F205Y', 'Giovanni', 'Gialli', '1975-03-18', '3333333333'),
    ('VRDLCA88D04F205W', 'Luca', 'Verdi', '1988-04-05', '3334444444'),
    ('NRYLRA95E05F205V', 'Sara', 'Neri', '1995-05-15', '3335555555'),
    ('BNCFAB80F06F205U', 'Fabio', 'Bianchi', '1980-06-20', '3336666666'),
    ('RZZMRA92G07F205T', 'Marco', 'Rizzo', '1992-07-22', '3337777777'),
    ('DNCALB70H08F205S', 'Alberto', 'Donati', '1970-08-01', '3338888888'),
    ('CRTVAL98I09F205R', 'Valeria', 'Carta', '1998-09-09', '3339999999'),
    ('LCCGIO85L10F205Q', 'Giorgio', 'Lucci', '1985-10-10', '3330000000');

INSERT INTO MOTORIZZATO_DA (Codice_Telaio, Denominazione_Commerciale, Motore, Potenza) VALUES
    ('E87', '116d', 'N47', 116),
    ('E60', 'M5', 'S85', 507),
    ('E92', '320d', 'N47', 163),
    ('E90', '320d', 'N47', 177),
    ('E92', '335d', 'M57', 286),
    ('E90', 'M3', 'S65', 420),
    ('F20', '118d', 'N47', 143),
    ('F82', 'M4 Competition', 'S55', 450),
    ('F20', 'M140i', 'B58', 340),
    ('G30', 'M550d', 'B57', 400),
    ('G82', 'M4 Competition', 'S58', 510),
    ('G20', 'M340i', 'B58', 374),
    ('G80', 'M3 Competition', 'S58', 510),
    ('E87', '120i', 'N43', 150),
    ('E90', '320i', 'N43', 170);

INSERT INTO VEICOLO (VIN, Codice_Telaio, Denominazione_Commerciale, Anno_Immatricolazione) VALUES
    ('WBSG8000000000001', 'G80', 'M3 Competition', 2024),
    ('WBSG8000000000002', 'G80', 'M3 Competition', 2024),
    ('WBSG8200000000003', 'G82', 'M4 Competition', 2023),
    ('WBSG8200000000004', 'G82', 'M4 Competition', 2024),
    ('WBA340I0000000005', 'G20', 'M340i', 2024),
    ('WBA340I0000000006', 'G20', 'M340i', 2024),
    ('WBA340I0000000007', 'G20', 'M340i', 2023),
    ('WBAG3000000000008', 'G30', 'M550d', 2023),
    ('WBA118D0000000009', 'F20', '118d', 2024),
    ('WBA118D0000000010', 'F20', '118d', 2024),
    ('WBA116D0000000011', 'E87', '116d', 2008),
    ('WBA116D0000000012', 'E87', '116d', 2010),
    ('WBA120I0000000013', 'E87', '120i', 2007),
    ('WBSE6000000000014', 'E60', 'M5', 2006),
    ('WBSE6000000000015', 'E60', 'M5', 2008),
    ('WBA320D0000000016', 'E90', '320d', 2007),
    ('WBA320D0000000017', 'E90', '320d', 2010),
    ('WBA320I0000000018', 'E90', '320i', 2006),
    ('WBA320DE920000019', 'E92', '320d', 2009),
    ('WBA335D0000000020', 'E92', '335d', 2008),
    ('WBSE9000000000021', 'E90', 'M3', 2008),
    ('WBSE9000000000022', 'E90', 'M3', 2011),
    ('WBAF2000000000023', 'F20', '118d', 2013),
    ('WBAF2000000000024', 'F20', '118d', 2015),
    ('WBAF2000000000025', 'F20', '118d', 2018),
    ('WBA140I0000000026', 'F20', 'M140i', 2017),
    ('WBSF8200000000027', 'F82', 'M4 Competition', 2016),
    ('WBSF8200000000028', 'F82', 'M4 Competition', 2019),
    ('WBAG3000000000029', 'G30', 'M550d', 2018),
    ('WBAG3000000000030', 'G30', 'M550d', 2020),
    ('WBAN4700000000001', 'F20', '118d', 2014),
    ('WBAN4700000000002', 'F20', '118d', 2013),
    ('WBAN4700000000003', 'F20', '118d', 2015),
    ('WBAN4700000000004', 'E90', '320d', 2012),
    ('WBAN4700000000005', 'E90', '320d', 2010);

INSERT INTO MECCANICO (Matricola, Specializzazione, Livello_Aziendale) VALUES
    ('MAT02', 'Motori Diesel', 3),
    ('MAT03', 'Reparto M Power', 4),
    ('MAT06', 'Tagliandi Rapidi', 2),
    ('MAT08', 'Elettronica', 2),
    ('MAT10', 'Capo Officina', 5);

INSERT INTO VENDITORE (Matricola, Percentuale_Commissione) VALUES
    ('MAT01', 5.0),
    ('MAT04', 4.5),
    ('MAT05', 3.5),
    ('MAT07', 6.0),
    ('MAT09', 4.0);

INSERT INTO VEICOLO_NUOVO (VIN, Garanzia) VALUES
    ('WBSG8000000000001', 48),
    ('WBSG8000000000002', 48),
    ('WBSG8200000000003', 48),
    ('WBSG8200000000004', 48),
    ('WBA340I0000000005', 24),
    ('WBA340I0000000006', 48),
    ('WBA340I0000000007', 24),
    ('WBAG3000000000008', 24),
    ('WBA118D0000000009', 48),
    ('WBA118D0000000010', 24);

INSERT INTO VEICOLO_USATO (VIN, Data_Ultima_Revisione, Numero_Proprietari) VALUES
    ('WBA116D0000000011', '2022-05-10', 3),
    ('WBA116D0000000012', '2024-02-15', 2),
    ('WBA120I0000000013', '2023-11-20', 4),
    ('WBSE6000000000014', '2024-01-05', 2),
    ('WBSE6000000000015', '2023-08-12', 5),
    ('WBA320D0000000016', '2023-09-30', 2),
    ('WBA320D0000000017', '2024-03-10', 1),
    ('WBA320I0000000018', '2022-12-14', 3),
    ('WBA320DE920000019', '2023-07-22', 2),
    ('WBA335D0000000020', '2024-04-01', 3),
    ('WBSE9000000000021', '2023-10-10', 2),
    ('WBSE9000000000022', '2024-01-25', 1),
    ('WBAF2000000000023', '2023-05-18', 2),
    ('WBAF2000000000024', '2023-11-05', 1),
    ('WBAF2000000000025', '2024-02-28', 1),
    ('WBA140I0000000026', '2023-09-12', 2),
    ('WBSF8200000000027', '2024-03-15', 2),
    ('WBSF8200000000028', '2023-12-01', 1),
    ('WBAG3000000000029', '2024-04-10', 1),
    ('WBAN4700000000001', '2025-05-10', 2),
    ('WBAN4700000000002', '2024-11-20', 3),
    ('WBAN4700000000003', '2025-08-15', 1),
    ('WBAN4700000000004', '2025-02-28', 4),
    ('WBAN4700000000005', '2024-07-10', 3),
    ('WBAG3000000000030', '2024-01-20', 1);

INSERT INTO ACQUISTO (Veicolo, Data_Acquisto, Cliente, Venditore, Prezzo) VALUES
    ('WBSG8000000000001', '2025-05-10', 'RSSMRA85A01F205Z', 'MAT07', 95000.00),
    ('WBA320D0000000016', '2025-06-15', 'BRNLRA90B02F205X', 'MAT01', 12500.00),
    ('WBAF2000000000023', '2025-07-20', 'GLLGNN75C03F205Y', 'MAT07', 16500.00),
    ('WBSE6000000000014', '2025-09-05', 'VRDLCA88D04F205W', 'MAT04', 35000.00),
    ('WBA340I0000000005', '2025-10-12', 'NRYLRA95E05F205V', 'MAT07', 68000.00),
    ('WBA116D0000000011', '2025-11-22', 'BNCFAB80F06F205U', 'MAT01', 6500.00),
    ('WBA320D0000000017', '2026-01-15', 'RZZMRA92G07F205T', 'MAT07', 13500.00);

INSERT INTO INTERVENTO (Veicolo, Numero_Intervento, Data_Intervento, Costo, Ore_Manodopera, Meccanico) VALUES
    ('WBA320D0000000016', 1, '2026-02-10', 1400.00, 12, 'MAT02'),
    ('WBA116D0000000011', 1, '2026-03-05', 1350.00, 11, 'MAT02'),
    ('WBAF2000000000023', 1, '2026-04-20', 1450.00, 12, 'MAT02'),
    ('WBSG8000000000001', 1, '2026-05-15', 550.00, 2, 'MAT06'),
    ('WBA340I0000000005', 1, '2026-05-20', 450.00, 2, 'MAT06'),
    ('WBA320D0000000017', 1, '2026-05-25', 350.00, 2, 'MAT06'),
    ('WBSE6000000000014', 1, '2026-05-26', 2800.00, 18, 'MAT03'),
    ('WBA320D0000000016', 1, '2026-04-15', 300.00, 2, 'MAT06'), 
    ('WBA116D0000000011', 1, '2026-05-02', 150.00, 1, 'MAT06'),
    ('WBSG8000000000001', 1, '2026-05-22', 400.00, 2, 'MAT03'), 
    ('WBSG8000000000001', 1, '2026-05-25', 250.00, 1, 'MAT03'),
    ('WBAN4700000000001', 1, '2026-09-01', 1800.00, 14, 'MAT02'),
    ('WBAN4700000000002', 1, '2026-09-05', 1850.00, 15, 'MAT02'),
    ('WBAN4700000000003', 1, '2026-09-10', 1800.00, 14, 'MAT02'),
    ('WBAN4700000000004', 1, '2026-09-15', 1900.00, 16, 'MAT02'),
    ('WBAN4700000000005', 1, '2026-09-20', 1950.00, 16, 'MAT02');


INSERT INTO UTILIZZA (Ricambio, Numero_Intervento, Veicolo, Quantita) VALUES
    ('11318510014', 1, 'WBA320D0000000016', 1),
    ('11427953129', 1, 'WBA320D0000000016', 1),
    ('11318510014', 1, 'WBA116D0000000011', 1),
    ('83212365946', 1, 'WBA116D0000000011', 3),
    ('11427953129', 1, 'WBA116D0000000011', 1),
    ('11318510014', 1, 'WBAF2000000000023', 1),
    ('83212365946', 1, 'WBAF2000000000023', 4),
    ('11427953129', 1, 'WBAF2000000000023', 1),
    ('64119237555', 1, 'WBAF2000000000023', 1),
    ('83212405097', 1, 'WBSG8000000000001', 7),
    ('11427953129', 1, 'WBSG8000000000001', 1),
    ('13717797465', 1, 'WBSG8000000000001', 2),
    ('83212365950', 1, 'WBA340I0000000005', 6),
    ('11427953129', 1, 'WBA340I0000000005', 1),
    ('11427953129', 1, 'WBA320D0000000017', 1),
    ('13328582272', 1, 'WBA320D0000000017', 1),
    ('11247841703', 1, 'WBSE6000000000014', 10),
    ('83212219736', 1, 'WBSE6000000000014', 9),
    ('11427953129', 1, 'WBSE6000000000014', 1),
    ('34116871542', 2, 'WBA320D0000000016', 1),
    ('64119237555', 2, 'WBA116D0000000011', 1),
    ('12120037582', 2, 'WBSG8000000000001', 6),
    ('34116792223', 3, 'WBSG8000000000001', 2),
    ('11318510014', 1, 'WBAN4700000000001', 1),
    ('11318510014', 1, 'WBAN4700000000002', 1),
    ('11318510014', 1, 'WBAN4700000000003', 1),
    ('11318510014', 1, 'WBAN4700000000004', 1),
    ('11318510014', 1, 'WBAN4700000000005', 1);

INSERT INTO EQUIPAGGIA (Optional, Veicolo) VALUES
    ('2NH', 'WBSG8000000000001'),
    ('2VF', 'WBSG8000000000001'),
    ('2NH', 'WBSG8000000000002'),
    ('2VF', 'WBSG8000000000002'),
    ('2T4', 'WBSG8000000000002'),
    ('2NH', 'WBSG8200000000004'),
    ('2VF', 'WBSG8200000000004'),
    ('2NH', 'WBA340I0000000005'),
    ('710', 'WBA340I0000000005'),
    ('712', 'WBA340I0000000005'),
    ('760', 'WBA340I0000000005'),
    ('609', 'WBA340I0000000006'),
    ('552', 'WBA340I0000000006'),
    ('6WA', 'WBA340I0000000006'),
    ('609', 'WBA340I0000000007'),
    ('710', 'WBAG3000000000008'),
    ('712', 'WBAG3000000000008'),
    ('2VF', 'WBAG3000000000008'),
    ('760', 'WBA118D0000000009'),
    ('710', 'WBA118D0000000009'),
    ('712', 'WBA118D0000000009'),
    ('688', 'WBA118D0000000010'),
    ('2VL', 'WBA118D0000000010');



---------------------------------
-- INTERROGAZIONI SUL DATABASE --
---------------------------------

-------------
-- QUERY 1 --
-------------

-- View --
CREATE OR REPLACE VIEW VenditePerModello AS
SELECT
M. Denominazione_Commerciale ,
M. Codice_Telaio ,
COUNT (*) AS Numero_Vendite
FROM MODELLO M
JOIN VEICOLO V ON M. Denominazione_Commerciale = V. Denominazione_Commerciale
AND M. Codice_Telaio = V. Codice_Telaio
JOIN ACQUISTO A ON V.VIN = A. Veicolo
GROUP BY M. Denominazione_Commerciale , M. Codice_Telaio ;
-- Query --
SELECT *
FROM VenditePerModello
WHERE Numero_Vendite = ( SELECT MAX( Numero_Vendite ) FROM VenditePerModello );


-------------
-- QUERY 2 --
-------------

-- Query --
SELECT D.Matricola, D.Nome, D.Cognome, COUNT(*) AS vendite
FROM VENDITORE V
JOIN DIPENDENTE D ON V.Matricola = D.Matricola
JOIN ACQUISTO A ON V.Matricola = A.Venditore
WHERE A.Data_Acquisto BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY D.Matricola, D.Nome, D.Cognome
HAVING COUNT(*) >= 3;

-- Indice --
CREATE INDEX idx_acquisto_data_venditore ON ACQUISTO ( Data_Acquisto , Venditore );



-------------
-- QUERY 3 --
-------------

SELECT DISTINCT ON (M.Codice_Motore)
    M.Codice_Motore,
    R.OEM,
    R.Nome AS Nome_Ricambio,
    SUM(U.Quantita) AS Quantita_Totale
FROM MOTORE M

JOIN MOTORIZZATO_DA MD ON M.Codice_Motore = MD.Motore
JOIN MODELLO MO 
        ON MD.Denominazione_Commerciale = MO.Denominazione_Commerciale
        AND MD.Codice_Telaio = MO.Codice_Telaio
JOIN VEICOLO V 
        ON MO.Denominazione_Commerciale = V.Denominazione_Commerciale
        AND MO.Codice_Telaio = V.Codice_Telaio
JOIN INTERVENTO I ON V.VIN = I.Veicolo
JOIN UTILIZZA U 
        ON I.Veicolo = U.Veicolo
        AND I.Numero_Intervento = U.Numero_Intervento
JOIN RICAMBIO R ON U.Ricambio = R.OEM

GROUP BY M.Codice_Motore, R.OEM, R.Nome
ORDER BY M.Codice_Motore, Quantita_Totale DESC;



-------------
-- QUERY 4 --
-------------

SELECT 
    M.Frazionamento,
    M.Alimentazione,
    COUNT(*) AS Numero_Vendite
FROM MOTORE M
JOIN MOTORIZZATO_DA MD ON M.Codice_Motore = MD.Motore
JOIN MODELLO MO 
        ON MD.Denominazione_Commerciale = MO.Denominazione_Commerciale 
        AND MD.Codice_Telaio = MO.Codice_Telaio
JOIN VEICOLO V 
        ON MO.Denominazione_Commerciale = V.Denominazione_Commerciale 
        AND MO.Codice_Telaio = V.Codice_Telaio
JOIN ACQUISTO A ON V.VIN = A.Veicolo

GROUP BY M.Frazionamento, M.Alimentazione
ORDER BY Numero_Vendite DESC;



-------------
-- QUERY 5 --
-------------

SELECT ROUND(AVG(A.Prezzo), 2) AS Prezzo_Medio_Superbollo
FROM MOTORIZZATO_DA MD
JOIN MODELLO MO 
        ON MD.Denominazione_Commerciale = MO.Denominazione_Commerciale 
        AND MD.Codice_Telaio = MO.Codice_Telaio
JOIN VEICOLO V 
        ON MO.Denominazione_Commerciale = V.Denominazione_Commerciale 
        AND MO.Codice_Telaio = V.Codice_Telaio
JOIN ACQUISTO A ON V.VIN = A.Veicolo
WHERE MD.Potenza > 250;