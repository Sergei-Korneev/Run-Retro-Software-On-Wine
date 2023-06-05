# Run retro games / software on wine

This script is created to simplify the process of running windows applications on Wine.
The script creates wine prefix (32/64) in the current directory and also redirects all write request from your profile to the local HOME folder.

#### How to use
- Install wine on your distro first.
- Run ``script.sh run "/somedisk/someinstall.exe"``
- Well, that is it, run ``script.sh runlnk`` to search for all lnk files in the prefix  and run one or run  ``script.sh run "/somedisk/prefix/pathinsidetheprefix/program.exe"``.
- You also can run some utilities e.g. ``script.sh run winecfg`` or ``script.sh winetricks``
