job "aeronmd" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

    restart {
      attempts = 3    # Number of restarts allowed
      interval = "5m" # Time window for restarts
      delay    = "10s" # Delay between restarts
      mode     = "fail" # Restart only if the task fails (non-zero exit code)
    }

    reschedule {
      attempts       = 2    # Number of rescheduling attempts
      interval       = "1h" # Time window for rescheduling
      unlimited      = false # Do not allow unlimited rescheduling
      delay          = "30s" # Delay before rescheduling
      delay_function = "exponential" # Use exponential backoff for delays
      max_delay      = "1h" # Maximum delay between reschedules
    }

    network {
      port "driver" {
        to = 40123
      }
    }

    service {
      name = "aeronmd"
      port = "driver"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "media-driver" {
      driver = "docker"

      config {
        privileged = true
        shm_size = 1024
        image = "ronnieday/aeron-md:0.0.1"
        ports = ["driver"]
      }

      resources {
        cpu    = 1000  
        memory = 512  
      }
    }
  }
}