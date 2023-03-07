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
### Module Inputs
* Values that you submit to Terraform code at runtime mode.
* They are defined inside **module block**
* Basically it's defining the inputs variables from the module we are consuming.
```
module "<NAME>" {
	source = "<SOURCE>"
	
	variable1 = "asd"
	variable2 = 123
}
```
### Module Locals
* Same as variables but its use case is when you don’t want to use a configurable variable. You want not to repeat yourself but neither expose a variable as configurable input.
* They are calculated internally, not inputed to your code. That’s why they are “locals”.
* They are available only within that “root module”, within that configuration only.
* Syntax example (go to the module, then create locals.tf or inside main.tf):
```
locals {
    http_port    = 80
    ssh_port     = 22
    any_port     = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips      = ["0.0.0.0/0"]
}
```
### Module Outputs
* In Terraform, a module can also return values. Again, you do this using a
mechanism you already know: output variables.
* First you define the output variable in ***module/outputs.tf***, then you do the same in the folder where you configure/make us of the module. But in this case with the following syntax:
```
output "output-name" {
    value = module.module-name.output-name
}
```
### FilePaths
* In chapter 3, we defined a “user data” script for the web server cluster into an external file, userdata.sh, and used the **templatefile** bulit-in function to read this file from disk. The catch with the **templatefile** function is that the file path you use must be a relative path.
* By default, TF interprets the path relative to the current working directory. That works if you’re using the **templatefile** function in a tf configuration file that’s in the same directory as where you’re running **terraform apply**, but that won’t work when you’re using **templatefile** in a module that’s defined in a separate folder.
* To solve this issue, you can use an expression known as **path reference**, which is of the form **path.<TYPE>.** TF supports the following types of paths references:
    * **path.module** = returns the filesystem path of the module where the expression is defined.
    * **path.root** = returns the filesystem path of the root module
    * **path.cwd** = returns the filesystem path of the current working directory.

