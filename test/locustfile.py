from locust import HttpUser, task

class HelloWorldUser(HttpUser):
    @task
    def hello_world(self):
        self.client.get("/")
        self.client.get("/postgresql")
        self.client.get("/increment")
        self.client.get("/cpu_load?load=6")
