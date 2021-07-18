#!/bin/bash

#CURRENT VERSION IS IN DEVELOPEMENT AND DIDN"T PASS THE FINAL TEST

################
#     INFO     #
################
### current version is keeping the IDEA of future pcclib (package compatibility check)
### The idea is that to create simple bash functions to check dependecies, errors etc and create automatic
### output information, for the user with solutions of the problem. library is written in bash to easily transfer 
### it to other languages like Python/C++/Perl/Rust as running functions to call
### It suposed to be multiplatform solution.

### YES... I consider error handling of NVIDIA but it... it's too much for this state and any future state.
### This is written for Lutris as a solution to fix sone of the basic issues.


### Things to improve:
### basicly half of the code
### argvs for debug mode + puting manager
### arrays like existing packages as a "python like" dicts to make smaller cache problem with unwanted files
### error output of packages that doesnt exist
### controls values
### function results with output of possible solution and breaks in some cases (If repo is not available )
### Creates 2 diffrent functions with diffrent output of checking like MUST HAVE and MIGHT HAVE or SUGESTED
### Enter/space as input value error Handling
### Check if there is installed 2 diffrent drivers packages if there is only one gpu
### optimus checker
### dxvk check ;-;


#Arrays
declare -a gpu_names=(
    NVIDIA
    AMD 
    Intel
    )
gpu_comp=()
declare -a package_men_list=(
    pacman
    apt
    apt-get 
    yum
    dnf
    eopkg
)

declare -a packages_existing=()


#File names
gpu_info="temp/gpu.txt"
temp="temp/temp.txt"
packages_installed="temp/ExistingPackages.txt"

package_info='pacman -Q '

gpus=$(lspci | grep -i  'vga\|3d\|2d' > $gpu_info )
session=$XDG_SESSION_TYPE


#check if exist in 
if_in_arr(){
    elem=$1
    shift
    array=("$@")
    if c=$'\x1E' && p="${c}${elem} ${c}" && [[ ! "${array[@]/#/${c}} ${c}" =~ $p ]]; then
        return 0
    else
        return 1
    fi
}

#check if file is empty and exist
if_f_not_empty(){
    FILENAME=$*
    if [ -f ${FILENAME} ];then
        if [ -s ${FILENAME} ];then
            echo "not empty"
        else
            echo "empty"
        fi
    else
        echo "File not exists"
    fi
}

#send existing packages to array
append_packages_arr(){
    str="$*"
    packages_existing+=($(echo $str | tr " " "\n"))
}

#check hardwere
hardwere_check(){
    for name in "${gpu_names[@]}"
    do
        if grep -q $name "$gpu_info"; then
            gpu_comp+=("$name")
        fi
    done
}


session_compatibility(){
    if [ $session == wayland ]; then
        echo wayland
    elif [ $session == x11 ] || [ $session == X11 ]; then
        echo x11
    fi
}



select_manager(){
    read -r -p  "select proper package from list: ${package_men_list[*]}: " package_men
    case "$package_men" in
        "pacman") source configs/pacman.cfg ;;
        "dnf") source configs/dnf.cfg ;;        ##  in progres
        "apt") echo $package_men ;;             ##  planned
        "apt-get") echo $package_men ;;         ##  planned
        "yum") echo $package_men ;;             ##  planned       
        "eopkg") echo $package_men ;;           ##  planned 
        *) echo "manger is not on list"
    esac
}
select_manager
#check software
driver_check(){
    local comm
    for name in "${gpu_comp[@]}"
    do
    
        if [ $name == NVIDIA ];then
            comm=`$package_info $nvidia_drivers `
            echo $comm 
        elif [ $name == AMD ];then
            comm=`$package_info $amd_drivers  `
            echo $comm
        elif [ $name == Intel ];then
            comm=`$package_info $intel_drivers  `
            echo $comm
        else
            echo "driver for $name were not found"
        fi
    done
}


#vulkan_comp
vulkan_check(){
    for name in "${gpu_comp[@]}"
    do
        comm=
        if [ $name == NVIDIA ];then
            comm=`$package_info $nvidia_vulkan_packages `
            echo $comm 
        elif [ $name == AMD ];then
            comm=`$package_info $amd_vulkan_packages `
            echo $comm
        elif [ $name == Intel ];then
            comm=`$package_info $intel_vulkan_packages `
            echo $comm
        else
            echo "driver for $name were not found"
        fi
    done
}

#### Change name to check_packages and call it as a variable with names. 
check_wine(){
    local dep="$wine_packages"
    #local coun=$(wc -w <<< "$dep")
    local comm=`$package_info $(echo $dep) |&  grep -v 'error' | tee -a $path` 

    check=$(if_f_not_empty $path)
    to_move=$(cat $path | awk '{ print $1 }' )
    append_packages_arr $to_move
    $(rm -f $path)
}

dependacy_hell(){
    local dep="$wine_dependecy_hell"
    local comm=`$package_info $(echo $dep) |&  grep -v 'error' | tee -a $path`
    
    check=$(if_f_not_empty $path)
    to_move=$(cat $path | awk '{ print $1 }' )
    append_packages_arr $to_move
    for i in "${packages_existing[@]}"
    do
        echo "$i" ###debug
    done
    
}

#### SPECIAL CASES #####
# Here will be special cases of formating text or checks for systems.
# for example some packages might be only installed if some library/repo is enabled.

# Maybe it will be transfered to other files as special_cases. there is no need to create each 
# bash file for each system. Better configs

check_pacmanconf(){
    local path="/etc/pacman.conf"
    local multi="#\[multilib\]"
    local multi_test="#\[multilib-testing\]"
    if [ "$(grep -c $multi $path)" -ge 1  ];then 
        echo $multi_test
    elif [ "$(grep -c $multi_test $path)" -ge 1 ];then
        echo $multi
    else
        echo none #change to create error to handle and stop rest of the scripts!
    fi
}


