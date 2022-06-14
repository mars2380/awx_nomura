vagrant init centos/8
vagrant up
vagrant ssh

cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum -y install git python3 python3-pip

dnf install docker -y
dnf install epel-release -y
dnf makecache
dnf install ansible -y

git clone https://github.com/geerlingguy/ansible-role-kubernetes.git roles/kubernetes/
cd ansible-role-kubernetes/ 