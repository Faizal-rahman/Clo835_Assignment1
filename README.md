# Clo835_Assignment1
For installing terraform

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

for creating sshkey

ssh-keygen -t rsa -b 2048 -f ./sshkey


git config --global user.name "Faizal"
git config --global user.email "Faizalrahman2000@gmail.com"

docker exec -it sql_container mysql -u root -p
docker exec -it blue-container sh
apt install inetutils-ping