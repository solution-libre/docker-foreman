# Docker Foreman

#### Table of Contents

1. [Description](#module-description)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Reference](#reference)
4. [Development](#development)
5. [Contributors](#contributors)

## Description

Docker image of [Foreman](http://theforeman.org/)

## Setup

```sh
cd /opt
git clone https://github.com/solution-libre/docker-foreman.git foreman
cd foreman
```

Update `.env` file.

## Usage

```sh
cd /opt/foreman
docker-compose up -d
```

## Reference

### Environment variables

#### `DB_PASSWORD`

The database password. Default value: 'postgres\_password'

## Development

[Solution Libre](https://www.solution-libre.fr)'s repositories are open projects, and community contributions are essential for keeping them great.


[Fork this repo on GitHub](https://github.com/solution-libre/docker-foreman/fork)

## Contributors

The list of contributors can be found at: https://github.com/solution-libre/docker-foreman/graphs/contributors
