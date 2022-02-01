#!/usr/bin/bash

# Development: Clears the console upon running this script
if [[ $1 == "--clear" ]]; then
    clear
fi

# Global variables. Dynamically manipulated vars can be omitted, but are there for
# readability
PACKAGES_CONFIG="$(dirname "$0")/packages.json"
DISTRO_ID="" # This is dynamically manipulated by the below section
PACKAGE_MANAGER=""
INSTALL_PACKAGES=""

######################################################################################
# This section assigns values to global variabes                                     #
######################################################################################

command -v "jq" &>/dev/null || { printf "Missing dependency: jq\n" &&
    exit 1; }
DISTRO_ID="$(jq -r '.distributor_id' "$PACKAGES_CONFIG")" || { printf "Could not resolve the distribution ID\n"; exit 1; }
PACKAGE_MANAGER="$(jq -r ".package_manager | .$DISTRO_ID" "$PACKAGES_CONFIG")" || { printf "Could not resolve package manager\n"; exit 1; }
INSTALL_PACKAGES="$(jq -r ".package_install | .$DISTRO_ID" "$PACKAGES_CONFIG")" || { printf "Could not resolve package manager install argument\n"; exit 1; }

# Checks that none of the below variables are null
null_vars=(
    "$PACKAGE_MANAGER"
    "$INSTALL_PACKAGES"
)

for var in "${null_vars[@]}"; do
    if [[ "$var" == "null" ]]; then
        printf "Error: Null values were applied to global variables in unipack.sh\n"
        exit 1
    fi
done

######################################################################################
# This section checks if JSON Query package is# installed and ensures that           #
# packages.json has listed the systems distribution                                  #
######################################################################################

if [[ ${#DISTRO_ID} == 0 ]]; then
    printf "Unipack: No distributor_id was passed\n"
    # Detects distributor_id using lsb_release --id
    (command -v "lsb_release" &>/dev/null && printf "Detecting distributor_id...\n") ||
        { printf "Could not detect the system's distributor. Manually assign it to %s\n" \
            "$PACKAGES_CONFIG" && exit 1; }

    # Creates a new temp file
    # Redirects the newly edited JSON file to this temp file
    # Replaces "$PACKAGES_CONFIG" with the temp file

    trap 'rm -f  "$TMPFILE"' EXIT
    TMPFILE=$(mktemp) || (printf "Failed to edit %s\n" "$PACKAGES_CONFIG" && exit 1)

    lsb=$(lsb_release --id)
    DISTRO_ID="$(printf "%s" "$lsb" | cut -d " " -f 2 | cut -d ":" -f 2 | xargs)"
    jq --arg d "$DISTRO_ID" '.distributor_id = $d' "$PACKAGES_CONFIG" >"$TMPFILE"

    cat "$TMPFILE" >"$PACKAGES_CONFIG"

fi

######################################################################################
# This section checks for missing packages, as states in packages.json. Then, it     #
# prompts the user to confirm to install them                                        #
######################################################################################

# Below var can be omitted, but is there for readability
missing_packages=()

while read -r cmd; do
    command -v "$cmd" &>/dev/null || missing_packages+=("$cmd")
done <<<"$(jq -r ".dependencies | .[] | .$DISTRO_ID" "$PACKAGES_CONFIG")"

if [[ ${#missing_packages} -gt 0 ]]; then
    printf "The application has missing dependencies:\n"
    printf "%s\n" "${missing_packages[@]}"

    # Prompts user to install missing packages
    read -r -p "Would you like to install them? [Y/n] " yn
    if ! [[ "$yn" == "Y" || "$yn" == "y" || "$yn" == "" ]]; then
        exit 1
    fi

    sudo "$PACKAGE_MANAGER" "$INSTALL_PACKAGES" "${missing_packages[@]}" || ( printf "Falied to install packages\n" && exit 1 )
fi

exit 0
