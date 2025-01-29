For installing terraform

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

for creating sshkey

 ssh-keygen -t rsa -b 2048 -f ./sshkey
