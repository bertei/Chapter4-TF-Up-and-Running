# In this repository I'll upload personal notes and code of Chapter 4 (Terraform modules) - Terraform up and running
## Terraform Modules
* With Terraform, you can put your code inside of a Terraform module and reuse that module in multiple places throughout your code. Instead of having the same code copied and pasted in the staging and production environments, you’ll be able to have both environments reuse code from the same module.
* Modules are the key ingredient to writing reusable, maintainable, and testable Terraform code.
### Modules Basics
* Any set of TF config files in a folder is a module. If you run apply directly on a module it’s referred to as **root** module.
* Providers should be configured only in **root modules** and not in **reusable modules**.
* Module syntax:
```
module "<NAME>" {
	source = "<SOURCE>"
	[CONFIG...]
}

NAME = identifier you can use throughout TF code to refer to this module.
SOURCE = is the path where the module code can be found
CONFIG = consists of arguments that are specific to that module
```
* Whenever you add a module to your tf config or modify the source parameter of a module, you need to run the init command before you run plan or apply.

