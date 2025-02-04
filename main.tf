provider "google"{
    
    project = "mythic-inn-420620"
    zone = "us-central1-a"
}

resource "google_compute_network" "no" {
    name = "pipeline"
    

  
}
resource "google_compute_subnetwork" "name" {
    name = "net-okay"
    network = google_compute_network.no.id
    region = "us-central1"
    ip_cidr_range = "10.0.0.0/24"
    
    
  
}
resource "google_compute_firewall" "fire" {
    name = "pipe-fire"
    network = google_compute_network.no.id
  allow {
    protocol = "tcp"
    ports = [22,80,8080]
  }
  source_ranges = ["0.0.0.0"]
}

resource "google_compute_instance_template" "temp1" {
    name ="pipe-temp"
    machine_type = "e2-micro"
    disk {
      boot = true
      auto_delete = true
    source_image = "centos-stream-9"
    }
    network_interface {
      network = google_compute_network.no.id
      subnetwork = google_compute_subnetwork.name.id
    }
    
  
}
resource "google_compute_health_check" "hel" {
    name = "hel"
    http2_health_check {
      port = 80
      request_path = "/"
    }
    unhealthy_threshold = 2
    healthy_threshold = 2
    timeout_sec = 5
    check_interval_sec = 10
  
}
resource "google_compute_instance_group_manager" "man" {
    name = "pipe-manager"
    base_instance_name = "pipe"
    version {
      instance_template = google_compute_instance_template.temp1.self_link_unique

    }
    auto_healing_policies {
      initial_delay_sec = 300
      health_check = google_compute_health_check.hel.self_link
    }
}
resource "google_compute_autoscaler" "scale" {
    name = "pipe-scale"
    target = google_compute_instance_group_manager.man.id
    autoscaling_policy {
      min_replicas = 2
      max_replicas = 5
    }

  
}