### Windows Subsytem for Linux (wsl)

WSL allows Windows users to run Linux (Unix) [locally at a system-level](https://docs.microsoft.com/en-us/windows/wsl/compare-versions). All of the standard tooling is used and community guides can be followed without standard Windows caveats (e.g., escaping file paths, GNU utilities missing, etc.)
* Install from the [Setup](../README.md#setup) section
* Enable
  * Start Menu > search for "Turn Windows Features On" > open > toggle "Windows Subsystem for Linux"
  * Restart
* M1 Macs only (Intel Macs and native Windows boxes need not apply)
  * Revert WSL 2 to WSL 1 due to nested virtualization not being available at a hardware level
    ```bash
    wsl --set-default-version 1
    ```
  * Docker won't run without paravirtualization enabled, but the rest of the development environment will work as expected
* Install Ubuntu
  ```bash
  # enable default distribution (Ubuntu)
  wsl --install ubuntu
  ```
* Start Linux and prep for environment setup
    ```bash
    # launch Ubuntu
    ubuntu

    # upgrade packages (as root: `sudo -s`)
    apt update && apt upgrade -y

    # create standard user
    adduser <username>
    visudo

    # search for 'Allow root to run any commands anywhere', then append identical line with new user
    root            ALL=(ALL)       ALL
    <username>      ALL=(ALL)       ALL

    # Allow members of group sudo to execute any command
    %sudo  ALL=(ALL) NOPASSWD: ALL
    ```
* Additional configuration options
  * Configuration locations
    * WSL 1: `/etc/wsl.conf`
    * WSL 2: `~/.wslconfig`
      ```bash
        # set default user
        [user]
        default=<username>

        # mounts host drive at /mnt/c/
        [automount]
        enabled = true
        options = "uid=1000,gid=1000"

        # WSL2-specific options
        [wsl2]
        memory = 8GB   # Limits VM memory in WSL 2
        processors = 6 # Makes the WSL 2 VM use two virtual processors
        ```
  * After making changes to the configuration file, WSL needs to be shutdown for [8 seconds](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule)
    * `wsl --shutdown`
  * **OPTIONAL**: Change home directory to host Windows' home
    ```bash
    # copy dotfiles to host home directory
    cp $HOME/.* /mnt/c/Users/<username>

    # edit /etc/passwd
    <username>:x:1000:1000:,,,:/mnt/c/Users/<username>:/bin/bash
    ```
