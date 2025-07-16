# VPet

An interactive virtual pet designed around various vtubers and/or their mascots.

Currently included are
- [Clover Inari](https://erodozer.itch.io/pet-the-fox)
- [Hampwned](https://erodozer.itch.io/hamagotchi)
- [Gigi Murin](https://erodozer.itch.io/gremgotchi)'s Gremurins
- [Mono Monet](https://erodozer/itch.io/tabemono)'s Tabemonos

Keep the pet in good health and accumulate points to spoil them.

Designed to be played with either a mouse or touch interface.
Experimental keyboard and gamepad support

_* Autosaves occur once a minute_

Donations towards development accepted through [ko-fi](https://ko-fi.com/erodozer)

### Requirements

- Godot 4.4+

Additional dependencies must be downloaded and set up before editing the project.
Dependencies are managed using `godot_packages.json`
They can be fetched by running the included `godot-pkg.sh` script.

## Twitch Integration
This game supports integration with Twitch chat, allowing your viewers to take care of the pet with simple commands.

For the web version, you can enable twitch integration by visiting the itch.io page with your channel name in the url, like so
[https://erodozer.itch.io/pet-the-fox?twitch=erodozer](https://erodozer.itch.io/pet-the-fox?twitch=erodozer)

On Desktop, you can open the twitch integration configuration panel by pressing F1.  There you can then enter the channel name that you wish to link your game's session to.

<img width="300" src="https://github.com/erodozer/vpet/assets/316728/ec5c45b5-6b15-4440-81c7-d5e092ec2608" />

### Interactions
All interactions start with `!pet` as the command prefix

Commands are set to operate on the same cooldowns, this allows chat to act while the streamer is away/taking a break.
Per cycle stat adjustments are also tweaked to be more frequent and aggressive, encouraging chat engagement.

#### !pet &lt;food | give food
Feeds the pet

#### !pet lights < on | off >
toggle the lights

#### !pet < bath | bathe | wash >
washes the pet

#### !pet < heal | cure | give medicine >
give medicine to the sick pet

## Making Themes

This project implements a system internally referred to as AppSkin, which enables overriding placeholder resources at runtime with files located in the Theme folder.  While not the ideal approach to this problem, it works and has enabled faster iteration of new pets.  This allows VPet to work as a white-label application, and without the need of forking the project every time I wanted to make a new pet.

To add a new theme you must
- Add a new OS feature flag identifying the theme, which can be done through the Export Project interface
- Define new Project Settings overrides for configurable values relating to the theming
- Add assets within the `res://theme` directory according to your theme

To save on size, when exporting the project, export only with the resources selected for the theme the executable will run with.

Files within the theme's subdirectory must be placed and named exactly according to the directory tree relative to the project root for overriding.
Executing the project through the editor will generate an enumerated list of overridden files in the theme directory for the active theme.  This file is required by the project in order to skin resources, as enumerating files within the `res://` filesystem is not available in Godot exported runtimes.  These files should be checked into version control.

### Configuring features and resources

Each pet should have its own Shop and ResourceMenu configurations.  This allows customizing what food and games can be unlocked.
Individual resources for Food and Games control aspects like item effectiveness, the icon shown in the menu, and the animations.

For most sprite resources, you can simply override the image itself.  For animations, if you want more control over the number of frames or the ordering of frames, creating a new SpriteFrames resource is required.
