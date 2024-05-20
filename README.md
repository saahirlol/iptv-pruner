# IPTV Pruner

#### Overview
This script, called IPTV Pruner, is designed to filter and update M3U playlist files and Electronic Program Guide (EPG) XML files based on user-specified channel names. It first checks for the presence of an existing filtered M3U file, prompts the user for the channel names, and filters the M3U file accordingly. If the user opts to proceed with EPG filtering, it filters the EPG file to include only the channels listed in the filtered M3U file.

#### Prerequisites
- Bash shell environment
- Input files:
  - `list.m3u`: Original M3U playlist file
  - `epg.xml`: Original EPG XML file

#### Script Usage
1. **Input and Output File Names**
    - `input_file`: Original M3U playlist file (`list.m3u`)
    - `output_file`: Filtered M3U playlist file (`update.m3u`)
    - `epg_file`: Original EPG XML file (`epg.xml`)
    - `filtered_epg_file`: Filtered EPG XML file (`update.xml`)

2. **Steps to Execute the Script**
    - Run the script using a bash shell: `./script.sh`
    - The script will prompt for channel names:
      ```
      Enter channels to find (separated by spaces):
      ```
    - Enter the channel names separated by spaces.

3. **M3U Filtering Process**
    - The script checks if an existing `update.m3u` file is present. If it exists, it skips the M3U update.
    - If no existing file is found, it reads the `list.m3u` file, filters the entries based on the provided channel names, and writes the filtered entries to `update.m3u`.
    - The contents of the updated M3U file are displayed.

4. **EPG Filtering Process**
    - The script asks if the user wants to proceed with EPG filtering:
      ```
      Do you want to proceed with EPG filtering? (y/n):
      ```
    - If the user inputs 'y', the script proceeds with the following steps:
      - Inserts line breaks between `</channel><channel>` tags in the EPG file.
      - Creates a temporary file to store the filtered EPG data.
      - Extracts channel names from the `update.m3u` file.
      - Reads the `epg.xml` file line by line, includes only the channels and programs that match the filtered M3U channels, and writes them to the temporary file.
      - The filtered EPG data is moved to `update.xml`.

#### Example Commands
- To run the script:
  ```bash
  ./script.sh
  ```
- When prompted, enter the channel names:
  ```
  Enter channels to find (separated by spaces): ABC NBC FOX
  ```
- To confirm EPG filtering:
  ```
  Do you want to proceed with EPG filtering? (y/n): y
  ```

#### Script Output
- `update.m3u`: Filtered M3U playlist file.
- `update.xml`: Filtered EPG XML file.

#### Notes
- Ensure the input files (`list.m3u` and `epg.xml`) are in the same directory as the script.
- The script assumes the format of the M3U and EPG files is standard and consistent.

The IPTV Pruner script streamlines the process of filtering large M3U and EPG files to only include specific channels, making it easier to manage and use the playlists and program guides.
