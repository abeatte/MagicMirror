#!/bin/bash

# NOTE: 
# Run this from the directory you want the code to be installd by typing `sudo ./easy_init.sh`. 
# (Dont forget to run `chmod +x easy_init.sh` to make this script executable) 

# Intro
# TODO: Splash screen
echo "This script will install all the necessary files for Magic Mirror and additional modules."
# TODO: By line

# Root User Check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# NPM Check
command_to_run="npm -v"
output=$($command_to_run)
if [ -z "$output" ]; then
  echo "NPM is not installed"
  exit 1
fi

# Node Check 
command_to_run="node -v"
output=$($command_to_run)
if [[ "${output:1}" < "20.09.0" || "${output:1}" > "22" ]]; then
  echo "Node is the incorrect version. ("${output:1}" >= 20.09.0 < 21 || 22)"
  exit 1
fi

# Git Check
command_to_run="git --version"
output=$($command_to_run)
if [ -z "$output" ]; then
  echo "Git is not installed"
  exit 1
fi

# Get Git Repo
if ! [ -d "MagicMirror" ]; then
    echo "Cloning from MagicMirror Git repo..."

    git clone https://github.com/abeatte/MagicMirror.git
    cd MagicMirror
    npm install
    cd ..
fi
cd MagicMirror

# Get Module(s)
cd modules

# Get MMM-CalendarExt3 Module
if ! [ -d "MMM-CalendarExt3" ]; then
    echo "Cloning from MMM-CalendarExt3 Git repo..."

    git clone https://github.com/MMRIZE/MMM-CalendarExt3
    cd MMM-CalendarExt3
    npm install
    git submodule update --init --recursive
    cd ..
fi

cd ..

# Adding the config
cd config
if [ -f "config.js" ]; then
    rm config.js.bak
    cp config.js config.js.bak
    rm config.js
fi

calendarCount=0
calendars="
"

read -p "Do you have a calendar to add? (y or n) " addCalendar
while [ "$addCalendar" == "y" ]; do
    ((calendarCount++))
    read -p "Calendar Name (calendar${calendarCount}): " name
    if [ -z "$name" ]; then
        name="calendar${calendarCount}"
    fi

    read -p "${name}'s calendar symbol (soccer-ball): " symbol
    if [ -z "$symbol" ]; then
        symbol="soccer-ball"
    fi

    read -p "${name}'s calendar color (blue): " color
    if [ -z "$color" ]; then
        color="blue"
    fi

    read -p "${name}'s calendar url: " url
    if [ -z "$url" ]; then
        url="https://calendar.google.com/calendar/embed?src=en.usa%23holiday%40group.v.calendar.google.com&ctz=America%2FLos_Angeles"
    fi

    calendars+='{ symbol: "'"${symbol}"'", color: "'"${color}"'", name: "'"${name}"'", url: "'"${url}"'" }'

    read -p "Do you have another calendar to add? (y or n)" addCalendar
    if [ "$addCalendar" == "y" ]; then
        calendars+=",
        "
    fi
done

    echo ""
    echo "For accurate weather input your latitude and longitude."
    echo "An easy way to find your current coordinates is to use https://www.google.com/maps"
    
    read -p "latitude: " lat
    if [ -z "$lat" ]; then
        lat="48.85850415798338"
    fi

    read -p "longitude: " lon
    if [ -z "$lon" ]; then
        lon="2.294513493475159"
    fi

echo "Writing to config.js..."

echo '/* Easy Config Init
 *
 * For more information on how you can configure this file
 * see https://docs.magicmirror.builders/configuration/introduction.html
 * and https://docs.magicmirror.builders/modules/configuration.html
 *
 * You can use environment variables using a `config.js.template` file instead of `config.js`
 * which will be converted to `config.js` while starting. For more information
 * see https://docs.magicmirror.builders/configuration/introduction.html#enviromnent-variables
 */
let config = {
	address: "0.0.0.0",	// Address to listen on, can be:
							// - "localhost", "127.0.0.1", "::1" to listen on loopback interface
							// - another specific IPv4/6 to listen on a specific interface
							// - "0.0.0.0", "::" to listen on any interface
							// Default, when address config is left out or empty, is "localhost"
	port: 8081,
	basePath: "/",	// The URL path where MagicMirror² is hosted. If you are using a Reverse proxy
									// you must set the sub path here. basePath must end with a /
	ipWhitelist: [], // ["127.0.0.1", "::ffff:127.0.0.1", "::1"],	// Set [] to allow all IP addresses
									// or add a specific IPv4 of 192.168.1.5 :
									// ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.1.5"],
									// or IPv4 range of 192.168.3.0 --> 192.168.3.15 use CIDR format :
									// ["127.0.0.1", "::ffff:127.0.0.1", "::1", "::ffff:192.168.3.0/28"],

	useHttps: false,			// Support HTTPS or not, default "false" will use HTTP
	httpsPrivateKey: "",	// HTTPS private key path, only require when useHttps is true
	httpsCertificate: "",	// HTTPS Certificate path, only require when useHttps is true

	language: "en",
	locale: "en-US",
	logLevel: ["INFO", "LOG", "WARN", "ERROR"], // Add "DEBUG" for even more logging
	timeFormat: 24,
	units: "imperial",

	modules: [
		{
			module: "clock",
			position: "top_left"
		},
		{
			module: "MMM-CalendarExt3",
			// header: "The Family Schedule",
			position: "bottom_bar",
			config: {
				waitFetch: 60000, // once per minute
				refreshInterval: 60000, // once per minute
				displayWeatherTemp: true,
				useSymbol: true,
				useWeather: true,
				maxEventLines: 4,
				// calendarSet: ["cal1", "cal2", "cal3"]
				},		
		},
		{
			module: "calendar",
			// position: "top_left",
			config: {
				broadcastPastEvents: true,
				fetchInterval:60*1000,
				maximumNumberOfDays: 28,
				calendars: [' "${calendars}" ']
			}
		},
		{
			module: "weather",
			position: "top_right",
			config: {
				weatherProvider: "openmeteo",
				type: "current",
				lat: ' "${lat}" ',
				lon: ' "${lon}" '
			}
		},
		{
			module: "weather",
			//position: "null",
			header: "Weather Forecast",
			config: {
				weatherProvider: "openmeteo",
				type: "forecast",
				lat: ' "${lat}" ',
				lon: ' "${lon}" ',
				maxNumberOfDays: 14
			}
		},
	]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") { module.exports = config; }' > config.js

cd ..

echo ""
read -p "Would you like to start Magic Mirror with these configurations now? (y or n) " start
if [[ -z "$start" || "$start" != "y" ]]; then
    echo "Setup complete!"
    exit 0
fi

# Start Magic Mirror
read -p "Do you want to start in 'display' or 'server' mode? (display) " mode
if [[ "$mode" != "server" ]]; then
    mode="server"
fi

if [ "$mode" = "server" ]; then
    npm run server
elif [ "$mode" = "display" ]; then
    npm start
fi
