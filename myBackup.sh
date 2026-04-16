
#!/bin/bash
 
#############################################################################
# myBackup - Script de Backup Automático para Linux
# Descripción: Automatiza tareas de backup con soporte para encriptación,
#              compresión, programación automática e interfaz por menús
# Autor: Grupo Angel Caffa
# Fecha: 2026
#############################################################################
ORIGEN=""
DESTINO="$HOME/backups"
VERBOSE=false
COMPRIMIR=true
ENCRIPTAR=false
RETENCION=7          # días que se guardan los backups
FRECUENCIA="0 2 * * *"  # cron: todos los días a las 2am
LOG_FILE="$HOME/.mybackup.log"
CONF_FILE="$HOME/.myBackup.conf"

# ---------------------------------------------------------------------------
# Colores para output
# ---------------------------------------------------------------------------
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # sin color

# ---------------------------------------------------------------------------
# Funciones auxiliares
# ---------------------------------------------------------------------------

log() {
    local nivel="$1"
    local mensaje="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Escribir en log usando el comando C si existe, sino usar echo
    if command -v backup_log &>/dev/null; then
        backup_log "$nivel" "$mensaje" "$LOG_FILE"
    else
        echo "[$timestamp] [$nivel] $mensaje" >> "$LOG_FILE"
    fi

    # Si verbose, también mostrar en pantalla
    if $VERBOSE; then
        case "$nivel" in
            INFO)  echo -e "${VERDE}[INFO]${NC}  $mensaje" ;;
            WARN)  echo -e "${AMARILLO}[WARN]${NC}  $mensaje" ;;
            ERROR) echo -e "${ROJO}[ERROR]${NC} $mensaje" ;;
        esac
    fi
}

mostrar_ayuda() {
    echo ""
    echo -e "${AZUL}myBackup${NC} — Script de backup automatizado"
    echo ""
    echo "Uso:"
    echo "  ./myBackup.sh [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -d <directorio>   Directorio origen del backup"
    echo "  -o <destino>      Directorio destino del backup"
    echo "  -v                Verbose: mostrar detalles en pantalla"
    echo "  -n                No comprimir (por defecto comprime)"
    echo "  -e                Encriptar con GPG"
    echo "  -r <días>         Retención: días a guardar los backups (default: 7)"
    echo "  -c <archivo>      Archivo de configuración alternativo"
    echo "  -i                Instalar en cron"
    echo "  -m                Abrir menú interactivo"
    echo "  -h                Mostrar esta ayuda"
    echo ""
}

cargar_conf() {
    if [ -f "$CONF_FILE" ]; then
        # shellcheck source=/dev/null
        source "$CONF_FILE"
        log "INFO" "Configuración cargada desde $CONF_FILE"
    fi
}

