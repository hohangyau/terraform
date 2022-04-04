# terraform

This module creates on-demand aws-vpc resources.

Steps to run:
1. clone repo to local dir
2. run "terraform init" command
3. run "terraform apply --var-file=env/dev.json" command
4. Resources shall be created

Some Terraform best practices
1. Isolate environments using terraform workspace feature:
  - Create new environment using "terraform new workspace ${env_name}" command
  - Select desired environment using "terraform workspace select ${env_name}" command

2. Separately store variables' values in env/${env_name}.json files
3. Update all tfstates files to git by environment
4. Always pull latest tfstates files from git whenever one operates on aws resources.  
5. Turn on debug mode using "TF_LOG=true" command
