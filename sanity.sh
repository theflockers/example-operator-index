#! /bin/bash
#  PNAME=$$(bin/yq "select(.schema == \"olm.package\") | .name" catalog/$(OPERATOR_NAME)/catalog.yaml)
#  @echo `bin/yq "select(.schema == \"olm.package\") | .name" catalog/$(OPERATOR_NAME)/catalog.yaml`
#  @export PNAME=$(shell bin/yq "select(.schema == \"olm.package\") | .name" catalog/$(OPERATOR_NAME)/catalog.yaml)
#  @echo package name is $(PNAME)
#  @if [ ${PNAME} != ${OPERATOR_NAME} ] \ 
#  then \ 
#  $(error "operator name in veneer and Makefile does not agree: Makefile(${OPERATOR_NAME}) Veneer:(${PNAME})") 
#  fi

function usage () {
  echo "usage: $0 -n package-name -f veneer-file-name"
  exit 1
}

YQ=bin/yq

while getopts 'n:f:' arg; 
do
  case "$arg" in
    f) FILENAME=$OPTARG ;;
    n) PKGNAME=$OPTARG ;;
    h) usage ;; 
  esac
done
shift `expr $OPTIND - 1`

#echo "FILENAME is $FILENAME"
#echo "PKGNAME is $PKGNAME"

if [ -z $FILENAME ]
then
  echo "veneer-file-name is empty"
  usage
fi

if [ ! -e $FILENAME ]
then
  echo "$FILENAME does not exist"
  exit 253
fi

if [ -z $PKGNAME ]
then
  echo "package-name is empty"
  usage
fi

if [ ! -e $YQ ]
then
  echo "unable to find yq binary: $YQ"
  exit 255
fi

SCHEMA_PNAME=$($YQ "select(.schema == \"olm.package\") | .name" ${FILENAME})
if [ $SCHEMA_PNAME != $PKGNAME ] 
then
  echo "operator name in veneer and Makefile do not agree:"
  echo "    Makefile(${SCHEMA_PNAME})"
  echo "    veneer(  ${PKGNAME})"
  exit 254
else
  echo "operator name match between veneer and Makefile"
fi