verificar_dependencias() {
    local faltantes=()

    if ! command -v tar &>/dev/null; then
        faltantes+=("tar")
    fi

    if $ENCRIPTAR && ! command -v gpg &>/dev/null; then
        faltantes+=("gpg")
    fi

    if [ ${#faltantes[@]} -gt 0 ]; then
        echo -e "${ROJO}[ERROR]${NC} Dependencias faltantes: ${faltantes[*]}"
        echo "Instalá con: sudo apt install ${faltantes[*]}"
        exit 1
    fi
}

instalar_cron() {
    local script_path
    script_path=$(realpath "$0")
    local entrada_cron="$FRECUENCIA $script_path -d \"$ORIGEN\" -o \"$DESTINO\""

    # Verificar si ya está instalado
    if crontab -l 2>/dev/null | grep -q "$script_path"; then
        echo -e "${AMARILLO}[WARN]${NC}  myBackup ya está en cron."
        read -r -p "¿Sobreescribir? [s/N]: " respuesta
        if [[ ! "$respuesta" =~ ^[Ss]$ ]]; then
            return
        fi
        # Eliminar entrada anterior
        crontab -l 2>/dev/null | grep -v "$script_path" | crontab -
    fi

    # Agregar nueva entrada
    (crontab -l 2>/dev/null; echo "$entrada_cron") | crontab -
    echo -e "${VERDE}[INFO]${NC}  Cron instalado: $entrada_cron"
    log "INFO" "Cron instalado con frecuencia: $FRECUENCIA"
}

limpiar_backups_viejos() {
    if [ -d "$DESTINO" ] && [ "$RETENCION" -gt 0 ]; then
        local eliminados
        eliminados=$(find "$DESTINO" -name "backup_*.tar*" -mtime +"$RETENCION" -print)
        if [ -n "$eliminados" ]; then
            find "$DESTINO" -name "backup_*.tar*" -mtime +"$RETENCION" -delete
            log "INFO" "Backups eliminados por retención ($RETENCION días): $(echo "$eliminados" | wc -l) archivo(s)"
        fi
    fi
}

hacer_backup() {
    # Validaciones
    if [ -z "$ORIGEN" ]; then
        echo -e "${ROJO}[ERROR]${NC} Directorio origen no especificado. Usá -d o configurá ORIGEN en .myBackup.conf"
        exit 1
    fi

    if [ ! -d "$ORIGEN" ]; then
        echo -e "${ROJO}[ERROR]${NC} El directorio origen no existe: $ORIGEN"
        exit 1
    fi

    # Crear destino si no existe
    mkdir -p "$DESTINO"

    # Nombre del archivo de backup con timestamp
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local nombre_base="backup_${timestamp}"
    local archivo_destino

    log "INFO" "Iniciando backup: $ORIGEN -> $DESTINO"

    # Comprimir o no
    if $COMPRIMIR; then
        archivo_destino="$DESTINO/${nombre_base}.tar.gz"
        tar -czf "$archivo_destino" -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")" 2>/dev/null
    else
        archivo_destino="$DESTINO/${nombre_base}.tar"
        tar -cf "$archivo_destino" -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")" 2>/dev/null
    fi

    if [ $? -ne 0 ]; then
        log "ERROR" "Falló la creación del backup"
        echo -e "${ROJO}[ERROR]${NC} Falló la creación del backup"
        exit 1
    fi

    local tamanio
    tamanio=$(du -sh "$archivo_destino" | cut -f1)
    log "INFO" "Backup creado: $archivo_destino ($tamanio)"

    # Encriptar si se pidió
    if $ENCRIPTAR; then
        if [ -z "$GPG_RECIPIENT" ]; then
            echo -e "${ROJO}[ERROR]${NC} Encriptación activada pero GPG_RECIPIENT no está configurado en .myBackup.conf"
            exit 1
        fi
        gpg --recipient "$GPG_RECIPIENT" --encrypt "$archivo_destino"
        if [ $? -eq 0 ]; then
            rm "$archivo_destino"   # eliminar versión sin encriptar
            archivo_destino="${archivo_destino}.gpg"
            log "INFO" "Backup encriptado: $archivo_destino"
        else
            log "ERROR" "Falló la encriptación"
            echo -e "${ROJO}[ERROR]${NC} Falló la encriptación"
            exit 1
        fi
    fi

    # Limpiar backups viejos
    limpiar_backups_viejos

    echo -e "${VERDE}[OK]${NC} Backup completado: $archivo_destino ($tamanio)"
    log "INFO" "Backup completado exitosamente"
}

# ---------------------------------------------------------------------------
# Menú interactivo con dialog
# ---------------------------------------------------------------------------
menu_interactivo() {
    if ! command -v dialog &>/dev/null; then
        echo -e "${ROJO}[ERROR]${NC} 'dialog' no está instalado."
        echo "Instalá con: sudo apt install dialog"
        exit 1
    fi

    while true; do
        OPCION=$(dialog --clear --backtitle "myBackup — Sistema de backup" \
            --title "Menú principal" \
            --menu "Elegí una opción:" 15 50 6 \
            1 "Hacer backup ahora" \
            2 "Configurar parámetros" \
            3 "Instalar en cron" \
            4 "Ver log" \
            5 "Salir" \
            3>&1 1>&2 2>&3)

        case $OPCION in
            1)
                # Pedir origen si no está configurado
                if [ -z "$ORIGEN" ]; then
                    ORIGEN=$(dialog --inputbox "Directorio origen:" 8 50 "$HOME" 3>&1 1>&2 2>&3)
                fi
                clear
                hacer_backup
                read -r -p "Presioná Enter para continuar..."
                ;;
            2)
                menu_configuracion
                ;;
            3)
                clear
                instalar_cron
                read -r -p "Presioná Enter para continuar..."
                ;;
            4)
                if [ -f "$LOG_FILE" ]; then
                    dialog --textbox "$LOG_FILE" 20 70
                else
                    dialog --msgbox "No hay log todavía." 6 40
                fi
                ;;
            5|"")
                clear
                exit 0
                ;;
        esac
    done
}

