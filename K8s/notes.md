vagrant init centos/8
vagrant up
vagrant ssh

cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yum -y install git python3 python3-pip docker
pip install --upgrade pip
pip3 install --user Rust setuptools_rust
pip3 install --user ansible

git clone https://github.com/geerlingguy/ansible-role-kubernetes.git roles/kubernetes/
cd ansible-role-kubernetes/ 