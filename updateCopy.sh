#!/bin/sh

# ./updateCopy.sh <project_id> <branch> <api_token>
# Updates translations from Lokalise and creates a GitHub pull request to integrate these translations.
#
# You almost never have to do this manually—use the GitHub "Update Translations" action to do it for you.
# 
# 
# OH NO, THE SCRIPT/ACTION ISN'T WORKING!
# If the error looks like this:
# 
# > Downloading translations...
# > curl: no URL specified!
# 
# ...your API token is probably out of date, or has been removed (maybe the user who created it left.)
# 
# Generate a new API token for a Lokalise user who will be here for a while. (See: https://docs.lokalise.com/en/articles/1929556-api-tokens)
# Then update the LOKALISE_API_TOKEN secret in the GitHub settings for the project (you need to be a maintainer to do this.)
# Then try re-running the Update Translations action again to see if it worked.

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

# Clean link to generated zip file.
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
