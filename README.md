# Project Title

This project is intended to be the client side of a ham radio remote control application.  

## Description

Using livekit.io to provide WebRTC services.
When combined with the server side of the application, removes the requirement to open firewall rules/port mapping on the home router, and eliminates the need for a VPN between the client and radio (Normally at the remote site, AKA - Home).
By developing with Flutter the intent is to have a single code base for the most common operating systems, and remote devices.
Since it may run on a mobile device (Phone) we are keeping the interface very simple, only focusing on SSB for the time being.  There simply isn't enough room on the screen for much else.

## Getting Started

### Dependencies

* Flutter
* LiveKit.io account
- A livekit.io project
- A livekit.io API_KEY and SECRET
* Upstream token server
- See tokenserver.txt for setup instructions.
- You will probably need to have your own domain so you can add the DNS record
* XCode (mac), Android Studio (Android), or Windows development environment depending on where you want to develop and test.


### Installing

* Git clone this repo
* Copy .env.sample to .env (leave it in the root directory)
* Update the setting in .env to match your environment

### Executing program

* After cloning and setting up .env, press 'F5' to run the project.  You may also click 'run', which is located about 'main' in 'main.dart'

## Help

* You can submit an issue, but generally you are on your own.  No support is offered or implied.

## Authors

Contributors names and contact info

ex. Dana Gertsch 

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the [NAME HERE] License - see the LICENSE.md file for details

## Acknowledgments

None to speak of at this point.