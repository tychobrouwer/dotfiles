#!/bin/bash
# Copyright (C) 2014  Smith AR <audoban@openmailbox.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Version 2.0

shopt -s extglob
shopt -s expand_aliases
# avoid warnings
unset GREP_OPTIONS

declare colors=(default black brown cyan blue grey green magenta orange red yellow violet)

declare symbols=( \
    default      activities  apple     copy-cloud desktop  \
    development  documents   download  downloads  drive    \
    dropbox      favorites   games     git        gnome    \
    image-people important   java      linux      locked   \
    mail         mail-cloud  mega      meocloud   music    \
    network      owncloud    photo     pictures   print    \
    private      public      recent    remote     script   \
    steam        tar         templates unlocked   vbox     \
    video        videos      visiting  wifi       wine     \
    yandex-disk
)

declare desktopEntry='.directory'
declare tmp=${TMPDIR:="/tmp"}/$desktopEntry-$PPID
declare custom=false
declare icon='none'
declare color='none'
declare symbol='none'

targetDir=$PWD

if which kiconfinder5 &>/dev/null ; then
    alias kiconfinder="kiconfinder5"
fi


showHelp() {
    cat <<-EOF
    USAGE
    `basename $0` <options> [FOLDER1 FOLDER2 ...]

    OPTIONS 
    -c <color>      default black brown cyan grey green magenta orange red yellow violet


    -s <symbol>     default      activities  apple     copy-cloud desktop 
                    development  documents   download  downloads  drive   
                    dropbox      favorites   games     git        gnome   
                    image-people important   java      linux      locked  
                    mail         mail-cloud  mega      meocloud   music   
                    network      owncloud    photo     pictures   print   
                    private      public      recent    remote     script  
                    steam        tar         templates unlocked   vbox  
                    video        videos      visiting  wifi       wine         
                    yandex-disk
                    
    -i              <icon|path> Path of the icon or a name of icon.

    -d              <directory>  Directory of the theme

    -o              open the icon chooser

    -h              show this help
EOF
exit
}

setColor() {
    pattern='[[:space:]]'$1'[[:space:]]'
    if [[ " ${colors[@]} " =~ $pattern ]] ; then
        color=$1
    else
        exit 1
    fi
}

setSymbol() {
    pattern='[[:space:]]'$1'[[:space:]]'
    if [[ " ${symbols[@]} " =~ $pattern ]] ; then 
        symbol=$1
    else
        exit 1
    fi
}

findIcon() {
    if ! [ -r "$(kiconfinder "$1")" ] ; then
        exit 1
    fi
    
    echo "$1"
}

setCustomIcon() {
    custom=true
    icon=$(findIcon $1)
}

openChooser() {
    custom=true
    icon=$(kdialog --title 'Select a icon' \
           --geticon Desktop Place 2> /dev/null)

    if [[ ${#icon} = 0 ]] ; then
        exit
    fi
}

reloadDolphin() {
    method='/dolphin/Dolphin_1/actions/reload org.qtproject.Qt.QAction.trigger'
    service='org.kde.dolphin-'
    reloaded=false

    for pid in $(pidof "dolphin") ; do
        if [[ $pid = $PPID ]] ; then
            qdbus $service$PPID $method &> /dev/null & disown -h
            reloaded=true
        fi
    done

    if ! $reloaded ; then
        for pid in $(pidof "dolphin") ; do
            qdbus $service$pid $method &> /dev/null & disown -h
        done
    fi
}

getCurrentSymbol() {
    pattern=${symbols[@]}
    pattern=${pattern//[[:space:]]/'|'}
    
    local symbol=$(echo "$1" | grep -E -o $pattern)
    
    if [ -n "$symbol" ] ; then
        echo "-$symbol"
    fi
}

getCurrentColor() {
    pattern=${colors[@]}
    pattern=${pattern//[[:space:]]/'|'}
    
    local color=$(echo "$1" | grep -E -o $pattern)
    
    if [ -n "$color" ] ; then
        echo "-$color"
    fi
}

configureIcon() {
    local icon='folder'
    
    case $color in
        default) ;;
        none)    icon="$icon"$(getCurrentColor $1) ;;
        *)       icon="$icon-$color"
    esac
    
    case $symbol in
        default) ;;
        none)    icon="$icon"$(getCurrentSymbol $1) ;;
        *)       icon="$icon-$symbol"
    esac
    
    echo $icon
}

# process the options
while getopts c:s:i:d:ro opt ; do
    case "$opt" in
        c) setColor      "$OPTARG" ;;
        s) setSymbol     "$OPTARG" ;;
        i) setCustomIcon "$OPTARG" ;;
        d) targetDir="$OPTARG"     ;;
        o) openChooser             ;;
        ?) showHelp                ;;
    esac
done

shift $(($OPTIND - 1)) # discard the options

writeIcon() {
    cd "$1"
    local tmpfile=$tmp$3
    
    if [ -w $desktopEntry ] && [ -n "$(< $desktopEntry)" ] ; then

        currentIcon=$(grep 'Icon=.*' $desktopEntry)
        header=$(grep '\[Desktop Entry\]' $desktopEntry)

        if $custom ; then
            icon=${icon//+(\/)/\\/}
        else
            icon=$(configureIcon $currentIcon)
        fi
        

        if [[ $icon = 'none' ]] ; then
            sed '/Icon=.*/d' $desktopEntry > $tmpfile

            pattern='\[Desktop Entry\][[:space:]]*[^[:alpha:]]*(\[|$)'
            headernoTags=$(echo $(< $tmp) | grep -E $pattern)
            if [[ ${#headernoTags} != 0 ]] ; then
                cat $tmp > $desktopEntry
                sed '/\[Desktop Entry\]/d;/./,$!d' $desktopEntry > $tmpfile
            fi

        elif [[ ${#currentIcon} != 0 ]] ; then
            sed "s/Icon=.*/Icon=$icon/" $desktopEntry > $tmpfile

        elif [[ ${#header} != 0 ]] ; then
            sed "s/\[Desktop Entry\]/[Desktop Entry]\nIcon=$icon/" $desktopEntry > $tmpfile

        else
            sed "1i[Desktop Entry]\nIcon=$icon\n" $desktopEntry > $tmpfile

        fi

        cat $tmpfile > $desktopEntry
        rm $tmpfile

    else
        echo -e "[Desktop Entry]\nIcon=$(configureIcon '')" > $desktopEntry
    fi
}


id=$((1))
for dir in "$@" ; do
    cd "$targetDir"

    if [ -d "$dir" ] ; then
        cd "$dir"
    else
        echo "Directory not found: $PWD/$dir"
        continue
    fi

    writeIcon "$PWD" $color $id &
    id=$((id + 1))
done

reloadDolphin
