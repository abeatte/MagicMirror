For Windows:

1. Get a mac.

For Mac:

1. Follow the repo instructions

For Raspberry Pi Zero W

---

## Get the basics

Download NVM and point it to unofficial nodejs mirror
`curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash`
`echo "export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release" >> ~/.bashr`

Install the proper Node and Npm
`nvm install 20.9.0`
`nvm use 20.9.0`

Verify the proper Node and Npm
`node -v`
`npm -v`

Install git
`sudo apt install git`

---

## Setup the repo

Download and install MagicMirror
`git clone https://github.com/abeatte/MagicMirror.git`
`cd MagicMirror/`
`npm run install-mm`

Setup the custom modules (optional)
`cd modules/`
`git clone https://github.com/MMRIZE/MMM-CalendarExt3`
`cd MMM-CalendarExt3/`
`npm install`
`git submodule update --init --recursive`
`cd ../..`

Add your config
`cd config/`

# put your config here

`cd ..`

---

## Start the server

`npm install`
`npm run server`

---
