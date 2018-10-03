Role Name
=========

Install a minimal Python environment to enable Ansible

Requirements
------------

None

Role Variables
--------------

**bootstrap_os** - Specify the flavor of OS of the target system. 
One of ("ubuntu", "debian", "coreos", "centos"m "opensuse")

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
        - bootstrap_os
      vars:
        bootstrap_so: "ubuntu"

License
-------

MIT

Author Information
------------------

