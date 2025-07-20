# Example Minimal Package

This is a minimal example package that demonstrates how to structure a Composer package for use with the Local Packagist system.

## Structure

This package follows the standard Composer package structure:

- `composer.json` - Package metadata and dependencies
- `src/` - Source code with PSR-4 autoloading
- `README.md` - Documentation

## Usage

Once this package is detected by the Local Packagist system, you can require it in your projects:

```bash
composer require example/minimal-package
```

## Example Code

```php
<?php

use Example\MinimalPackage\HelloWorld;

$hello = new HelloWorld();
echo $hello->greet('Developer');
```

This package is intended as a demonstration only and has minimal functionality.