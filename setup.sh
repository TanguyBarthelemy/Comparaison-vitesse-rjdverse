
sudo apt-get update -y
sudo apt-get install -y protobuf-compiler libprotobuf-dev libprotoc-dev
sudo apt-get install -y unzip
sudo apt install -y openjdk-21-jdk

curl -LO https://github.com/jdemetra/jdplus-main/releases/download/v3.5.1/jwsacruncher-standalone-3.5.1-linux-x86_64.zip
curl -LO https://github.com/jdemetra/jwsacruncher/releases/download/v2.2.6/jwsacruncher-2.2.6-bin.zip

unzip -o jwsacruncher-standalone-3.5.1-linux-x86_64.zip
unzip -o jwsacruncher-2.2.6-bin.zip

chmod +rwx jwsacruncher-3.5.1/bin/jwsacruncher
chmod +rwx jwsacruncher-2.2.6/bin/jwsacruncher

Rscript Comparaison-vitesse-rjdverse/R/install.R
