#!/bin/bash
#source ./hardwere-check.sh

#okay in Managment and finincial ther is double checking by counting 2 times on 2 sides
#so that's what i'm going for:
#create second file with files to synch.
# Give output of errors


update_repo='sudo pacman -Syy'
question_repo=" We want to update your local repo to check if files are up to date. We want to run '$update_repo'. Do you agree? (Y/n) "

sync_array=()

packages_sync="temp/PackagesSync.txt"
packages_to_update="temp/PackagesDiffrence.txt"

append_sync_array(){
    str="$*"
    sync_array+=($(echo $str | tr " " "\n"))
}

ask(){
    read -r -p  "$1" permission
    if [  $permission = Y -o $permission = y ];then
        return 0
    else
        return 1
    fi
}

repo_update(){
    if ask "$question_repo"; then
        $update_repo        
    else
        echo "we couldn't update repo so the program will be terminated"
    fi  
}

check_updates(){ ### special case Pacman simple comand <3
    echo `checkupdates | tee -a $packages_sync`
}

check_diffrence(){ ### emmm.. I should redo it.. 
    if [[ -n "$*" ]];then 
        packages_existing=("$*")
    fi
    
    for name in "${packages_existing[@]}"
    do
        echo ` cat $package_sync |& grep -e '$name' | tee -a $packages_to_update`
    done
}

clearing(){ ### clear unwanted files disable it in debug mode
    echo rm -f $packages_to_update
    echo rm -f $packages_sync
    echo rm -f $gpu_info
    echo rm -f $temp
    echo rm -f $packages_installed
}