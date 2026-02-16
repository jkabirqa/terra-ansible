🌐 Terraform + Ansible Automated Web Server Deployment






Automate the provisioning of EC2 instances using Terraform and configure a dynamic web server deployment using Ansible. Works across Debian/Ubuntu and RedHat/CentOS/Amazon Linux.

📂 Repository Structure
terra-ansible/
├── inventory.ini         # Ansible inventory for managed hosts
├── my-playbook.yml       # Dynamic, OS-aware Ansible playbook
├── html/
│    └── index.html       # Web page to serve via Apache
├── keys/
│    └── terra-ansible.pem  # SSH key (never commit private key!)
├── README.md
└── .gitignore

⚙️ Prerequisites

Ubuntu 20.04+ or Debian-based control node

Terraform installed (terraform --version)

Ansible installed (ansible --version)

Python 3 on remote hosts

AWS EC2 instances with SSH key access

🛠 Installation & Setup
1️⃣ Install Ansible
sudo apt update
sudo apt-add-repository ppa:ansible/ansible
sudo apt install ansible -y
ansible --version

2️⃣ Configure SSH Keys
mkdir -p ~/keys
cd ~/keys/
vim terra-ansible.pem       # Paste your EC2 private key
chmod 400 terra-ansible.pem


Test connection:

ssh -i ~/keys/terra-ansible.pem ubuntu@<EC2_PUBLIC_IP>

3️⃣ Configure Ansible Inventory

Create inventory.ini:

[servers]
54.196.226.76 ansible_user=ubuntu ansible_ssh_private_key_file=~/keys/terra-ansible.pem
3.86.70.111 ansible_user=ec2-user ansible_ssh_private_key_file=~/keys/terra-ansible.pem


Verify:

ansible-inventory -i inventory.ini --list
ansible all -m ping -i inventory.ini

4️⃣ Clone Repository
git clone https://github.com/jkabirqa/terra-ansible.git
cd terra-ansible/

5️⃣ Prepare Playbook & HTML

my-playbook.yml (dynamic, OS-aware):

- hosts: all
  become: true
  vars:
    web_root: /var/www/html
    web_file: index.html

  tasks:
    - name: Install web server
      package:
        name: "{{ 'apache2' if ansible_facts['os_family'] == 'Debian' else 'httpd' }}"
        state: present

    - name: Ensure web root exists
      file:
        path: "{{ web_root }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Copy index.html
      copy:
        src: "html/{{ web_file }}"
        dest: "{{ web_root }}/{{ web_file }}"
        owner: root
        group: root
        mode: '0644'

    - name: Ensure web server is running
      service:
        name: "{{ 'apache2' if ansible_facts['os_family'] == 'Debian' else 'httpd' }}"
        state: started
        enabled: yes


Place your index.html in the html/ folder.

6️⃣ Run Ansible Playbook
ansible-playbook -i inventory.ini my-playbook.yml


Check the website:

curl http://54.196.226.76
curl http://3.86.70.111

7️⃣ Terraform Deployment (Optional)
terraform init
terraform plan
terraform apply

💻 Git Workflow
git init
git add .
git commit -m "initial commit"
git remote add origin git@github.com:jkabirqa/terra-ansible.git
git push origin master


Update playbooks:

git add .
git commit -m "updated playbook as dynamic"
git push origin master

⚡ Best Practices

Always chmod 400 for SSH private keys

Use ansible_facts['os_family'] for cross-OS compatibility

Keep project structure clean: html/, inventory.ini, playbooks/

Never commit private keys; use .gitignore

Use generic package module instead of hardcoding apt/yum

🎯 Outcome

Multi-OS Apache web server deployed

Dynamic index.html copied to /var/www/html/

Fully managed via Ansible, integrated with Terraform infrastructure

🏆 Live Demo

Access deployed web page:

http://54.196.226.76
http://3.86.70.111
