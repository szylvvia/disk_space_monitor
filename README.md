<h1> HDGUARD - disk space monitor </h1>
<p><i>Shell script</i></p>

<h2>How does it work?</h2>
<p align="justify">
This script is designed to monitor a disk or specified partition every 60 seconds. If there are invalid values given when the script runs, it will automatically close. The value must be a number in the open range (30;99), and the script accepts only one value. The limit value is taken when the script is called.</p>
<p align="justify">
The script collects the partition information and displays it to the user. It then calculates how much memory should be freed to go below the limit value. The script searches for and displays a list of files that can be deleted, and the user has the option to select which files he wants to delete. Once selected, the script automatically deletes the selected files and informs the user that the action is complete. </p>
<p align="justify">
To use the script, run it by specifying a limit value when calling it.</p>

