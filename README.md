# CAPS_CRONSCAN

CAPS_Cronscan is a collection of LINUX based bash shell scripts for capturing labroratory petri dish experiments with one or more scanners. The software will program a LINUX cron-job to capture scanner data and send serial control data to accessories. 

This version of the software requires the us of SANE software

## Installation

Install SANE, and ensure user permissions for any attanched scanners

If using Arduino light controls, ensure proper drivers and user device permissions are properly configured.

Clone repository and alter constants found in go.sh script to reflect local configurations


## Usage

```terminal
$ go.sh
```

Configure experiment settings with the text-based UI. The UI displays variable fields that belong to an experiment record, to be recorded in the experiment subdirectory when the user S)aves and executes crontab installation.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Authors and acknowledgment
Chief architect and repository maintained by Zeth duBois || zdubois@uidaho.edu
Principle Investigatory: Dr Kyle Harrington
Contributions by: Conrad Mearns

## License
[MIT](https://choosealicense.com/licenses/mit/)