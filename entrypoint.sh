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
remote_repo="https://${GITHUB_ACTOR}:${API_TOKEN_GITHUB}@github.com/${GITHUB_REPOSITORY}.git"
git config --global user.email "$COMMIT_EMAIL"
git config --global user.name "lab@bot.com"
git config http.sslVerify false
git remote add botpub "${remote_repo}"
git show-ref # useful for debugging
git branch --verbose

echo "Building clone target directory"
CLONE_DIRECTORY=$(mktemp -d)
git clone --branch "$BASE_BRANCH" "${remote_repo}" "$CLONE_DIRECTORY"

echo "Replacing target directory"
rm -rf "$CLONE_DIRECTORY/$TARGET_DIRECTORY"
cp -rvf $SOURCE_DIRECTORY "$CLONE_DIRECTORY/$TARGET_DIRECTORY"

echo "Commiting changes"
cd "$CLONE_DIRECTORY"
git checkout -B "$DESTINATION_BRANCH"
git add .

echo "Build commit message"
# don't commit if no changes were made
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

echo "Push updates"
git remote add botpub "${remote_repo}"
git push botpub ${DESTINATION_BRANCH} --force

echo "Completed"
