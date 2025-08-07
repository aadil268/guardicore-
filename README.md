# Terraform: Azure Windows VM with Guardicore Agent.

This project provisions a Windows Virtual Machine in Azure using Terraform, and configures it to Install **Guardicore** Agent.

---

## 📁 Project Structure

```

.
├── main.tf                             # Terraform configuration
├── variables.tf                        # Input variables
├── terraform.tfvars                    # Sensitive values (ignored by git)
├── README.md                           # Readme File
├── .gitignore                          # Git ignore rules
├── guardicore_windows_installer.exe    # Guardicore Installer
└── install_guardicore_agent.ps1        # Guardicore Insaller Script


````

---

## 🚀 Features

- Provision Windows Server 2022 VM on Azure
- Download and Install Guardicore on VM
- Install and execute a Windows command script at first boot using Cloudbase-Init
- Secure configuration via `terraform.tfvars`
- Storage account, virtual network, subnet, NIC, NSG, Public IP auto-created

---

## 🔧 Usage

### 1. Configure your variables

Update `terraform.tfvars` with your Azure subscription ID and desired settings:

```hcl
subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
guardicore_token = "XXXXXXXXXXXXXXXXXXXX"
guardicore_idp_hostname = "xxxx.xxx.xxx.com:443"
guardicore_exe_url = "https://raw.githubusercontent.com/aadil268/guardicore-/main/guardicore_windows_installer.exe"
guardicore_script_url = "https://raw.githubusercontent.com/aadil268/guardicore-/main/install_guardicore_agent.ps1"
````

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the plan

```bash
terraform plan
```

### 4. Apply the configuration

```bash
terraform apply
```

---

## 📜 Requirements

* Terraform CLI ≥ 1.0
* Azure CLI authenticated (`az login`)

---

## 🔒 Security

Ensure `terraform.tfvars` is excluded from version control:

```
terraform.tfvars
```

---

## 📄 License

MIT License