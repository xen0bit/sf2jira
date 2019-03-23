echo OFF
echo 'Starting sf2jira...'
echo 'Copying master.csv to step 0...'
#copy /Y master.csv .\0remap\master.csv
Copy-Item ".\master.csv" -Destination ".\0remap"
echo 'Stepping into /0remap...'
cd 0remap
echo 'Starting mapping of Projects...'
python genProjectMapping.py
echo 'Starting mapping of Issue Keys...'
python genIssueKeyMapping.py
echo 'Starting mapping of Names...'
python genNameMapping.py
echo 'Remapping Fields...'
python applyMappings.py
echo 'Backing up mappings...'
.\7z.exe a "$(get-date -f yyyy-MM-dd_HHMM).zip" *.json
echo 'Traversing up a directory...'
cd ..
echo 'Moving files to step 1...'
#copy /Y .\0remap\0output.csv .\1markup\0output.csv
Copy-Item ".\0remap\0output.csv" -Destination ".\1markup\0output.csv"
echo 'Stepping into /1markup...'
cd 1markup
echo 'Starting conversion of HTML2JIRA markup...'
python genMarkup.py
echo 'Traversing up a directory...'
cd ..
echo 'Moving files to step 2...'
#copy /Y .\1markup\1output.csv .\2issuesAndComments\1output.csv
Copy-Item ".\1markup\1output.csv" -Destination ".\2issuesAndComments\1output.csv"
#copy /Y .\0remap\account2projectkey.json .\2issuesAndComments\account2projectkey.json
Copy-Item ".\0remap\account2projectkey.json" -Destination ".\2issuesAndComments\account2projectkey.json"
#copy /Y .\0remap\case2issuekey.json .\2issuesAndComments\case2issuekey.json
Copy-Item ".\0remap\case2issuekey.json" -Destination ".\2issuesAndComments\case2issuekey.json"
#copy /Y .\0remap\name2username.json .\2issuesAndComments\name2username.json
Copy-Item ".\0remap\name2username.json" -Destination ".\2issuesAndComments\name2username.json"
echo 'Stepping into /2issuesAndComments...'
cd 2issuesAndComments
echo 'Splitting the comments from the issues using mappings...'
python stripCommentsFromIssues.py
echo 'Copying final output...'
Copy-Item "2output.csv" -Destination ".\..\readyForImport\Issues_Import.csv"
Copy-Item "3output.csv" -Destination ".\..\readyForImport\Comments_Import.csv"
echo 'Traversing up a directory...'
cd ..