#!/usr/bin/env bash


function __kobman_check_parameter_present
{

  local environment=$1
  local version=$2

  if [[ $environment == "all" ]]; then
    return 0
  fi

  if [[ ! -d $KOBMAN_DIR/envs/kobman-$environment ]]; then
    __kobman_echo_red "$environment is not installed in your local system"
    return 1
  fi
  
  if [[ ! -d $KOBMAN_DIR/envs/kobman-$environment/$version ]]; then
    __kobman_echo_red "Version $version for $environment is not installed in your system."
    return 1
  fi
  
}


function __kobman_interactive_uninstall
{
  if [[ $KOBMAN_INTERACTIVE_USER_MODE = "true" ]]; then
    read -p "Would you like to proceed?(y/n):" c
    if [[ $c == "n" ]]; then
      __kobman_echo_no_colour "Exiting!!!"
      return 1
    else
      return 0
    fi
  else
    return 0
  fi
}

function __kobman_check_ssh_key
{
  if [[ ! -f $HOME/kobman_ssh || ! -f $HOME/kobman_ssh.pub ]]; then
    __kobman_echo_no_colour "No ssh key found."
    __kobman_echo_no_colour ""
    __kobman_echo_no_colour "Follow the instructions in the below link to generate an ssh key and link it with your remote"
    __kobman_echo_no_colour ""
    __kobman_echo_yellow "https://github.com/asa1997/KOBman/blob/ssh_install/docs/Generating%20and%20adding%20ssh%20key.md"
    __kobman_echo_no_colour ""
    __kobman_echo_no_colour "Please try again after generating the ssh key."
    return 1
  else
    return 0
  fi
}

function __kobman_create_fork
{
  local environment=$1
  if [[ -z $KOBMAN_USER_NAMESPACE ]]; then
    __kobman_echo_no_colour "Please run the below command by substituing <namespace> with your GitHub id"
    __kobman_echo_no_colour ""
    __kobman_echo_white "$ export KOBMAN_USER_NAMESPACE=<namespace>"
    __kobman_echo_no_colour ""
    __kobman_echo_no_colour "Eg: export KOBMAN_USER_NAMESPACE=abc123"
    __kobman_echo_no_colour ""
    __kobman_echo_no_colour "Please run the install command after exporting your Github id"
    __kobman_echo_no_colour ""
    __kobman_error_rollback "$environment"
    return 1
  fi
  if [[ -z $(which hub) ]]; then
    __kobman_echo_no_colour "Installing hub..."
    snap install hub --classic 
  fi
  curl -s https://api.github.com/repos/$KOBMAN_USER_NAMESPACE/$environment | grep -q "Not Found"
  if [[ "$?" == "0" ]]; then
    __kobman_echo_white "Creating a fork of https://github.com/$KOBMAN_NAMESPACE/$environment under your namespace $KOBMAN_USER_NAMESPACE"
    git clone -q https://github.com/$KOBMAN_NAMESPACE/$environment $KOBMAN_NAMESPACE/$environment
    cd $KOBMAN_NAMESPACE/$environment
    hub fork
    cd $HOME
    if [[ -d $KOBMAN_NAMESPACE/$environment ]]; then
      rm -rf $KOBMAN_NAMESPACE/$environment
    fi
    # curl -s https://api.github.com/repos/$KOBMAN_USER_NAMESPACE/$environment | grep -q "Not Found"
    # if [[ "$?" == "0" ]]; then
    #   __kobman_echo_red "Could not create fork"
    #   __kobman_echo_red "Please try again"
    #   __kobman_echo_no_colour "Make sure you have given the correct environment name"
    #   __kobman_error_rollback "$environment"
    #   return 1
    # fi
  else
    
    return 0
  fi
}
function __kobman_error_rollback
{
  local environment=$1
  if [[ -d $KOBMAN_DIR/envs/kobman-$environment ]]; then
    rm -rf $KOBMAN_DIR/envs/kobman-$environment
  fi

  if [[ -d $KOBMAN_ENV_ROOT ]]; then
    rm -rf $KOBMAN_ENV_ROOT
  fi

}