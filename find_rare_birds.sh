nano find_rare_birds
#!/bin/bash

# --- BEGINNER-FRIENDLY SCRIPT ---

# Check if user provided input files
if [ "$#" -eq 0 ]; then
  echo "Usage: find_rare_birds [list of CSV files]"
  exit 1
fi

# Output files
output_once="species_observed_once_overall.csv"
output_year="species_observed_once_per_year.csv"
temp_combined="combined_data.csv"

# Get header from first file
head -n 1 "$1" > "$temp_combined"

# Combine all files, remove extra headers
for f in "$@"; do
  tail -n +2 "$f" >> "$temp_combined"
done

# --- Extract just the needed columns ---
# For simplicity, assume columns are:
# SpeciesCode, ScientificName, CommonName, Year, LocationID, Latitude, Longitude, State
# You may need to adjust column numbers with 'cut' or 'awk' if they differ.

# Create file with species seen exactly once overall
awk -F, '
{
  key = $1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8
  count[key]++
  lines[key] = $0
}
END {
  print "SpeciesCode,ScientificName,CommonName,Year,LocationID,Latitude,Longitude,State" > "'$output_once'"
  for (k in count)
    if (count[k] == 1)
      print lines[k] >> "'$output_once'"
}
' "$temp_combined"

# Create file with species seen once per year
awk -F, '
{
  species_year = $1 FS $4  # Species + Year
  full = $1 FS $2 FS $3 FS $4 FS $5 FS $6 FS $7 FS $8
  count[species_year]++
  lines[species_year] = $0
}
END {
  print "SpeciesCode,ScientificName,CommonName,Year,LocationID,Latitude,Longitude,State" > "'$output_year'"
  for (k in count)
    if (count[k] == 1)
      print lines[k] >> "'$output_year'"
}
' "$temp_combined"

# Clean up
rm "$temp_combined"

echo "Done! Created:"
echo " - $output_once"
echo " - $output_year"


