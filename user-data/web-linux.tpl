#cloud-config
package_update: True
packages:
  - python3
  - python3-pip
write_files:
  - path: /root/ansible_variables.yml
    permissions: "0644"
    content: |
      ${ansible_variables}
    owner: root:root
  - path: /root/ansible_playbook.yml
    permissions: "0644"
    content: |
      - hosts: localhost
        collections:
          - ${ansible_namespace}.${ansible_collection}
        roles:
    %{ for role in ansible_roles ~}
      - ${role}
    %{ endfor ~}
    
    owner: root:root
  - path: /root/terraform_service_credentials.json
    permissions: "0644"
    content: |
      ${service_credentials}
    owner: root:root
runcmd:
  - python3 -m pip install ansible
  - ansible-galaxy collection install git+${ansible_url}#/${ansible_namespace}/${ansible_collection}
  - cd /root; ansible-playbook --extra-vars @ansible_variables.yml ansible_playbook.yml