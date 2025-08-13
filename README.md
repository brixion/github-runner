# Brixion GitHub Actions Runner

This repository contains a `Dockerfile` to build a custom container image for a self-hosted GitHub Actions runner. The image is based on the official `actions-runner` image and includes a variety of common tools and dependencies needed for modern CI/CD workflows.

## Purpose

The primary goal of this custom runner is to provide a pre-configured environment with necessary software, reducing setup time within workflow jobs and ensuring consistent builds.

## Base Image

*   **`ghcr.io/actions/actions-runner:latest`**

## Included Software

This image comes with the following software and tools pre-installed:

### Languages & Runtimes

*   **Node.js 18.x**: A modern version of Node.js for JavaScript-based tools and applications.
*   **Python 3**: The latest stable version of Python available in the base image's repositories.

### Package Managers

*   **npm** (via Node.js)
*   **yarn**: A popular JavaScript package manager.
*   **pip3** (via Python 3)

### Cloud & DevOps Tools

*   **AWS SAM CLI**: The AWS Serverless Application Model (SAM) Command Line Interface for building and deploying serverless applications.
*   **Git & Git LFS**: For version control and handling large files.

### Build Tools & Libraries

A comprehensive set of build tools and libraries are included to compile native extensions and other software:
*   `build-essential`
*   `autoconf`, `automake`, `libtool`
*   `libssl-dev`, `libxml2-dev`, `zlib1g-dev`, `libonig-dev`, `libzip-dev`, `libcurl4-openssl-dev`

### Linters & Utilities

*   **@redocly/cli**: For OpenAPI documentation generation and validation.
*   **yamllint**: A linter for YAML files.
*   Standard utilities like `curl`, `wget`, `unzip`, `zip`, `rsync`.

## Usage

1.  **Build the Docker image:**
    ```bash
    docker build -t brixion-github-runner .
    ```

2.  **Run the container:**
    Follow the GitHub documentation for [running self-hosted runners in a container](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/running-self-hosted-runners-in-a-container). You will need to provide your repository/organization URL and a personal access token (PAT) to register the runner.
