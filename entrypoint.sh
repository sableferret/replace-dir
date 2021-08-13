#!/bin/sh -l

set -e  # if a command fails exit the script
set -u  # script fails if trying to access an undefined variable

# Get arguments from action
BASE_BRANCH="$1"
DESTINATION_BRANCH="$2"
REPLACEMENT_DIRECTORY="$3"
COMMIT_USERNAME="$4"
COMMIT_EMAIL="$5"
COMMIT_MESSAGE="$6"

# Use temp directory to clone into
CLONE_DIRECTORY=$(mktemp -d)

# Setup git
git config --global user.email "$COMMIT_EMAIL"
git config --global user.name "$DESTINATION_USERNAME"
git clone --single-branch --branch "$BASE_BRANCH" "https://$API_TOKEN_GITHUB@github.com/$DESTINATION_USERNAME/$DESTINATION_REPOSITORY.git" "$CLONE_DIRECTORY"

cd "$CLONE_DIRECTORY"
rm -rf "$REPLACEMENT_DIRECTORY"

cp -a "../$REPLACEMENT_DIRECTORY/." "$REPLACEMENT_DIRECTORY"

git add .
git status

# don't commit if no changes were made
git diff-index --quiet HEAD || git commit --message "$COMMIT_MESSAGE"

# --set-upstream: sets the branch when pushing to a branch that does not exist
git push origin --set-upstream "$DESTINATION_BRANCH"