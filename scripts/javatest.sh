if [ -z ${{ inputs.junit_dir }} ]; then
    LIBS="${{ github.action_path }}/lib"
else
    LIBS="${{ inputs.junit_dir }}"
fi

echo "LIBS = ${LIBS}"
echo

find . -type f -name "*.class" -exec rm {}  \;    #remove classfiles
time (find . -name "*.java" | xargs javac -cp "${LIBS}/*") #build classes
echo "Java build time"

time (java -jar "${LIBS}/junit-platform-console-standalone-1.8.1.jar" --classpath . --fail-if-no-tests --include-engine=junit-jupiter --include-classname='.*Test.*' --scan-classpath --reports-dir=reports 2>/dev/null | grep -wv "Thanks")
echo "JUnit run-all time"
find . -type f -name "*.class" -exec rm {}  \;    #remove classfiles
