job "aeronmd" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

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
        image = "ronnieday/aeron-md:0.0.1"
        shm_size = 536870912
        command = "java"
         args    = [
          "--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED",
          "-cp", "aeron-all-1.47.5-SNAPSHOT.jar",
          "io.aeron.driver.MediaDriver"
        ]
         ports = ["driver"]
      }

      resources {
        cpu    = 1000  
        memory = 512  
      }
    }
  }
}