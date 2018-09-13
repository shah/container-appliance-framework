# The Container Appliance Framework (CAF)
CAF is an opinionated set of building blocks for creating and deploying portable micro servers using
Git as a delivery vehicle. These "appliances" can be developer sandboxes or small servers that act as
gateways for B2B or other enterprise applications.

Prerequisites:

* Ubuntu 18.04+ LTS server
* user with sudo privileges

Install basic utilities:

    sudo apt install make git net-tools curl wget

Intial setup:

    git clone https://github.com/shah/container-appliance-framework CAF
    cd CAF

    make switch-to-zsh

Exit the shell, log back in.
*If you are greeted with a Zsh shell configuration prompt, select "2" to accept default settings.*

Exit the shell again, log back in. Then:

    cd CAF
    make install-oh-my-zsh

Exit the shell, log back in. Then:

    cd CAF
    make setup-oh-my-zsh

Exit the shell, log back in. Then:

    cd CAF
    make check-dependencies

Follow instructions to install all dependencies.

## Secrets Management

The CAF_HOME/secrets directory is where all secrets across all containers are kept. The convention is
to create a file called *container-name*.secrets.jsonnet and place it in the **CAF_HOME/.secrets** directory,
which is in the jsonnet path (--jpath in CAF_HOME/lib/Makefile:configure target).

The *container-name*.secrets.conf.jsonnet is then import'd by container.defn.jsonnet in a particular
container. Because --jpath includes the CAF_HOME/.secrets directory, it will find the secrets jsonnet
configuration files easily.

NOTE: *The CAF_HOME/secrets directory is in CAF_HOME/.gitignore so it will not be tracked by Git.*
To help get started with CAF, the CAF_HOME/Makefile copies lib/secrets-default to CAF_HOME/screts when
the *check-dependencies* target is run.