set -e # exit when another command exits

# define tree command, if it isn't installed yet
# see stackoverflow answer https://stackoverflow.com/a/62589932
[ -z $(which tree) ] && function tree() (
    find ${1:-.} | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"
)


if [ -z ${INPUT_JUNIT} ]; then
    LIBS="${ACTION_PATH}/lib"
else
    LIBS="$INPUT_JUNIT"
fi

TMP_DIR="$(mktemp -d)" # create temp dir

echo
echo "Script options:"
echo "--------------------------------------------------"
echo "SOURCE  = $INPUT_SOURCE"
echo "LIBS    = $LIBS"
echo "TMP_DIR = $TMP_DIR"
echo

for SRC in ${INPUT_SOURCE}; do
(
    cd "$SRC"

    PWD="$(pwd)"
    echo "Entering source dir ${PWD}..."

    # copy source file to temp dir (and create missing dirs)
    find . -name "*.java" -exec mkdir -p "${TMP_DIR}/$(dirname {})" \; -exec cp "{}" "${TMP_DIR}/$(dirname {})" \; -exec echo "  Copied {} to ${TMP_DIR}/{}" \;

    echo "Leaving source dir..."
    echo
)
done

(
    cd "$TMP_DIR"

    PWD="$(pwd)"
    echo "Entering temp dir ${PWD}..."
    echo

    time (find . -name "*.java" | xargs javac -cp "${LIBS}/*") # compile source files
    echo "Java build time"
    echo

    echo "Content of temp dir:"
    tree

    echo "Leaving temp dir..."
    echo
)

time (java -jar "${LIBS}/junit-platform-console-standalone-1.8.1.jar" --classpath ".:$TMP_DIR" --fail-if-no-tests --include-engine=junit-jupiter --scan-classpath --reports-dir=reports 2>/dev/null | grep -wv "Thanks")
echo "JUnit run-all time"
echo
