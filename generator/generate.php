<?php
$dir = '/repos';
$repos = [];

foreach (scandir($dir) as $folder) {
    $path = "$dir/$folder";
    if (is_dir($path) && is_dir("$path/.git")) {
        $repos[] = ['type' => 'vcs', 'url' => $path];
    }
}

file_put_contents('/satis.json', json_encode([
    'name' => 'local/packagist',
    'homepage' => 'http://localhost:9000',
    'repositories' => $repos,
    'require-all' => true,
    'archive' => [
        'directory' => 'dist',
        'format' => 'zip',
        'prefix-url' => 'http://localhost:9000',
        'skip-dev' => false
    ]
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
