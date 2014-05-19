#!/bin/bash
CUSTOM_JARS_DIRNAME=${PARCEL_DIRNAME:-"%PARCEL_NAME%"}
JARS=$(find $PARCELS_ROOT/$CUSTOM_JARS_DIRNAME/lib/ -name '*.jar' -printf "%p:" | perl -pe 's@:$@@g') 
if [ -n "${HADOOP_CLASSPATH}" ]; then
  export HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:$JARS"
else
  export HADOOP_CLASSPATH="${HADOOP_CLASSPATH}:$JARS"
fi

