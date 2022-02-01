# Universal Packager for Bash Scripts

Unipack is a script that helps managing packages across multiple Linux distributions and package managers. It's a small contribution to try solving the frustration that Linux developers have when writing applications across multiple distributions.

The script is intended to be used as part of a larger project and only acts as a "helper function" to download and install dependencies that may have different names across different Linux distributions. Simply `cd` to your existing project and use the following commands to clone this project:

```
git clone https://github.com/asiangoldfish/unipack.git
```

The project includes two files: a JSON file "packages.json" and a Bash script "unipack.sh". "packages.json" has similar structure to Node's "package.json" file, but is intended for manual customization to suit your needs. This is where you manage your project's dependencies.

**packages.json**
```JSON
{
  "distributor_id": "",
  "package_manager": {
    "Arch": "pacman",
    "Debian": "apt-get"
  },
  "package_install": {
    "Arch": "-S",
    "Debian": "install"
  },
  "dependencies": {
    "Git": {
      "Arch": "git",
      "Debian": "git"
    }
  }
}
```

- `distributor_id`: The name of the Linux distribution. This is the only key that is dynamically assigned by the "unipack.sh" script. It can; however, also be manually assigned.
- `package_manager`: The name of the package manager for a distribution.
- `package_install`: The flag or argument to install a package. This largely depends on the package manager and its options.
- `dependencies`: This is where you list all dependencies that your project would need. The format goes like this:
  ```JSON
  "PACKAGE_1": {
    "DISTRO_1": "COMMAND",
    "DISTRO_2": "COMMAND",
  },
  "PACKAGE_2": {
    "DISTRO_1": "COMMAND",
    "DISTRO_2": "COMMAND",
  }
  ```
  - `PACKAGE_1` and `PACKAGE_2` are the name of the packages your project depends on, each representing a unique package.
  - `DISTRO_1` and `DISTRO_2` represents the name of the distribution to download the package for. The amount of distributions is up to you and depends on how many your project supports.
  - `COMMAND` is the appropriate command that works with the the distribution's package manager. The command, and sometimes also the package name, may vary from package manager to another.

**unipack.sh**

This script manages the dependencies listed in "packages.json". It has a single flag that is meant to be used only for development.  

- `--clear`: Clears the terminal upon execution  

Unipack heavily depends on [jq](https://stedolan.github.io/jq/) to parse JSON objects and manipulate keys. If this is not installed on the system, "unipack.sh" will return an error and terminate.  

To integrate the script into your own project, simply store its path to a variable and source it when needed.  

```Bash
# This assumes that the unipack project is in your project's root directory
unipack=$(dirname "${BASH_SOURCE[0]}")/unipack/unipack.sh
source "$unipack"
```

## Contribution
Simply fork the repository and make a pull request. Otherwise; bugs or suggestions can be raised [here](https://github.com/asiangoldfish/unipack/issues).

## License
MIT License

Copyright (c) 2022 Khai Duong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
