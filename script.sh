#!/bin/bash

# Function to prompt the user for top station call signs
read -p "Enter top station call signs (separated by spaces): " -a top_stations

# Input and output file names
input_file="list.m3u"
output_file="update.m3u"
epg_file="epg.xml"
filtered_epg_file="update.xml"

# Check if an existing update.m3u file is present
if [ -f "$output_file" ]; then
  echo "Existing $output_file found. Skipping M3U update."
else
  # Start the new M3U file with the header
  echo "#EXTM3U" > "$output_file"

  # Initialize variables to hold the current station info
  current_entry=""

  # Read the input M3U file line by line
  while IFS= read -r line; do
    # Check if the line is an entry descriptor
    if [[ $line == "#EXTINF:"* ]]; then
      current_entry="$line"
    elif [[ $line == http* ]]; then
      current_entry="${current_entry}\n${line}"
      # Check if the entry contains one of the top station call signs
      for station in "${top_stations[@]}"; do
        if [[ $current_entry == *"$station"* ]]; then
          echo -e "$current_entry" >> "$output_file"
          break
        fi
      done
      current_entry=""
    fi
  done < "$input_file"

  echo "Filtered M3U file created: $output_file"
  echo "Contents of the updated M3U file:"
  cat "$output_file"
fi

# Ask the user if they want to proceed with EPG filtering
read -p "Do you want to proceed with EPG filtering? (y/n): " proceed

if [[ $proceed != "y" ]]; then
  echo "EPG filtering aborted."
  exit 0
fi

# Insert line breaks between </channel><channel> tags in the EPG file if needed
sed -i 's@</channel><channel>@</channel>\n<channel>@g' "$epg_file"

# Create a temporary file to store filtered EPG
temp_file=$(mktemp)

# Start the new EPG file with the header
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$temp_file"
echo "<tv>" >> "$temp_file"

# Extract channel names from the M3U file
declare -A channel_names
while IFS= read -r line; do
  if [[ "$line" == \#EXTINF:* ]]; then
    name=$(echo "$line" | sed -n 's/.*tvg-name="\([^"]*\)".*/\1/p')
    channel_names["$name"]=1
  fi
done < "$output_file"

# Flags to indicate if the current channel/program should be included
include_channel=false
include_program=false

# Read the input EPG file line by line
while IFS= read -r line; do
  # Check if the line contains a channel element
  if [[ $line == *"<channel id="* ]]; then
    include_channel=false
    for name in "${!channel_names[@]}"; do
      if [[ $line == *"<display-name>${name}</display-name>"* ]]; then
        include_channel=true
        break
      fi
    done
  fi
  
  # Check if the line contains a programme element
  if [[ $line == *"<programme "* ]]; then
    include_program=false
    for name in "${!channel_names[@]}"; do
      if [[ $line == *"channel=\"$name\""* ]]; then
        include_program=true
        break
      fi
    done
  fi

  # Write the line to the temporary file if it belongs to an included channel/program
  if [[ $include_channel == true || $include_program == true ]]; then
    echo "$line" >> "$temp_file"
  fi

  # Reset include_program flag at the end of each programme element
  if [[ $line == *"</programme>"* ]]; then
    include_program=false
  fi

done < "$epg_file"

# Close the tv tag in the temporary file
echo "</tv>" >> "$temp_file"

# Move the temporary file to the final output file
mv "$temp_file" "$filtered_epg_file"

echo "Filtered EPG file created: $filtered_epg_file"
