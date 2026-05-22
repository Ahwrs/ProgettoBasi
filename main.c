#include <stdio.h>
#include <postgresql/libpq-fe.h>

int main() {
    char* s = "Ciao";
    s[0] = 'M';
    printf("%s", s);
}