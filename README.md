# ec2-guacamole-server
Deploy Apache Guacamole (remote desktop) server to AWS EC2

Deploys a guacamole server on a single EC2 Ubuntu 16.04 instance via Ansible. This may suitable for a small to medium team depending on the server size. The playbook requires recent versions of Ansible and boto3.

# Setup
You will need an AWS account ID, region ID, VPC ID, and SSH keypair name. 
After cloning, execute the following command to create a configuration file.  
```mkdir group_vars; cp example-group_vars-all groups_vars/all```   
Customize the (YAML formatted text) group_vars file for your environment.

You will need to have AWS authentication credentials already set up in your environment (environment variables, .aws files, etc.)

# Execution
From the root directory run the following.

```ansible-playbook guacamole-server.yml```

# Post-install Configuration
**IMMEDIATELY LOG IN AND CHANGE THE guacadmin DEFAULT PASSWORD**

Browse to the URL provided by the playbook (https://<publicIP>/guacamole/).
Log in as guacadmin (password is the same as the username). Click on 'guacadmin' in the top right and select settings. Click the Preferences tab. Use the Change password sections to change the password. This is an Internet facing interface so make it a strong one.
  
Refer to the Guacamole Manual for additional setup instructions.
