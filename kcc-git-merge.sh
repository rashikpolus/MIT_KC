git ls-remote --tags upstream
git fetch --tags upstream
git checkout -b coeus-6.0.0-s8-n coeus-6.0.0-s8
#create diff file
git diff coeus-6.0.0-s14-n coeus-6.0.0-s15-n > sprints14-s15-patch.txt 
#merge from a previous tag, coeus-6.0.0-s7-n
git merge coeus-6.0.0-s15-n

