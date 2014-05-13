#!/bin/bash
# exit on any error
set -e
# where to find cm tools
CM_EXT=${CM_EXT:-/opt/local/cm_ext/}
# http accessible dir to install parcels
PARCEL_REPO=${PARCEL_REPO:-/var/www/html/parcels/}
SRC_DIR=$PWD
BUILD_DIR=${BUILD_DIR:-$SRC_DIR/target}
DOWNLOAD_DIR=${DOWNLOAD_DIR:-$SRC_DIR/downloads}
# where the parcel should be installed on the *slaves*
INSTALL_DIR=${INSTALL_DIR:-/opt/cloudera/parcels/python2.7/}
# OS this parcel supports
OS=el6
# version
version=1.0.0.$(date +%Y%m%d.%H%M)
# name of pracel
parcelName=custom-jars-$version
# dir we will tar to make the parcel
stagingDir=$BUILD_DIR/$parcelName

################################
## Prebuild checks and env setup
################################
if [[ -d $INSTALL_DIR ]]
then
  echo "Intall dir $INSTALL_DIR already exits, exiting"
  exit 1
fi
sudo mkdir $INSTALL_DIR
sudo chown $USER $INSTALL_DIR
if [[ ! -f $CM_EXT/validator/target/validator.jar ]]
then
  echo "CM Ext $CM_EXT does not exist, exiting"
  exit 1
fi
if [[ ! -w $PARCEL_REPO ]]
then
  echo "Parcel Repo $PARCEL_REPO either does not exist or is not writable, exiting"
  exit 1
fi

# turn on debug statements
set -x
sudo rm -rf $BUILD_DIR
mkdir -p $stagingDir

#####################
## Parcel build steps
#####################
# copy meta to staging dir
cp -R meta $stagingDir
# update the parcel.json with the correct version/os
perl -i -pe "s@%VERSION%@$version@g" $stagingDir/meta/parcel.json
perl -i -pe "s@%OS%@$OS@g" $stagingDir/meta/parcel.json

#####################
## Jar build steps
#####################
# Get jars from some location or build them


#####################
## Parcel build steps
#####################
# move the compiled contents to staing dir
mv $INSTALL_DIR/* $stagingDir/
sudo rmdir $INSTALL_DIR
# validate the parcel
java -jar $CM_EXT/validator/target/validator.jar -d $parcelName/
# create parcel
tar -zcf ${parcelName}-${OS}.parcel --owner root --group root $parcelName/
# install in http dir
mv ${parcelName}-${OS}.parcel $PARCEL_REPO/
# regen manifest
$stagingDir/bin/python $CM_EXT/make_manifest/make_manifest.py $PARCEL_REPO/
