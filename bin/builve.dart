#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const String version = '0.1.0';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addOption(
      'project-path',
      abbr: 'p',
      help: 'Path to the Flutter project. Defaults to the current directory.',
    )
    ..addOption(
      'destination',
      abbr: 'd',
      help:
          'Destination directory to move the build output. Defaults to Downloads.',
    )
    ..addOption(
      'build-type',
      abbr: 'b',
      defaultsTo: 'apk',
      allowed: ['apk', 'appbundle', 'apk-split'],
      help:
          'Type of Flutter build (apk, appbundle, apk-split). Defaults to apk.',
    )
    ..addOption(
      'repo-url',
      abbr: 'r',
      help: 'GitHub repository URL of the Flutter project to build.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: builve <flags> [arguments]');
  print(argParser.usage);
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = results['verbose'] as bool;

    // Process the parsed arguments.
    if (results['help'] as bool) {
      printUsage(argParser);
      return;
    }
    if (results['version'] as bool) {
      print('builve version: $version');
      return;
    }

    // Determine if repo-url is provided
    final String? repoUrl = results['repo-url'] as String?;
    String projectPath =
        results['project-path'] as String? ?? Directory.current.path;
    Directory? tempDir;
    if (repoUrl != null && repoUrl.isNotEmpty) {
      // Create a temp directory
      tempDir = await Directory.systemTemp.createTemp('builve_repo_');
      print('Cloning $repoUrl into ${tempDir.path} ...');
      final cloneResult =
          await Process.run('git', ['clone', repoUrl, tempDir.path]);
      if (cloneResult.exitCode != 0) {
        print('Error: Failed to clone repository.');
        print(cloneResult.stderr);
        return;
      }
      projectPath = tempDir.path;
    }

    final String destination = results['destination'] as String? ??
        path.join(
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!,
          'Downloads',
        );
    final String buildType = results['build-type'] as String;

    // Check if the project path is a Flutter project.
    final File pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      print('Error: The specified project path is not a Flutter project.');
      if (tempDir != null) await tempDir.delete(recursive: true);
      return;
    }

    // Run flutter pub get before building
    print('Running flutter pub get...');
    final pubGetResult = await Process.run('flutter', ['pub', 'get'],
        workingDirectory: projectPath, runInShell: true);
    if (pubGetResult.exitCode != 0) {
      print('Error: Failed to run flutter pub get.');
      print(pubGetResult.stderr);
      if (tempDir != null) await tempDir.delete(recursive: true);
      return;
    }
    if (verbose) {
      print(pubGetResult.stdout);
    }

    // Determine the Flutter build command.
    List<String> buildCommand = ['flutter', 'build'];
    if (buildType == 'apk') {
      buildCommand.add('apk');
    } else if (buildType == 'appbundle') {
      buildCommand.add('appbundle');
    } else if (buildType == 'apk-split') {
      buildCommand.addAll(['apk', '--split-per-abi']);
    }

    // Run the Flutter build command.
    print('Building $buildType...');
    final ProcessResult buildResult = await Process.run(
      buildCommand.first,
      buildCommand.sublist(1),
      workingDirectory: projectPath,
      runInShell: true,
    );

    if (buildResult.exitCode != 0) {
      print('Error: Failed to build $buildType.');
      print(buildResult.stderr);
      if (tempDir != null) await tempDir.delete(recursive: true);
      return;
    }

    if (verbose) {
      print(buildResult.stdout);
    }

    // Locate and move the generated build output.
    if (buildType == 'apk' || buildType == 'apk-split') {
      final Directory apkDir = Directory(
        path.join(projectPath, 'build', 'app', 'outputs', 'flutter-apk'),
      );

      if (!apkDir.existsSync()) {
        print('Error: APK output directory not found.');
        return;
      }

      final List<FileSystemEntity> apkFiles = apkDir.listSync().where((file) {
        return file is File && file.path.endsWith('.apk');
      }).toList();

      if (apkFiles.isEmpty) {
        print('Error: No APK files found.');
        return;
      }

      // Get the Flutter project name from pubspec.yaml
      final String pubspecContent = pubspecFile.readAsStringSync();
      final RegExp nameRegex = RegExp(r'^name:\s*(\S+)', multiLine: true);
      final Match? nameMatch = nameRegex.firstMatch(pubspecContent);
      final String projectName = nameMatch?.group(1) ?? 'flutter_project';

      final Directory destinationDir = Directory(
        path.join(destination, '${projectName}Builve'),
      );
      if (!destinationDir.existsSync()) {
        destinationDir.createSync(recursive: true);
      }

      for (final apkFile in apkFiles) {
        final String apkFileName = path.basename(apkFile.path);

        // Skip debug APKs
        if (apkFileName.contains('debug')) {
          continue;
        }

        // Rename APKs
        String newFileName;
        if (buildType == 'apk-split') {
          final RegExp abiRegex = RegExp(r'-(arm64-v8a|armeabi-v7a|x86_64)');
          final Match? abiMatch = abiRegex.firstMatch(apkFileName);
          final String abiSuffix = abiMatch?.group(1) ?? '';
          newFileName = '${projectName}_${abiSuffix}.apk';
        } else {
          newFileName = '${projectName}.apk';
        }

        final String destinationPath = path.join(
          destinationDir.path,
          newFileName,
        );
        File(apkFile.path).copySync(destinationPath);
        print('Moved ${path.basename(apkFile.path)} to $destinationPath');
      }
    } else if (buildType == 'appbundle') {
      final String bundlePath = path.join(
        projectPath,
        'build',
        'app',
        'outputs',
        'bundle',
        'release',
        'app-release.aab',
      );

      if (!File(bundlePath).existsSync()) {
        print('Error: App Bundle file not found.');
        return;
      }

      // Get the Flutter project name from pubspec.yaml
      final String pubspecContent = pubspecFile.readAsStringSync();
      final RegExp nameRegex = RegExp(r'^name:\s*(\S+)', multiLine: true);
      final Match? nameMatch = nameRegex.firstMatch(pubspecContent);
      final String projectName = nameMatch?.group(1) ?? 'flutter_project';

      final Directory destinationDir = Directory(
        path.join(destination, '${projectName}Builve'),
      );
      if (!destinationDir.existsSync()) {
        destinationDir.createSync(recursive: true);
      }

      final String destinationPath = path.join(
        destinationDir.path,
        '${projectName}.aab',
      );
      File(bundlePath).copySync(destinationPath);

      print('App Bundle successfully built and moved to: $destinationPath');
    }
    // Clean up temp directory if used
    if (tempDir != null) {
      print('Cleaning up temporary directory...');
      await tempDir.delete(recursive: true);
    }
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
  } on Exception catch (e) {
    print('Error: ${e.toString()}');
  } on Error catch (e) {
    print('Error: ${e.toString()}');
  } catch (e) {
    print('Error: ${e.toString()}');
  }
  exit(0);
}
