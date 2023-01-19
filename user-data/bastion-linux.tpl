#cloud-config
package_update: True
packages:
  - python3
  - python3-pip
runcmd:
  - pip3 install --upgrade pip
  - pip3 install locust
write_files:
  - path: /root/locustfile.py
    permissions: "0644"
    content: |
      from locust import HttpUser, task

      class HelloWorldUser(HttpUser):
          @task
          def hello_world(self):
            self.client.get("/")
            self.client.get("/postgresql")
            self.client.get("/increment")
            self.client.get("/cpu_load?load=6")
    owner: root:root
