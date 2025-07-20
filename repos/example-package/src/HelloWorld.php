<?php

namespace Example\MinimalPackage;

/**
 * A simple class that demonstrates basic functionality.
 */
class HelloWorld
{
    /**
     * Returns a greeting message for the given name.
     *
     * @param string $name The name to greet
     * @return string The greeting message
     */
    public function greet(string $name): string
    {
        return "Hello, {$name}! Welcome to the Example Minimal Package.";
    }
}