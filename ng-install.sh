#!/bin/bash

#############################################################################
# ng-install.sh                                                             #
# -------------                                                             #
# A small script that installs pzs-ng.                                      #
# You can run it at any time - no config-files will be overwritten, and no  #
# scripts will be overwritten. The only files that will be overwritten if   #
# they exists are the binary files and the bot files (not the bot config)   #
#                                                                           #
#############################################################################

# Enter glpath (usually not necessay - autodetect will take care of it).
glpath=

# Enter sslpath (usually not necessary - autodetect will take care of it).
sslpath=

# If you wish to install the bot, enter a valid path below.
eggpath="/home/sitebot/"

# Do you use ss5? Leave empty if not.
use_ss5=

# Do you wish to edit the full config? Leave empty if not.
use_expert=

# Do you wish to compile the bins static? Leave empty if not.
use_static=

# Do you wish to add formatting in the zipscript output? Leave empty if not.
use_format=

# Do you wish to disable alternative output in sitewho? Leave empty if not.
disable_altwho=


## END OF CONFIG ##

PATH=./:/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/usr/X11R6/bin:/$home/bin
possible_glroot_paths="/glftpd /jail/glftpd /usr/glftpd /usr/jail/glftpd /usr/local/glftpd /usr/local/jail/glftpd /$HOME/glftpd /glftpd/glftpd /opt/glftpd /opt/jail/glftpd"
scriptlist="./scripts/cleaner/cleaner.sh ./scripts/logtrimmer/logtrimmer.sh ./scripts/nfoextract/nfoextract.sh ./scripts/nfoextract/complete_script_wrapper.sh ./scripts/libcopy/libcopy.sh ./scripts/mp3-genre/mp3-genre-create.sh ./sitebot/extra/incomplete-list.sh ./sitebot/extra/invite.sh"

mywhich() {
  unset binname; for p in `echo $PATH | tr -s ':' '\n'`; do test -x $p/$bin && { binname=$p/$bin; break; }; done;
}

clear
# Getting glpath
if [ ! -z "$glpath" ] && [ -e "$glpath" ]; then
  echo "Using glpath: $glpath"
else
  for possible_glroot in $possible_glroot_paths; do
    if [ -e ${possible_glroot}/bin/glftpd ]; then
      glpath=${possible_glroot}
      break
    fi
  done
  if [ ! -z "$glpath" ]; then
    echo "Using glpath: $glpath"
  else
    echo "Failed to locate glpath. Please set in config."
    exit 1
  fi
fi

if [ ! -z "$eggpath" ] && [ -d "$eggpath" ]; then
  echo "Installing bot in $eggpath/pzs-ng/" | tr -s '/'
else
  echo "Bot will NOT be installed."
fi

echo "This script may be used to install or upgrade pzs-ng. Please note that no"
echo "config files or bot themes will be overwritten, neither will any of the"
echo "shell scripts. Thus, it should be safe to use."
echo
echo "If you wish to continue, please press <ENTER>. If not, press <CTRL-C> to"
echo "break."
echo ""
read readline

# Eggdrop
if [ ! -z "$eggpath" ] && [ -d "$eggpath" ]; then
  mkdir -p $eggpath/pzs-ng/plugins
  cp -fR sitebot/ngBot.* sitebot/plugins sitebot/modules $eggpath/pzs-ng/
  if [ ! -d $eggpath/pzs-ng/themes ]; then
    mkdir -p $eggpath/pzs-ng/themes
    cp -fR sitebot/themes/* $eggpath/pzs-ng/themes/
  else
    echo "sitebot themes are NOT being copied - please upgrade manually."
  fi
  if [ ! -e $eggpath/pzs-ng/ngBot.conf ]; then
    if [ -e "$eggpath/pzs-ng/dZSbot.conf" ]; then
      echo -n "Do you wish to rename dZSbot.conf to ngBot.conf (recommended)? (Y/n)> "
      read answer
      if [ ! "`echo $answer | tr 'A-Z' 'a-z' | cut -c 1-1`" = "n" ]; then
        mv $eggpath/pzs-ng/dZSbot.conf $eggpath/pzs-ng/ngBot.conf
      else
        cp sitebot/ngBot.conf.dist $eggpath/pzs-ng/ngBot.conf
      fi
    fi
  fi
fi

# Setting configure options
unset configline
if [ ! -z "$use_ss5" ]; then configline="$configline --enable-ss5"; fi
if [ ! -z "$use_expert" ]; then configline="$configline --enable-expert"; fi
if [ ! -z "$use_static" ]; then configline="$configline --enable-static"; fi
if [ ! -z "$use_format" ]; then configline="$configline --enable-format"; fi
if [ ! -z "$disable_altwho" ]; then configline="$configline --disable-altwho"; fi
if [ "$glpath" != "/glftpd" ]; then configline="$configline --with-glpath=$glpath"; fi

# Copying some scripts
if [ -d $glpath/bin ]; then
  echo -en "\nCopying scripts : "
  for script in $scriptlist; do
    echo -n "$(basename $script):"
    if [ ! -e "$glpath/bin/$(basename $script)" ]; then
      cp -f $script "$glpath/bin/$(basename $script)"
      echo -n "OK "
    else
      echo -n "NOT_COPIED "
    fi
  done
  echo
fi

# Compile/install zipscript and sitewho
echo -e "\nrunning 'make distclean'"
make distclean 2>/dev/null
echo -e "\nrunning './configure $configline'"
if [ ! -e ./zipscript/conf/zsconfig.h ]; then
  zsstop=1
else
  zsstop=0
fi
./configure $configline
if [ $zsstop -eq 1 ]; then
  echo "This seems to be the first time you install the zipscript."
  echo "Please edit zipscript/conf/zsconfig.h and re-run this script to continue."
  exit 0
fi
echo -e "\nrunning 'make install'"
make install

# Run libcopy
if [ -e "$glpath/bin/libcopy.sh" ]; then
  echo -e "\nrunning $glpath/bin/libcopy.sh'"
  $glpath/bin/libcopy.sh "$glpath"
fi

# Check imdb script
if [ ! -e "$glpath/bin/psxc-imdb.sh" ]; then
  echo -n "Do you wish to install psxc-imdb? (Y/n)> "
  read answer
  if [ ! "`echo $answer | tr 'A-Z' 'a-z' | cut -c 1-1`" = "n" ]; then
    mypath=$PWD
    cd scripts/psxc-imdb
    ./installer.sh
    cd $mypath
  fi
else
  echo -e "\npsxc-imdb already installed. Ignoring it."
fi
if [ -e "$eggpath" ]; then
  echo -e "\nMake sure you add the following to your eggdrop.conf:"
  echo "  source pzs-ng/ngBot.tcl"
fi
echo -e "\n\npzs-ng installed."

