#!/bin/sh

echo "v1.16"

echo "Changing ownership of init_dir..."
init_dir="/home/onyxia/.cache/init"
mkdir -p "${init_dir}"
chown -R onyxia:users "${init_dir}"
cd ${init_dir}
echo "init_dir ready - OK"


echo "Downloading the bash files..."
curl -fsSL -O "https://raw.githubusercontent.com/TanguyBarthelemy/onyxia-setup/refs/heads/main/library/setup-cruncher.sh"
curl -fsSL -O "https://raw.githubusercontent.com/TanguyBarthelemy/onyxia-setup/refs/heads/main/init-rproject.sh"
echo "Dowloading is complete - OK"


echo "Changing the ownership..."
chmod +x "setup-cruncher.sh"
chmod +x "init-rproject.sh"
echo "Changed the ownership - OK"


echo "Setting up cruncher..."
"./setup-cruncher.sh"
echo "Env setup - OK"

echo "Setting up project..."
"./init-rproject.sh" TanguyBarthelemy Comparaison-vitesse-rjdverse
echo "R project setup - OK"
