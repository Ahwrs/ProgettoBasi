CREATE TABLE CLIENTE(

	Codice_Fiscale VARCHAR(16) PRIMARY KEY,
	Nome VARCHAR(255) NOT NULL,
	Cognome VARCHAR(255) NOT NULL,
	Data_Nascita DATE NOT NULL,
	Telefono VARCHAR(20) NOT NULL
);

CREATE TABLE MOTORE(
    
    Codice_Motore VARCHAR(20) PRIMARY KEY,
    Cilindrata INT NOT NULL,
    Frazionamento VARCHAR(20) NOT NULL,
    Alimentazione VARCHAR(20) NOT NULL
);

-- INSERT

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
    ('OPT_FRENI_M', 'Meccanica', 'Freni M Sport'),
    ('OPT_ASSETTO_ADATT', 'Meccanica', 'Assetto Adattivo M'),
    ('OPT_STERZO_SPORT', 'Meccanica', 'Sterzo Sportivo'),
    ('OPT_DIFF_PERF', 'Meccanica', 'Diff. M Performance'),
    ('OPT_SHADOW_LINE', 'Estetica', 'Shadow Line Lucida'),
    ('OPT_SEDILI_ALC', 'Interni', 'Sedili M Alcantara'),
    ('OPT_VOLANTE_M', 'Interni', 'Volante Sportivo M'),
    ('OPT_AUDIO_HK', 'Comfort', 'Harman Kardon Audio'),
    ('OPT_LED_ADATT', 'Tecnologia', 'Fari LED Adattivi'),
    ('OPT_DISPLAY_EXT', 'Tecnologia', 'Display Esteso'),
    ('OPT_NAV_PRO', 'Tecnologia', 'Navigatore Pro');

INSERT INTO RICAMBIO (OEM, Nome, Prezzo_Unitario) VALUES
    ('11318510014', 'Kit Catena N47', 349.99),
    ('11247841703', 'Bronzine V10 S85', 599.00),
    ('83212365946', 'Olio TwinPower 5W30', 22.50),
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
    -- VEICOLI NUOVI
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
    -- VEICOLI USATI
    ('WBA116D0000000011', 'E87', '116d', 2008),
    ('WBA116D0000000012', 'E87', '116d', 2010),
    ('WBA120I0000000013', 'E87', '120i', 2007),
    ('WBSE60000000000014', 'E60', 'M5', 2006),
    ('WBSE60000000000015', 'E60', 'M5', 2008),
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
    ('WBAG3000000000030', 'G30', 'M550d', 2020);

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
    ('WBSE60000000000014', '2024-01-05', 2),
    ('WBSE60000000000015', '2023-08-12', 5),
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
    ('WBAG3000000000030', '2024-01-20', 1);