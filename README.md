# Pocket Mans
A Pokémon-inspired RPG for [GB Compo 2023](https://gbdev.io/gbcompo23.html).

## Dependencies
- A POSIX-like environment
  - If you're on Linux then congratulations, you already have a POSIX environment! 
  - For macOS, you will need to install the [Xcode command line tools](https://developer.apple.com/xcode/resources/). Additionally, you will need to use [Homebrew](https://brew.sh/) in order to install a more recent version of GNU Make, since the version provided by Apple is out-of-date.
  - For Windows, you'll need to install [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) or a POSIX environment such as [Cygwin](https://www.cygwin.com/) or [MSYS2](https://www.msys2.org/).
- [RGBDS](https://rgbds.gbdev.io), version 0.6 or later
- [Python 3](https://python.org)

## Building
1. Clone the repository and submodules: `$ git clone --recursive https://github.com/DevEd2/PocketMans`
2. Run `make` (or `gmake` if you're on macOS).
3. Load the resulting ROM in an emulator such as [BGB](https://bgb.bircd.org) or [SameBoy](https://sameboy.github.io).
