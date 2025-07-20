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
