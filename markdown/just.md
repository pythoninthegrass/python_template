# justfile

> [just](https://just.systems/man/en/chapter_1.html) is a handy way to save and run project-specific commands.
> 
> Commands, called recipes, are stored in a file called justfile with syntax inspired by make:

## [Install](https://just.systems/man/en/chapter_4.html)
```bash
# macOS
brew install just

# Ubuntu/Debian
curl -q 'https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub' | gpg --dearmor | sudo tee /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg 1> /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs)" | sudo tee /etc/apt/sources.list.d/prebuilt-mpr.list
sudo apt update
sudo apt install just -y
```

## Usage
```bash
# default commands
just

# custom directives
just buildx         # [docker] intel build
just pull           # [docker] pull latest image
just run            # [docker] run local image
just up             # [docker] start docker-compose container
just down           # [docker] remove docker-compose container(s) and networks
```
