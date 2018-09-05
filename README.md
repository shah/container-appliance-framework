# The Container Appliance Framework (CAF)
CAF is an opinionated set of building blocks for building portable micro servers. These "appliances" can be developer sandboxes or small servers that act as gateways for B2B or other enterprise applications.

Prerequisites:

* Ubuntu 18.04+ LTS server
* user with sudo privileges

Install basic utilities:

    sudo apt install make git net-tools curl wget

Intial setup:

    git clone shah/container-appliance-framework CAF
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
