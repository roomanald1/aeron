job "aeron_demo" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

    network {
      port "driver" {
        to = 40123
      }
      port "http" {
        to = 8000
      }
    }

    task "media-driver" {
      driver = "docker"

      config {
        image = "ronnieday/aeron-md:0.0.1"
        shm_size = 536870912  # 512MB of shared memory
        command = "java"
        ipc_mode = "host"
        args    = [
          "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED",
          "-cp", "aeron-all-1.47.5-SNAPSHOT.jar",
          "io.aeron.driver.MediaDriver"
        ]
        ports = ["driver"]
      }

      resources {
        cpu    = 1000  # 1000 MHz
        memory = 512   # 512MB
      }
    }

    task "julia_subscriber" {
      driver = "docker"

      config {
        image = "ronnieday/julia_subscriber:0.0.2"
        ports = ["http"]
        ipc_mode = "host"  # Share IPC namespace with the "media-driver" task
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 256  # 256MB
      }
    }

    task "julia_publisher" {
      driver = "docker"

      config {
        image = "ronnieday/julia_publisher:0.0.2"
        ports = ["http"]
        ipc_mode = "host"  # Share IPC namespace with the "media-driver" task
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 256  # 256MB
      }
    }

   task "rust_publisher" {
      driver = "docker"

      config {
        image = "ronnieday/rust_aeron:0.0.2"
        ports = ["http"]
        command = "./app/aeron_test"
        ipc_mode = "host"  # Share IPC namespace with the "media-driver" task
        network_mode = "host"
      }

      env {
        MODE = "publisher"
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 256  # 256MB
      }
    }

    task "rust_subscriber" {
      driver = "docker"

      env {
        MODE = "subscriber"
      }

      config {
        image = "ronnieday/rust_aeron:0.0.2"
        ports = ["http"]
        command = "./app/aeron_test"
        ipc_mode = "host"  # Share IPC namespace with the "media-driver" task
        network_mode = "host"
      }

      resources {
        cpu    = 500  # 500 MHz
        memory = 256  # 256MB
      }
    }
  }
}