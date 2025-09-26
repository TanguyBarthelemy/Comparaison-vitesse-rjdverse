
sudo apt-get update -y
sudo apt-get install -y protobuf-compiler libprotobuf-dev libprotoc-dev
sudo apt-get install -y unzip
sudo apt install -y openjdk-21-jdk

mkdir ~/work/software

curl -Lo ~/work/software/jwsacruncher-3.5.1.zip https://github.com/jdemetra/jdplus-main/releases/download/v3.5.1/jwsacruncher-standalone-3.5.1-linux-x86_64.zip
curl -Lo ~/work/software/jwsacruncher-2.2.6.zip https://github.com/jdemetra/jwsacruncher/releases/download/v2.2.6/jwsacruncher-2.2.6-bin.zip
curl -Lo ~/work/software/install.R https://raw.githubusercontent.com/TanguyBarthelemy/Comparaison-vitesse-rjdverse/refs/heads/main/R/install.R

unzip -o ~/work/software/jwsacruncher-3.5.1.zip -d ~/work/software/
unzip -o ~/work/software/jwsacruncher-2.2.6.zip -d ~/work/software/

chmod +rwx ~/work/software/jwsacruncher-3.5.1/bin/jwsacruncher
chmod +rwx ~/work/software/jwsacruncher-2.2.6/bin/jwsacruncher
chmod +rwx ~/work/software/install.R

Rscript ~/work/software/install.R

PROJECT_DIR=~/work/Comparaison-vitesse-rjdverse
git clone https://github.com/TanguyBarthelemy/Comparaison-vitesse-rjdverse.git $PROJECT_DIR
chown -R onyxia:users $PROJECT_DIR/
cd $PROJECT_DIR
