provider "ibm" {
   #softlayer_username = "FILL_IN_PLEASE"
   #softlayer_api_key = "FILL_IN_PLEASE"
   #bluemix_api_key = "FILL_IN_PLEASE"
}

# Create an SSH key. The SSH key surfaces in the SoftLayer console under Devices > Manage > SSH Keys.
resource "ibm_compute_ssh_key" "test_key_1" {
  label      = "${var.keylabel}"
  public_key = "${file("~/.ssh/id_rsa.pub")}"

  # Windows example:
  # public_key = "${file(\"C:\ssh\keys\path\id_rsa_test_key_1.pub\")}"
}

# Create a VLAN
resource "ibm_network_vlan" "privateVlan1" {
   name = "test_vlan"
   datacenter = "${var.datacenter}" 
   type = "PRIVATE"
   subnet_size = 8
}

#Create block storage
resource "ibm_storage_block" "bockStorage1" {
        type = "Performance"
        datacenter = "${var.datacenter}"
        capacity = 20
        iops = 100
        os_format_type = "Linux"
}

#Create VM
resource "ibm_compute_vm_instance" "vj_vm_instances" {
  count          = "${var.vm_count}"
  hostname       ="${format("vj-paul-example-%02d", count.index + 1)}"
  domain         = "ibm.com"
  datacenter     = "${var.datacenter}"
  block_storage_ids = ["${ibm_storage_block.bockStorage1.id}"]
  network_speed     = 10 
  ssh_key_ids          = ["${ibm_compute_ssh_key.test_key_1.id}"]
  hourly_billing = true
  cores          = "1"
  memory         = "1024"
  disks          = ["25"]
  local_disk     = false
  image_id       = 1707661 #Assumes you have a vm template created and uploaded to SL portal and its id is 1707661
  private_network_only = true
}
