# HackathonGroup4ProjectInfra

Infrastructure for the Hackathon Group 4 project.

## To build
Ensure that you have the latest Terraform, Python 3, Pip installations, etc.
You will also need `aws-cli` configured with the proper credentials to the target AWS account.

1. Run `build_app.bat` in `./lambda`.
2. `terraform init`.
3. `terraform plan` - ensure that the infrastructure listed are correct.
4. `terraform apply`.
