# Mac System Utility Script

This script provides various system maintenance and troubleshooting options for macOS users.

## Overview

The script offers the following functionalities:
- System status check
- Memory statistics and cleanup
- Cleaning temporary files
- Finding large files
- Network troubleshooting
- RAM and performance optimization

## How to Use

### Prerequisites

- macOS (the script is optimized for macOS).
- You should have `sudo` privileges for some of the operations (like cleaning system caches and restarting network services).

### Running the Script

1. Open a terminal window on your Mac.
2. Copy the script content and save it as `mac_system_utility.sh` in your preferred directory.
3. Give the script execution permissions:
   ```bash
   chmod +x mac_system_utility.sh


### Then
run
   ./mac_system_utility.sh

Main Menu

The script will present a menu of options to choose from:
	1.	View System Status: Displays information about uptime, disk space, and memory usage.
	2.	Clean Temporary Files: Cleans system and application cache files.
	3.	Open Junk Folders: Opens potential junk folders for manual review.
	4.	Find Large Files: Identifies and lists large files (>100MB) on your system.
	5.	Network Tools: Provides network troubleshooting utilities.
	6.	RAM & Performance Optimization: Displays memory information and recommendations for improving performance.
	7.	Exit: Exit the script.

User Data and Safety

The script operates in a non-invasive way, but it’s important to note:
	•	Cleaning Temporary Files: The script deletes cached files that are typically safe to remove (e.g., browser caches, system logs). These should not affect your personal data, but it is always a good practice to ensure that no important files are stored in those folders.
	•	Deleting Large Files: The script allows the user to delete large files, but it does not automatically delete them unless the user confirms the action. You should double-check the file paths before confirming deletion.
	•	Network Tools and System Status: These actions are read-only and will not modify or affect your system.

Important: Always make sure to have backups of important files before running cleanup scripts or deleting large files, just to be safe.

Folders Accessed by the Script

The script goes through the following folders for cleaning temporary files and opening junk directories:
	•	$HOME/Library/Caches: User-specific cache files.
	•	/Library/Caches: System-wide cache files.
	•	/private/var/folders: System’s temporary files.
	•	$HOME/Downloads/ChunkTemp: Temporary files generated by downloads.
	•	$HOME/Library/Application Support/Google/Chrome/Default/Cache: Google Chrome cache.
	•	$HOME/Library/Application Support/Firefox/Profiles/*/cache2: Firefox cache.
	•	$HOME/Library/Logs: Log files for various applications.
	•	/private/var/log: System log files.

License

This script is provided as-is. Feel free to modify or extend it, but use at your own risk. Always test the script in a safe environment before using it on important systems.
