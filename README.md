# Simple-Testing-Script
Shell script for testing return code, output and error output.

## Usage
Place test.sh into folder with script that is going to be tested.

Edit script and set executable to application you would like to test.
```shell
executable="app_to_test"
```

Set test_output in script depending on if you want to test application's output or not
```shell
test_output="true/false"
```

Make script launchable:
```shell
chmod +x ./test.sh
```

Create some tests:
```shell
./test.sh example
```

Edit files created in folder tests and start the script
```shell
./test.sh
```
