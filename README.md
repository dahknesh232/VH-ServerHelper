# Vault Hunters Server Helper

These scripts are meant to help you setup a local server on your machine.


## Setup

1. To start, please go to the [CurseForge page](https://www.curseforge.com/minecraft/modpacks/vault-hunters-1-18-2) and download the **server files** for Vault Hunters.
2. Extract the ZIP to your project directory: `/path/to/minecraft/project` or `C:\path\to\project` - Drive letter on Windows may vary if using a different drive than `C`.
3. Download the `vh-setup` file of your choice, from this repository.
4. Place the downloaded `vh-setup` file into project directory.
   1. If on UNIX system, you need to ensure the file is executable -  you can do so by running the following command in your project directory:
       a. `sudo chmod +x vh-setup.*` 
5. Run the script, and it will install all forge dependencies and start the server for you!


## Running the Server

The script will automatically run the server once it has installed all if its requirements, however, when running the server in the future, you will find a `run.bat` script (and a `run.sh` script) which you can use to start your server.

## Additional Options

If you would like to change the JVM arguments for your server, you can adjust these in the `user_jvm_args.txt` file. -- *Note that after making changes, to apply them, you need to restart the server*
