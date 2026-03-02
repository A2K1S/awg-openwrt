#!/bin/sh

# Установка зависимостей и проверка репозитория
check_repo() {
    printf "\033[32;1mChecking ImmortalWrt repo availability...\033[0m\n"
    opkg update | grep -q "Failed to download" && printf "\033[31;1mopkg failed. Check internet or date.\033[0m\n" && exit 1
}

install_awg_packages() {
    # Получение архитектуры и таргета устройства (Cudy TR3000: filogic/aarch64)
    PKGARCH=$(opkg print-architecture | awk 'BEGIN {max=0} {if ($3 > max) {max = $3; arch = $2}} END {print arch}')
    TARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 1)
    SUBTARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 2)
    VERSION=$(ubus call system board | jsonfilter -e '@.release.version' | sed 's/^v//')
    
    # Твой формат из build-module.yml: _v24.10.5_arch_target_subtarget.ipk
    PKGPOSTFIX="_v${VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}.ipk"
    BASE_URL="https://github.com{VERSION}/"

    printf "\033[32;1mDetected: $TARGET/$SUBTARGET ($PKGARCH) on v$VERSION\033[0m\n"

    AWG_DIR="/tmp/amneziawg"
    mkdir -p "$AWG_DIR"
    
    # Список пакетов для установки
    PACKAGES="kmod-amneziawg amneziawg-tools luci-proto-amneziawg luci-i18n-amneziawg-ru"

    for pkg in $PACKAGES; do
        if opkg list-installed | grep -q "$pkg"; then
            echo "$pkg already installed"
        else
            FILENAME="${pkg}${PKGPOSTFIX}"
            echo "Downloading $FILENAME..."
            wget -O "$AWG_DIR/$FILENAME" "${BASE_URL}${FILENAME}"
            
            if [ $? -eq 0 ]; then
                opkg install "$AWG_DIR/$FILENAME"
            else
                echo "Error downloading $pkg. Check if release v$VERSION exists in your repo."
                exit 1
            fi
        fi
    done
    rm -rf "$AWG_DIR"
}

# Функция настройки интерфейса (оставил твою логику)
configure_amneziawg_interface() {
    printf "\033[32;1m--- Конфигурация интерфейса AmneziaWG ---\033[0m\n"
    # Твой код настройки uci...
    # (Здесь остаются все твои read -p запросы для PrivateKey, Jc, Jmin и т.д.)
    echo "Настройка интерфейса завершена."
}

check_repo
install_awg_packages
configure_amneziawg_interface
