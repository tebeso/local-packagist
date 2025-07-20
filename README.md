# Local Packagist (Self-hosted Composer Repository)

This is a fully automated local Composer repository system inspired by Packagist, using Satis in a Docker container. It requires no manual configuration — simply drop your Composer packages in the `repos/` folder and run it.

## Features

- Automatic detection of Composer packages (Git repositories only)
- Local Composer repository served at `http://localhost:9000`
- No need to manually list packages
- Clean and production-ready Docker setup
- Automatic handling of Git ownership issues in Docker

## Usage

### 1. Add Your Packages

Put your local Composer packages into the `repos/` folder.

Each package should contain a valid `composer.json` file and must be initialized as a Git repository.

### 1.1 Initializing a Git Repository

If you've added a folder that doesn't have a `.git` directory, you need to initialize it as a Git repository:

```bash
# Navigate to your package directory
cd repos/your-package-name

# Initialize a new Git repository
git init

# Add all files to the repository
git add .

# Commit the files
git commit -m "Initial commit"
```

After initializing the Git repository and committing your files, the system will detect your package and include it in the Composer repository.

> **Note:** Only committed changes are detected by the system. If you make changes to your package, you need to commit them for the changes to be reflected in the Composer repository.

### 2. Start the Server

```bash
docker-compose up --build
```

To run the server in the background (daemon mode), add the `-d` flag:

```bash
docker-compose up --build -d
```

This will:
- Generate a `satis.json` based on all repos found in `repos/`
- Build the Composer repository into `satis/`
- Serve it at `http://localhost:9000`
- You can visit `http://localhost:9000` in your web browser to see a web interface with an overview of all available repositories

Running in daemon mode allows the containers to run in the background, which is useful for production environments or when you don't want to keep a terminal window open.

### 3. Use in Composer

In your consuming project's `composer.json`:

```json
{
  "repositories": [
    {
      "type": "composer",
      "url": "http://localhost:9000"
    }
  ],
  "config": {
    "secure-http": false
  }
}
```

The `secure-http: false` configuration is required because the local repository is served over HTTP, not HTTPS, and Composer's `secure-http` setting defaults to true.

#### Using from Docker Containers

If you're using this repository from another Docker container (e.g., in a Docker Compose setup), you'll need to use the Docker host's IP address instead of `localhost`:

```json
{
  "repositories": [
    {
      "type": "composer",
      "url": "http://172.17.0.1:9000"
    }
  ],
  "config": {
    "secure-http": false
  }
}
```

`172.17.0.1` is the default Docker host IP address. This allows containers to communicate with services running on the host machine.

Then install as usual:

```bash
composer require vendor/package
```

---

## Advanced

- The repository auto-rebuilds every time `docker-compose up` is called.
- The system automatically watches for changes in the `repos/` folder and rebuilds the repository when changes are detected. Note that only committed changes to Git repositories are detected.

## Notes

- Works with Git repositories containing `composer.json` in root.

## User Permissions

By default, the Docker container runs with user ID 1000 and group ID 1000, which is typically the first user on a Linux system. If your user has different IDs, you might encounter permission issues when the container creates or modifies files.

### Configuring User IDs

To run the container with your user ID and group ID:

1. Copy the `.env.example` file to `.env`:

```bash
cp .env.example .env
```

2. Find your user ID and group ID:

```bash
id -u && id -g
```

3. Update the `.env` file with your IDs:

```
USER_ID=your_user_id
GROUP_ID=your_group_id
```

4. Restart the container:

```bash
docker-compose down
docker-compose up --build -d
```

This ensures that all files created by the container will be owned by your user, avoiding permission issues when you need to modify or delete these files.

### How It Works

- The Dockerfile creates a non-root user with the specified user ID and group ID
- The container runs as this user instead of root
- Git operations are performed with the correct permissions
- The example-package is automatically initialized with the correct file permissions

This approach solves the "dubious ownership" issues that can occur with Git repositories in Docker containers and ensures that you can easily manage the files in the `repos/` directory.

## Example Package

This repository includes a minimal example package (`example/minimal-package`) that demonstrates how to structure a Composer package for use with the Local Packagist system. You can find it in the `repos/example-package` directory.

### Package Structure

```
example-package/
├── .git/                  # Git repository (required)
├── composer.json          # Package metadata and dependencies
├── README.md              # Documentation
└── src/
    └── HelloWorld.php     # Example class with PSR-4 autoloading
```

### Key Components

1. **composer.json**: Defines the package name, description, dependencies, and autoloading configuration
2. **src/ directory**: Contains the PHP classes following PSR-4 autoloading standard
3. **Git repository**: The package must be initialized as a Git repository with committed files

### Using the Example Package

Once the Local Packagist system is running, you can require this example package in your projects:

```bash
composer require example/minimal-package
```

Then use it in your PHP code:

```php
<?php

use Example\MinimalPackage\HelloWorld;

$hello = new HelloWorld();
echo $hello->greet('Developer');
```

This example package serves as a template for creating your own packages to use with the Local Packagist system.
