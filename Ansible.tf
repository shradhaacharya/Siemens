/* my-webapp/
├── ansible/
│   ├── playbook.yml       # Ansible playbook to configure the web application
│   └── requirements.yml   # Ansible dependencies
├── main.tf               # Main Terraform configuration
├── variables.tf          # Variables used in the module
└── README.md             # README explaining module inputs and design decisions
*/


resource "aws_launch_template" "web_instance_template" {
  # Define your launch template here
  # Include block device mappings, instance type, etc.

  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y ansible

                # Clone your Ansible playbook repository or copy the playbook to the instance
                git clone <your_ansible_repo_url> /tmp/ansible

                # Run the Ansible playbook
                ansible-playbook /tmp/ansible/playbook.yml
              EOF
}
