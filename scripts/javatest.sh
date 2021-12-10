set -e # exit when another command exits


if [ -z ${INPUT_JUNIT} ]; then
    LIBS="${ACTION_PATH}/lib"
else
    LIBS="$INPUT_JUNIT"
fi

TMP_DIR="$(mktemp -d)" # create temp dir

echo "SOURCE  = $INPUT_SOURCE"
echo "LIBS    = $LIBS"
echo "TMP_DIR = $TMP_DIR"
echo

for SRC in ${INPUT_SOURCE}; do
(
    cd "$SRC"

    PWD="$(pwd)"
    echo "Entering source dir ${PWD}..."

    find . -name "*.java" -exec mkdir -p "${TMP_DIR}/$(dirname {})" \; -exec cp "{}" "$TMP_DIR" \; # copy source file to temp dir (and create missing dirs)
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
)

time (java -jar "${LIBS}/junit-platform-console-standalone-1.8.1.jar" --classpath ".:$TMP_DIR" --fail-if-no-tests --include-engine=junit-jupiter --scan-classpath --reports-dir=reports 2>/dev/null | grep -wv "Thanks")
echo "JUnit run-all time"
echo
