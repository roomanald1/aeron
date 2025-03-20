job "rust_application" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

    network {
      port "publisher" {
        to = 50000
      }
    }

    service {
      name = "rust_application"
      port = "publisher"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "publisher" {
      driver = "docker"

      config {
        image = "ronnieday/rust_application:0.0.1"
        load  = "ronnieday/rust_application:0.0.1"  # Load the local image
        shm_size = 1024
        ports = ["publisher"]
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 256  # 256MB
      }
    }
  }
}