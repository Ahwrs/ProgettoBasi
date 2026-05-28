#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <postgresql/libpq-fe.h>

PGconn* connetti_al_db() {

    // Login
    char host[50], port[10], db_name[50], username[50], password[50];
    char conninfo[500];

    printf("=======================\n");
    printf("\t LOGIN\n");
    printf("=======================\n");
    printf("Inserire le credenziali per accedere al database.\n");
    
    printf("Host: ");
    scanf("%s", host);
    
    printf("Porta: ");
    scanf("%s", port);

    printf("Nome database: ");
    scanf("%s", db_name);

    printf("Nome utente: ");
    scanf("%s", username);

    printf("Password: ");
    scanf("%s", password);
    
    snprintf(conninfo, sizeof(conninfo), "host=%s port=%s dbname=%s user=%s password=%s", host, port, db_name, username, password);

    // Connessione effettiva al database
    PGconn* conn = PQconnectdb(conninfo);

    if (PQstatus(conn) != CONNECTION_OK) {
        printf("\nERRORE CRITICO: Connessione fallita!\n");
        printf("Motivo: %s\n", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }

    printf("\nConnessione al database '%s' riuscita con successo!\n\n", db_name);
    return conn;
}

int mostra_menu() {
    int scelta = -1;
    int esito_lettura = -1;

    printf("==============\n");
    printf("MENU QUERY\n");
    printf("==============\n");
    printf("1) Individuazione del modello di veicolo più venduto\n");
    printf("2) Estrazione dei venditori che hanno superato una specifica soglia di vendite in un determinato intervallo temporale\n");
    printf("3) Ricerca del ricambio più utilizzato per ogni tipologia di motore\n");
    printf("4) Calcolo del numero di vendite per le combinazioni più richieste di frazionamento e alimentazione\n");
    printf("5) Calcolo del prezzo medio dei veicoli venduti soggetti al superbollo (applicato sopra i 250 cv)\n");
    printf("-----------------\n");
    printf("Inserire il numero 0 per uscire dal programma\n"); // Permette di chiudere correttamente 
                                                               // la connessione con il database
    printf("-----------------\n");
    printf("Scegliere il numero corrispondente alla query desiderata: ");
    esito_lettura = scanf("%d", &scelta);
    printf("\n");

    while (scelta < 0 || scelta > 5 || esito_lettura != 1) {

        if (esito_lettura != 1) {
            while(getchar() != '\n'); // Pulisce in buffer di input se l'utente 
                                      // inserisce caratteri diversi da un numero
        }
        printf("Scelta non supportata o input invalido. Riprovare: ");
        esito_lettura = scanf("%d", &scelta);
        printf("\n");
    }

    return scelta;
}

void esegui_e_stampa(PGconn* conn, const char* query) {
    PGresult* risultato = PQexec(conn, query);

    if (PQresultStatus(risultato) != PGRES_TUPLES_OK) {          // PGRES_TUPLES_OK funziona solo in caso di interrogazioni (SELECT).
        printf("\nERRORE CRITICO: Esecuzione fallita!\n");       // In questo caso va bene, ma se si volesse generalizzare questa
        printf("Motivo: %s\n", PQerrorMessage(conn));            // funzione sarebbe necessario usare PGRES_COMMAND_OK
        PQclear(risultato);
        return; // Uscita anticipata dalla funzione, dato che sarebbe insensato continuare
    }

    int numero_attributi = PQnfields(risultato);
    int numero_tuple = PQntuples(risultato);

    for (int i = 0; i < numero_attributi; i++) {
        printf("%-30s", PQfname(risultato, i)); // Stampa i titoli degli attributi
    }
    printf("\n");

    for (int i = 0; i < numero_attributi; i++) {
        printf("------------------------------");
    }
    printf("\n");

    for (int i = 0; i < numero_tuple; i++) {
        for (int j = 0; j < numero_attributi; j++) {
            printf("%-30s", PQgetvalue(risultato, i, j));
        }
        printf("\n");
    }
    printf("\n\n\n");

    PQclear(risultato);
}

int main() {
    PGconn* conn = connetti_al_db();
    int scelta = -1;

    const char* array_query[] = {

        // Query 1
        "CREATE OR REPLACE VIEW VenditePerModello AS "
        "SELECT "
        "M.Denominazione_Commerciale, "
        "M.Codice_Telaio, "
        "COUNT(*) AS Numero_Vendite "
        "FROM MODELLO M "
        "JOIN VEICOLO V ON M.Denominazione_Commerciale = V.Denominazione_Commerciale "
        "AND M.Codice_Telaio = V.Codice_Telaio "
        "JOIN ACQUISTO A ON V.VIN = A.Veicolo "
        "GROUP BY M.Denominazione_Commerciale, M.Codice_Telaio; "
        "SELECT * "
        "FROM VenditePerModello "
        "WHERE Numero_Vendite = (SELECT MAX(Numero_Vendite) FROM VenditePerModello); ",

        // Query 2 (parametrica)
        "SELECT D.Matricola, D.Nome, D.Cognome, COUNT(*) AS Vendite "
        "FROM VENDITORE V "
        "JOIN DIPENDENTE D ON V.Matricola = D.Matricola "
        "JOIN ACQUISTO A ON V.Matricola = A.Venditore "
        "WHERE A.Data_Acquisto BETWEEN '%s' AND '%s' "
        "GROUP BY D.Matricola, D.Nome, D.Cognome "
        "HAVING COUNT(*) >= %d ",

        // Query 3
        "SELECT DISTINCT ON (M.Codice_Motore) "
        "M.Codice_Motore, "
        "R.OEM, "
        "R.Nome AS Nome_Ricambio, "
        "SUM(U.Quantita) AS Quantita_Totale "
        "FROM MOTORE M "
        "JOIN MOTORIZZATO_DA MD ON M.Codice_Motore = MD.Motore "
        "JOIN MODELLO MO "
        "ON MD.Denominazione_Commerciale = MO.Denominazione_Commerciale "
        "AND MD.Codice_Telaio = MO.Codice_Telaio "
        "JOIN VEICOLO V "
        "ON MO.Denominazione_Commerciale = V.Denominazione_Commerciale "
        "AND MO.Codice_Telaio = V.Codice_Telaio "
        "JOIN INTERVENTO I ON V.VIN = I.Veicolo "
        "JOIN UTILIZZA U "
        "ON I.Veicolo = U.Veicolo "
        "AND I.Numero_Intervento = U.Numero_Intervento "
        "JOIN RICAMBIO R ON U.Ricambio = R.OEM "
        "GROUP BY M.Codice_Motore, R.OEM, R.Nome "
        "ORDER BY M.Codice_Motore, Quantita_Totale DESC;",

        // Query 4
        "SELECT "
        "M.Frazionamento, "
        "M.Alimentazione, "
        "COUNT(*) AS Numero_Vendite "
        "FROM MOTORE M "
        "JOIN MOTORIZZATO_DA MD ON M.Codice_Motore = MD.Motore "
        "JOIN MODELLO MO "
        "ON MD.Denominazione_Commerciale = MO.Denominazione_Commerciale "
        "AND MD.Codice_Telaio = MO.Codice_Telaio "
        "JOIN VEICOLO V "
        "ON MO.Denominazione_Commerciale = V.Denominazione_Commerciale "
        "AND MO.Codice_Telaio = V.Codice_Telaio "
        "JOIN ACQUISTO A ON V.VIN = A.Veicolo "
        "GROUP BY M.Frazionamento, M.Alimentazione "
        "ORDER BY Numero_Vendite DESC;",

        // Query 5
        "SELECT ROUND(AVG(A.Prezzo), 2) AS Prezzo_Medio_Superbollo "
        "FROM MOTORIZZATO_DA MD "
        "JOIN MODELLO MO "
        "ON MD.Denominazione_Commerciale = MO.Denominazione_Commerciale "
        "AND MD.Codice_Telaio = MO.Codice_Telaio "
        "JOIN VEICOLO V "
        "ON MO.Denominazione_Commerciale = V.Denominazione_Commerciale "
        "AND MO.Codice_Telaio = V.Codice_Telaio "
        "JOIN ACQUISTO A ON V.VIN = A.Veicolo "
        "WHERE MD.Potenza > 250;"
    };

    while (scelta != 0) {
        scelta = mostra_menu();
        if (scelta != 0) {
            if (scelta == 2) {
                char data_inizio[15];
                char data_fine[15];
                int soglia;
                char query_pronta[1000];
                int esito;
                int input_valido = 1;

                printf("Inserire la data di inizio (formato YYYY-MM-DD): ");
                scanf("%14s", data_inizio);
                while(getchar() != '\n'); // Pulizia del buffer di input

                if (strlen(data_inizio) != 10 || data_inizio[4] != '-' || data_inizio[7] != '-') {
                    printf("\nERRORE: Formato data inizio non valido.\n\n");
                    input_valido = 0; // Verranno saltati gli inserimenti successivi e la composizione
                                      // della query, facendo ritorno al menù
                }

                if (input_valido == 1) {
                    printf("Inserisci la data di fine (YYYY-MM-DD): ");
                    scanf("%14s", data_fine);
                    while(getchar() != '\n'); // Pulizia del buffer di input

                    if (strlen(data_fine) != 10 || data_fine[4] != '-' || data_fine[7] != '-') {
                        printf("\nERRORE: Formato data fine non valido.\n\n");
                        input_valido = 0; // Verrà saltato l'inserimento successivo, e la composizione
                                          // della query, facendo ritorno al menù
                    }
                }

                if (input_valido == 1) {
                    printf("Inserisci la soglia minima di vendite: ");
                    esito = scanf("%d", &soglia);
                    while(getchar() != '\n'); // Pulizia del buffer di input, dato che usare scanf() 
                                              // per ricevere interi crea problemi se l'utente digita una lettera

                    if (esito != 1 || soglia < 0) {
                        printf("\nERRORE: La soglia deve essere un numero intero positivo.\n\n");
                        input_valido = 0; // Verrà saltata la composizione della query, facendo ritorno al menù
                    }
                }

                if (input_valido == 1) {
                    snprintf(query_pronta, sizeof(query_pronta), array_query[1], data_inizio, data_fine, soglia); 
                    esegui_e_stampa(conn, query_pronta);

                    /*
                        NOTA SULLA SICUREZZA:
                        Comporre le query parametriche utilizzando snprintf() espone il programma ad attacchi di tipo SQL injection.
                        Attualmente la protezione viene parzialmente assicurata dalla Strict Input Validation (originariamente implementata
                        per evitare crash del programma) sui parametri della query.
                        In un applicativo professionale, andrebbe effettuata una sanificazione totale dell'input grazie alla libreria libpq.
                    */
                }
            }
            else esegui_e_stampa(conn, array_query[scelta-1]);
        }
        else printf("\nUscita dall'applicazione. Arrivederci!\n");
    }

    PQfinish(conn);
    return 0;
}