menu_configuracion() {
    ORIGEN=$(dialog --inputbox "Directorio origen:" 8 50 "$ORIGEN" 3>&1 1>&2 2>&3)
    DESTINO=$(dialog --inputbox "Directorio destino:" 8 50 "$DESTINO" 3>&1 1>&2 2>&3)
    RETENCION=$(dialog --inputbox "Días de retención:" 8 50 "$RETENCION" 3>&1 1>&2 2>&3)

    COMP_OPCION=$(dialog --menu "¿Comprimir backups?" 10 40 2 \
        1 "Sí" 2 "No" 3>&1 1>&2 2>&3)
    [ "$COMP_OPCION" = "2" ] && COMPRIMIR=false || COMPRIMIR=true

    ENC_OPCION=$(dialog --menu "¿Encriptar con GPG?" 10 40 2 \
        1 "Sí" 2 "No" 3>&1 1>&2 2>&3)
    if [ "$ENC_OPCION" = "1" ]; then
        ENCRIPTAR=true
        GPG_RECIPIENT=$(dialog --inputbox "Email/ID del destinatario GPG:" 8 50 "$GPG_RECIPIENT" 3>&1 1>&2 2>&3)
    else
        ENCRIPTAR=false
    fi

    # Guardar en conf
    guardar_conf
    dialog --msgbox "Configuración guardada en $CONF_FILE" 6 50
}

guardar_conf() {
    cat > "$CONF_FILE" <<EOF
# myBackup configuración — generado automáticamente
ORIGEN="$ORIGEN"
DESTINO="$DESTINO"
RETENCION=$RETENCION
COMPRIMIR=$COMPRIMIR
ENCRIPTAR=$ENCRIPTAR
GPG_RECIPIENT="$GPG_RECIPIENT"
FRECUENCIA="$FRECUENCIA"
LOG_FILE="$LOG_FILE"
EOF
    log "INFO" "Configuración guardada en $CONF_FILE"
}

# ---------------------------------------------------------------------------
# Parseo de argumentos
# ---------------------------------------------------------------------------

# Primero cargar conf, después CLI sobreescribe
cargar_conf

while getopts "d:o:r:c:vneimh" opt; do
    case $opt in
        d) ORIGEN="$OPTARG" ;;
        o) DESTINO="$OPTARG" ;;
        r) RETENCION="$OPTARG" ;;
        c) CONF_FILE="$OPTARG"; cargar_conf ;;
        v) VERBOSE=true ;;
        n) COMPRIMIR=false ;;
        e) ENCRIPTAR=true ;;
        i) INSTALAR_CRON=true ;;
        m) MENU=true ;;
        h) mostrar_ayuda; exit 0 ;;
        *) mostrar_ayuda; exit 1 ;;
    esac
done

# ---------------------------------------------------------------------------
# Ejecución
# ---------------------------------------------------------------------------

verificar_dependencias

if [ "${MENU:-false}" = true ]; then
    menu_interactivo
elif [ "${INSTALAR_CRON:-false}" = true ]; then
    instalar_cron
else
    hacer_backup
fi
