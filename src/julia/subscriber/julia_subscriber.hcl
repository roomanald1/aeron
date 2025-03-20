job "julia_subscriber" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

    network {
      port "http" {
        to = 8000
      }
    }

    service {
      name = "julia_subscriber"
      port = "http"

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "ronnieday/julia_subscriber:0.0.1"
        ports = ["http"]
        load  = "ronnieday/julia_subscriber:0.0.1"  # Load the local image
        ipc_mode = "task:media-driver"
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 256  # 256MB
      }
    }
  }
}