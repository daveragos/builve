# Builve

Builve is a command-line tool designed to simplify Flutter build processes. It allows developers to build Flutter projects and manage their build outputs efficiently.

## Features
- Build Flutter projects as APK, App Bundle, or Split APKs.
- Build directly from a GitHub repository URL.
- Automatically rename and organize build outputs.
- Specify custom project paths and output destinations.
- Exclude debug APKs from the output.

## Installation

### Option 1: Install and Run from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/daveragos/builve.git
   ```
2. Navigate to the project directory:
   ```bash
   cd builve
   ```
3. Install dependencies:
   ```bash
   dart pub get
   ```
4. Activate the CLI globally: 
   ```bash
   dart pub global activate --source path .
   ```
5. Add Dart's global bin directory to your PATH if not already done.

### Option 2: Download Precompiled Binaries
Precompiled binaries for Linux, macOS, and Windows will be available in the [Releases](https://github.com/daveragos/builve/tree/main/release) section.

## Usage


### Basic Command
```bash
builve --build-type <type> --project-path <path> --destination <path>
builve --repo-url <github_repo_url> [other options]
```

### Options
* `--build-type` (`-b`): Type of Flutter build. Options are:
  - `apk`: Build a single APK.
  - `appbundle`: Build an Android App Bundle.
  - `apk-split`: Build multiple APKs, one for each ABI.

* `--project-path` (`-p`): Path to the Flutter project. Defaults to the current directory.
* `--repo-url` (`-r`): GitHub repository URL of the Flutter project to build. If provided, the tool will clone the repo to a temporary directory and build from there.
* `--destination` (`-d`): Directory to move the build output. Defaults to the `Downloads` folder in the user's home directory.
* `--verbose` (`-v`): Show additional command output.
* `--help` (`-h`): Print usage information.
* `--version`: Print the tool version.

### Examples


#### Build a Single APK from a local project
```bash
builve --build-type apk --project-path /path/to/flutter/project
```

#### Build Split APKs from a local project
```bash
builve --build-type apk-split --project-path /path/to/flutter/project --destination /path/to/output
```

#### Build an App Bundle from a local project
```bash
builve --build-type appbundle --project-path /path/to/flutter/project
```

#### Build a Single APK from a GitHub repo
```bash
builve --build-type apk --repo-url https://github.com/username/repo
```

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests to improve the tool.
