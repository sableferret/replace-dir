#!/bin/sh -l

set -e  # if a command fails exit the script
set -u  # script fails if trying to access an undefined variable

echo "Setting up arguments"
# Get arguments from action
BASE_BRANCH="$1"
DESTINATION_BRANCH="$2"
SOURCE_DIRECTORY="$3"
TARGET_DIRECTORY="$4"
COMMIT_USERNAME="$5"
COMMIT_EMAIL="$6"
COMMIT_MESSAGE="$7"

echo "Setting up git"
git config --global user.email "$COMMIT_EMAIL"
git config --global user.name "lab@bot.com"
git config http.sslVerify false

echo "Building clone target directory"
CLONE_DIRECTORY=$(mktemp -d)
git clone --single-branch --branch "$BASE_BRANCH" "https://${GITHUB_ACTOR}:${API_TOKEN_GITHUB}@github.com/${GITHUB_REPOSITORY}.git" "$CLONE_DIRECTORY"

echo "Replacing target directory"
rm -rf "$CLONE_DIRECTORY/$TARGET_DIRECTORY"
cp -rvf $SOURCE_DIRECTORY "$CLONE_DIRECTORY/$TARGET_DIRECTORY"


echo "Commiting changes"
cd "$CLONE_DIRECTORY"
git add .

# don't commit if no changes were made
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

# --set-upstream: sets the branch when pushing to a branch that does not exist
git push origin --set-upstream "$DESTINATION_BRANCH"

echo "Issuing PR"
gh pr create --base $BASE_BRANCH --title "[ROBOT] Update" --body "Add the reason here"