if [ -z ${JUNIT_DIR} ]; then
    LIBS="${INTERNAL_LIB}"
else
    LIBS="${JUNIT_DIR}"
fi

echo "LIBS = ${LIBS}"
echo

find . -type f -name "*.class" -exec rm {}  \;    #remove classfiles
find . -name "*.java" #print sourcefiles
time (find . -name "*.java" | xargs javac -cp "${LIBS}/*") #build classes
echo "Java build time"
echo

find . -type f -name "*.class" #print classfiles
echo

time (java -jar "${LIBS}/junit-platform-console-standalone-1.8.1.jar" --classpath . --fail-if-no-tests --include-engine=junit-jupiter --include-classname='.*Test.*' --scan-classpath --reports-dir=reports 2>/dev/null | grep -wv "Thanks")
echo "JUnit run-all time"
echo

find . -type f -name "*.class" -exec rm {}  \;    #remove classfiles
