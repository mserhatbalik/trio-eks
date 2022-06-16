resource "local_file" "inventory" {
  filename = "./ansible/inventory"
  content = templatefile("./templates/inventory.tftpl",
    {
      do_droplets = "${module.digital_ocean.droplets[*]}"
      aws_bastion = "${module.aws.bastion[*]}"
      workers = "${module.aws.workers[*]}"
  })
    provisioner "local-exec" {
    working_dir = "/home/serhat/Documents/ProDevOpsProjects/trio-eks/ansible"
    command = "ansible-playbook -i inventory trio-final.yml"
  }

  depends_on = [
    module.aws
  ]
}

resource "local_file" "jenkins-casc" {
  filename = "./config/jenkins/jenkcasc.yml"
  content = templatefile("./templates/jenkcasc.tftpl",
    {
      do_droplets = "${module.digital_ocean.droplets}"
  })
}


resource "local_file" "docker-daemon" {
  filename = "./config/jenkins/daemon.json"
  content = templatefile("./templates/daemon.tftpl",
    {
      do_droplets = "${module.digital_ocean.droplets}"
  })

}