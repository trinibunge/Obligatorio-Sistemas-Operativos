/*
 * backup_log.c — Comando auxiliar para myBackup
 * Sistemas Operativos — ORT Uruguay
 *
 * Uso: backup_log <NIVEL> <MENSAJE> <ARCHIVO_LOG>
 *
 * Escribe una entrada formateada con timestamp en el archivo de log.
 * Se compila con: gcc backup_log.c -o backup_log
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_MSG 1024
#define MAX_PATH 512

/* Obtiene el timestamp actual formateado */
void obtener_timestamp(char *buffer, size_t size) {
    time_t ahora = time(NULL);
    struct tm *tm_info = localtime(&ahora);
    strftime(buffer, size, "%Y-%m-%d %H:%M:%S", tm_info);
}

/* Verifica que el nivel sea válido */
int nivel_valido(const char *nivel) {
    return (strcmp(nivel, "INFO")  == 0 ||
            strcmp(nivel, "WARN")  == 0 ||
            strcmp(nivel, "ERROR") == 0);
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Uso: %s <NIVEL> <MENSAJE> <ARCHIVO_LOG>\n", argv[0]);
        fprintf(stderr, "Niveles válidos: INFO, WARN, ERROR\n");
        return EXIT_FAILURE;
    }

    const char *nivel    = argv[1];
    const char *mensaje  = argv[2];
    const char *log_path = argv[3];

    /* Validar nivel */
    if (!nivel_valido(nivel)) {
        fprintf(stderr, "Nivel inválido: %s. Usar INFO, WARN o ERROR.\n", nivel);
        return EXIT_FAILURE;
    }

    /* Validar longitud del mensaje */
    if (strlen(mensaje) > MAX_MSG) {
        fprintf(stderr, "Mensaje demasiado largo (máx %d caracteres)\n", MAX_MSG);
        return EXIT_FAILURE;
    }

    /* Obtener timestamp */
    char timestamp[32];
    obtener_timestamp(timestamp, sizeof(timestamp));

    /* Abrir archivo en modo append */
    FILE *log_file = fopen(log_path, "a");
    if (log_file == NULL) {
        perror("No se pudo abrir el archivo de log");
        return EXIT_FAILURE;
    }

    /* Escribir entrada */
    fprintf(log_file, "[%s] [%-5s] %s\n", timestamp, nivel, mensaje);

    fclose(log_file);
    return EXIT_SUCCESS;
}
