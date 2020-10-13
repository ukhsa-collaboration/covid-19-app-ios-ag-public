#!/bin/sh

# ./updateCopy.sh <project_id> <branch> <api_token>

# Generate and upload zip for newest translations
echo "Requesting translations..."
response=$(curl --request POST \
  --url "https://api.lokalise.com/api2/projects/$1:$2/files/download" \
  --header 'content-type: application/json' \
  --header "x-api-token: $3" \
  --data '{
  	"format":"strings",
  	"original_filenames":true, 
  	"directory_prefix":"",
  	"indentation":"tab", 
  	"filter_langs": ["ar", "bn", "cy", "en", "gu", "pa", "ro", "tr", "ur", "zh", "pl", "so"], 
  	"replace_breaks":true, 
  	"export_sort":"first_added"
  }'
)

# Clean link to generated zip
bundle_url=$(echo $response | sed 's/\\//g' | grep -oiE '\"https.*"' | sed 's/"//g')

# Download translations
echo "Downloading translations..."
curl $bundle_url -LO

echo "Unpacking..."
unzip NHS_COVID-19-Localizable.zip -d Localization

echo "Move files into the project"
cd Localization
cp -r * ..
cd ..

echo "Cleaning up..."
rm -rf Localization
rm NHS_COVID-19-Localizable.zip
