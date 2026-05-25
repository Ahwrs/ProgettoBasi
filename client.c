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
    printf("1) Query 1\n");
    printf("2) Query 2\n");
    printf("3) Query 3\n");
    printf("4) Query 4\n");
    printf("5) Query 5\n");
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
        printf("%-20s", PQfname(risultato, i)); // Stampa i titoli degli attributi
    }
    printf("\n");

    for (int i = 0; i < numero_attributi; i++) {
        printf("--------------------");
    }
    printf("\n");

    for (int i = 0; i < numero_tuple; i++) {
        for (int j = 0; j < numero_attributi; j++) {
            printf("%-20s", PQgetvalue(risultato, i, j));
        }
        printf("\n");
    }

    PQclear(risultato);
}

int main() {
    PGconn* conn = connetti_al_db();
    int scelta = -1;

    const char* array_query[] = {
        "Query 1",
        "Query 2",
        "Query 3",
        "Query 4",
        "Query 5"
    };

    while (scelta != 0) {
        scelta = mostra_menu();
        if (scelta != 0) {
            if (scelta == 5) {
                // Composizione query parametrica
                esegui_e_stampa(conn, array_query[scelta-1]);
            }
            else esegui_e_stampa(conn, array_query[scelta-1]);
        }
        else {
            printf("\nUscita dall'applicazione. Arrivederci!\n");
        }
    }

    PQfinish(conn);
    return 0;
}