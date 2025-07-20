#!/bin/bash

echo "Installing Satis..."
composer create-project --quiet --no-interaction --stability=dev --ignore-platform-reqs composer/satis /tmp/satis

echo "Generating initial satis.json and building package index..."

for repo in /repos/*; do
  if [ -d "$repo" ]; then
    echo "Adding $repo as a safe directory for Git..."
    git config --global --add safe.directory "$repo"
    
    # Also add the .git directory as a safe directory if it exists
    if [ -d "$repo/.git" ]; then
      echo "Adding $repo/.git as a safe directory for Git..."
      git config --global --add safe.directory "$repo/.git"
    fi
  fi
done

php /generate.php
php /tmp/satis/bin/satis build /satis.json /build

echo "Starting local server on http://localhost:9000"
php -S 0.0.0.0:80 -t /build &

echo "Watching /repos for Git commits and changes..."

# Create a directory to store commit hashes
mkdir -p /tmp/repo_hashes

# Function to check if a directory is a Git repository
is_git_repo() {
  if git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0  # True, it is a Git repo
  else
    return 1  # False, it is not a Git repo
  fi
}

# Function to get the latest commit hash of a repository
get_commit_hash() {
  local repo="$1"
  local hash
  
  hash=$(git -C "$repo" rev-parse HEAD 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "$hash"
  else
    echo "no_commits"
  fi
}

# Function to check if a repository has uncommitted changes
has_uncommitted_changes() {
  local repo="$1"
  local changes
  
  changes=$(git -C "$repo" status --porcelain 2>/dev/null)
  if [ -n "$changes" ]; then
    return 0  # True, it has uncommitted changes
  else
    return 1  # False, it has no uncommitted changes
  fi
}

# Function to get a safe filename for a repository path
get_repo_filename() {
  local repo="$1"
  echo "${repo//\//_}"  # Replace / with _ to create a safe filename
}

# Initial scan of repositories to store their commit hashes
echo "Performing initial scan of repositories..."
for repo in /repos/*; do
  if [ -d "$repo" ]; then
    # Configure as safe directory
    git config --global --add safe.directory "$repo" 2>/dev/null
    
    # Also add the .git directory as a safe directory if it exists
    if [ -d "$repo/.git" ]; then
      git config --global --add safe.directory "$repo/.git" 2>/dev/null
    fi
    
    if is_git_repo "$repo"; then
      repo_filename=$(get_repo_filename "$repo")
      current_hash=$(get_commit_hash "$repo")
      echo "$current_hash" > "/tmp/repo_hashes/$repo_filename"
      echo "Monitoring Git repository: $repo (current commit: $current_hash)"
    elif [ -f "$repo/composer.json" ]; then
      echo "[NOT A GIT REPOSITORY] $repo - Contains composer.json but is not a Git repository. Initialize it with 'git init' and commit your files."
    fi
  fi
done

echo "Initial scan complete. Starting monitoring loop..."

# Main monitoring loop
while true; do
  rebuild_needed=false
  
  # Check for new repositories and changes
  for repo in /repos/*; do
    if [ -d "$repo" ]; then
      # Configure as safe directory if not already done
      git config --global --add safe.directory "$repo" 2>/dev/null
      
      # Also add the .git directory as a safe directory if it exists
      if [ -d "$repo/.git" ]; then
        git config --global --add safe.directory "$repo/.git" 2>/dev/null
      fi
      
      if is_git_repo "$repo"; then
        repo_filename=$(get_repo_filename "$repo")
        current_hash=$(get_commit_hash "$repo")
        
        # Check if we have a stored hash for this repository
        if [ -f "/tmp/repo_hashes/$repo_filename" ]; then
          last_hash=$(cat "/tmp/repo_hashes/$repo_filename")
          
          # If the hash has changed, a new commit was made
          if [ "$last_hash" != "$current_hash" ]; then
            echo "[NEW COMMIT DETECTED] $repo (${last_hash} -> ${current_hash})"
            echo "$current_hash" > "/tmp/repo_hashes/$repo_filename"
            rebuild_needed=true
          fi
        else
          # This is a new repository
          echo "[NEW REPOSITORY DETECTED] $repo (commit: ${current_hash})"
          echo "$current_hash" > "/tmp/repo_hashes/$repo_filename"
          rebuild_needed=true
        fi
        
        # Check for uncommitted changes
        if has_uncommitted_changes "$repo"; then
          echo "[UNCOMMITTED CHANGES] $repo - Changes detected but not committed. These changes will not be reflected in the repository until committed."
        fi
      elif [ -f "$repo/composer.json" ]; then
        # It's not a Git repo but has a composer.json file
        echo "[NOT A GIT REPOSITORY] $repo - Contains composer.json but is not a Git repository. Initialize it with 'git init' and commit your files."
      fi
    fi
  done
  
  # Rebuild if needed
  if [ "$rebuild_needed" = true ]; then
    echo "Rebuilding satis.json and repository due to new commits..."
    php /generate.php
    php /tmp/satis/bin/satis build /satis.json /build
    echo "Rebuild complete."
  fi
  
  # Sleep for a while before checking again
  echo "Sleeping for 5 seconds before next check..."
  sleep 5
done
