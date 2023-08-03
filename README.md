# Introduction
Simple Bash script to launch AWS EC2. Just uses aws cli.

## Prerequisite
basic aws authentication
Follow guide by aws.
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Usage

### Launching EC2

    ./start.sh <Instance Name>

This command creates Latest Debian 12 EC2 box. 
with port 22 for ssh open.
creates ssh key to login.

Waits for instance to start and ssh to it once server is up.


### Cleaning EC2

    ./clean.sh <Instance Name>

This command cleans all things created.
Stops for EC2 instance to terminate


Note:

I have created this script in hurry.
Its not prettiest yet.

I am planning to clean up and comment soon.
