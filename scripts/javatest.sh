if [ -z ${INPUT_JUNIT} ]; then
    LIBS="${INTERNAL_LIB}"
else
    LIBS="${INPUT_JUNIT}"
fi

echo "SOURCE = ${INPUT_SOURCE}"
echo "LIBS   = ${LIBS}"
echo

for SRC in ${INPUT_SOURCE}; do
(
    cd "${SRC}"
    pwd
    echo

    find . -type f -name "*.class" -exec rm {}  \;    #remove classfiles
    find . -name "*.java" #print sourcefiles
    time (find . -name "*.java" | xargs javac -cp "${LIBS}/*") #build classes
    echo "Java build time"
    echo

    find . -type f -name "*.class" #print classfiles
    echo

    time (java -jar "${LIBS}/junit-platform-console-standalone-1.8.1.jar" --classpath . --fail-if-no-tests --include-engine=junit-jupiter --scan-classpath --reports-dir=reports 2>/dev/null | grep -wv "Thanks")
    echo "JUnit run-all time"
    echo

    find . -type f -name "*.class" -exec rm {}  \;    #remove classfiles
)
done
