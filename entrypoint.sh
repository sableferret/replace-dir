#!/bin/sh -l

set -e  # if a command fails exit the script
set -u  # script fails if trying to access an undefined variable

# Get arguments from action
BASE_BRANCH="$1"
DESTINATION_BRANCH="$2"
SOURCE_DIRECTORY="$3"
TARGET_DIRECTORY="$4"
COMMIT_USERNAME="$5"
COMMIT_EMAIL="$6"
COMMIT_MESSAGE="$7"

# Setup git
git config --global user.email "$COMMIT_EMAIL"
git config --global user.name "$DESTINATION_USERNAME"

# replace the target directory
rm -rf "$TARGET_DIRECTORY"
cp -a "$SOURCE_DIRECTORY/." "$TARGET_DIRECTORY"

# Only commit the targeted directory
git add "$TARGET_DIRECTORY/."
git status

# don't commit if no changes were made
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

# --set-upstream: sets the branch when pushing to a branch that does not exist
git push origin --set-upstream "$DESTINATION_BRANCH"

# Issue the github PR
gh pr create --base $BASE_BRANCH --title "[ROBOT] Update" --body "Add the reason here"