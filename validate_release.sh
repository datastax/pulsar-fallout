#bin/bash

. validate_release_env.sh

TESTNAME=$1
HERE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

BASEDIR=$HERE/release_validation
TEMPLATE=release_validation/template.yaml
OUT_DIR=test_out
mkdir -p $HERE/$OUT_DIR

# overriding the template param value in order to force using kind provisioner
OVERRIDE_TEMPLATE_VALUES=" gke_project=$GKE_PROJECT use_ctool=false use_gke=true image.version=$PULSAR_VERSION image.name=$PULSAR_IMAGE"


SUCCESS_TEXT="Everything looks good"


run_test() {
   local test=$1
   local TESTNAME=$(basename -- "$test")
   local TESTOUTDIR=$OUT_DIR/$TESTNAME
   local OUTFILE=$HERE/$TESTOUTDIR/output.txt
   mkdir -p $HERE/$TESTOUTDIR
   echo "Running $test"
   echo "Template $TEMPLATE"
   echo "Output to $OUTFILE"
   echo "Look for kube_config.yaml files inside $HERE/$TESTOUTDIR in order to connect to the k8s cluster"
   echo "The cluster will be automatically disposed, please wait for the test to complete the execution, otherwise you have to clean up the cluster manually"
   echo "Test is running now, it will probably take at least 20 minutes..."
   $FALLOUT_CMD exec --use-unique-output-dir --params $FALLOUT_BASEDIR/$test $FALLOUT_BASEDIR/$TEMPLATE $FALLOUT_BASEDIR/$CREDS $FALLOUT_BASEDIR/$OUT_DIR/$TESTNAME $OVERRIDE_TEMPLATE_VALUES 2>&1 1>$OUTFILE

   ERRORSFILE=$(find $TESTOUTDIR -name "fallout-errors.log")
   MAINLOGFILE=$(find $TESTOUTDIR -name "fallout-shared.log")
   echo "Aggregated logs are located in $MAINLOGFILE"

   if grep -q "$SUCCESS_TEXT" $OUTFILE
   then
     echo "Test $test PASSED"
   else
     echo "Test $test FAILED"
     echo "Check the error in $ERRORSFILE"
   fi
}

echo "Running test $TESTNAME"
run_test $TESTNAME


