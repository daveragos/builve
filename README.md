# Builve

Builve is a command-line tool designed to simplify Flutter build processes. It allows developers to build Flutter projects and manage their build outputs efficiently.

## Features
- Build Flutter projects as APK, App Bundle, or Split APKs.
- Automatically rename and organize build outputs.
- Specify custom project paths and output destinations.
- Exclude debug APKs from the output.

## Installation

### Option 1: Install via Dart's `pub global activate`
1. Ensure you have Dart installed on your system.
2. Run the following command:
   ```bash
   dart pub global activate builve
   ```
3. Add Dart's global bin directory to your PATH if not already done.

### Option 2: Clone the Repository
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
4. Run the CLI:
   ```bash
   dart bin/builve.dart
   ```

### Option 3: Download Precompiled Binaries
Precompiled binaries for Linux, macOS, and Windows will be available in the [Releases](https://github.com/daveragos/builve/tree/main/release) section.

## Usage

### Basic Command
```bash
builve --build-type <type> --project-path <path> --destination <path>
```

### Options
- `--build-type` (`-b`): Type of Flutter build. Options are:
  - `apk`: Build a single APK.
  - `appbundle`: Build an Android App Bundle.
  - `apk-split`: Build multiple APKs, one for each ABI.
  
- `--project-path` (`-p`): Path to the Flutter project. Defaults to the current directory.
- `--destination` (`-d`): Directory to move the build output. Defaults to the `Downloads` folder in the user's home directory.
- `--verbose` (`-v`): Show additional command output.
- `--help` (`-h`): Print usage information.
- `--version`: Print the tool version.

### Examples

#### Build a Single APK
```bash
builve --build-type apk --project-path /path/to/flutter/project
```

#### Build Split APKs
```bash
builve --build-type apk-split --project-path /path/to/flutter/project --destination /path/to/output
```

#### Build an App Bundle
```bash
builve --build-type appbundle --project-path /path/to/flutter/project
```

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests to improve the tool.
