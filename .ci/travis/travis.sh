#!/bin/bash
# Attention, there is no "-x" to avoid problems on Travis
set -e

removeFolderWithProtectedFiles() {
  find $1 -delete
}

case $1 in

checkstyle-and-sevntu)
  export MAVEN_OPTS='-Xmx2000m'
  mvn -e clean verify -DskipTests -DskipITs -Dpmd.skip=true -Dspotbugs.skip=true -Djacoco.skip=true
  ;;

jacoco)
  export MAVEN_OPTS='-Xmx2000m'
  mvn -e clean test \
    jacoco:restore-instrumented-classes \
    jacoco:report@default-report \
    jacoco:check@default-check
  ;;

test)
  mvn -e clean integration-test failsafe:verify -DargLine='-Xms1024m -Xmx2048m'
  ;;

test-de)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=de -Duser.country=DE -Xms1024m -Xmx2048m'
  ;;

test-es)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=es -Duser.country=ES -Xms1024m -Xmx2048m'
  ;;

test-fi)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=fi -Duser.country=FI -Xms1024m -Xmx2048m'
  ;;

test-fr)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=fr -Duser.country=FR -Xms1024m -Xmx2048m'
  ;;

test-zh)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=zh -Duser.country=CN -Xms1024m -Xmx2048m'
  ;;

test-ja)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=ja -Duser.country=JP -Xms1024m -Xmx2048m'
  ;;

test-pt)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=pt -Duser.country=PT -Xms1024m -Xmx2048m'
  ;;

test-tr)
  mvn -e clean integration-test failsafe:verify \
    -DargLine='-Duser.language=tr -Duser.country=TR -Xms1024m -Xmx2048m'
  ;;

osx-assembly)
  export JAVA_HOME=$(/usr/libexec/java_home)
  mvn -e package -Passembly
  ;;

osx-package)
  export JAVA_HOME=$(/usr/libexec/java_home)
  mvn -e package
  ;;

osx-jdk13-package)
  export JAVA_HOME=$(/usr/libexec/java_home)
  mvn -e package
  ;;

osx-jdk13-assembly)
  mvn -e package -Passembly
  ;;

site)
  mvn -e clean site -Pno-validations
  ;;

javac8)
  # InputCustomImportOrderNoPackage2 - nothing is required in front of first import
  # InputIllegalTypePackageClassName - bad import for testing
  # InputVisibilityModifierPackageClassName - bad import for testing
  files=($(grep -REL --include='*.java' \
        --exclude='InputCustomImportOrderNoPackage2.java' \
        --exclude='InputIllegalTypePackageClassName.java' \
        --exclude='InputVisibilityModifierPackageClassName.java' \
        '//non-compiled (syntax|with javac)?\:' \
        src/test/resources-noncompilable))
  mkdir -p target
  for file in "${files[@]}"
  do
    javac -d target "${file}"
  done
  ;;

javac9)
  files=($(grep -Rl --include='*.java' ': Compilable with Java9' \
        src/test/resources-noncompilable || true))
  if [[  ${#files[@]} -eq 0 ]]; then
    echo "No Java9 files to process"
  else
      mkdir -p target
      for file in "${files[@]}"
      do
        javac --release 9 -d target "${file}"
      done
  fi
  ;;

javac14)
  files=($(grep -Rl --include='*.java' ': Compilable with Java14' \
        src/test/resources-noncompilable || true))
  if [[  ${#files[@]} -eq 0 ]]; then
    echo "No Java14 files to process"
  else
      mkdir -p target
      for file in "${files[@]}"
      do
        javac --release 14 --enable-preview -d target "${file}"
      done
  fi
  ;;

javac15)
  files=($(grep -Rl --include='*.java' ': Compilable with Java15' \
        src/test/resources-noncompilable || true))
  if [[  ${#files[@]} -eq 0 ]]; then
    echo "No Java15 files to process"
  else
      mkdir -p target
      for file in "${files[@]}"
      do
        javac --release 15 --enable-preview -d target "${file}"
      done
  fi
  ;;

jdk14-assembly-site)
  mvn -e package -Passembly
  mvn -e site -Pno-validations
  ;;

jdk14-verify-limited)
  # we skip pmd and spotbugs as they executed in special Travis build
  mvn -e verify -Dpmd.skip=true -Dspotbugs.skip=true
  ;;

versions)
  if [ -v TRAVIS_EVENT_TYPE ] && [ $TRAVIS_EVENT_TYPE != "cron" ] ; then exit 0; fi
  mvn -e clean versions:dependency-updates-report versions:plugin-updates-report
  if [ $(grep "<nextVersion>" target/*-updates-report.xml | cat | wc -l) -gt 0 ]; then
    echo "Version reports (dependency-updates-report.xml):"
    cat target/dependency-updates-report.xml
    echo "Version reports (plugin-updates-report.xml):"
    cat target/plugin-updates-report.xml
    echo "New dependency versions:"
    grep -B 7 -A 7 "<nextVersion>" target/dependency-updates-report.xml | cat
    echo "New plugin versions:"
    grep -B 4 -A 7 "<nextVersion>" target/plugin-updates-report.xml | cat
    echo "Verification is failed."
    sleep 5s
    false
  else
    echo "No new versions found"
  fi
  ;;

assembly-run-all-jar)
  mvn -e clean package -Passembly
  CS_POM_VERSION=$(mvn -e -q -Dexec.executable='echo' -Dexec.args='${project.version}' \
                     --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec)
  echo version:$CS_POM_VERSION
  mkdir -p .ci-temp
  FOLDER=src/it/resources/com/google/checkstyle/test/chapter7javadoc/rule73wherejavadocrequired
  FILE=InputMissingJavadocTypeCheckNoViolations.java
  java -jar target/checkstyle-$CS_POM_VERSION-all.jar -c /google_checks.xml \
        $FOLDER/$FILE > .ci-temp/output.log
  fail=0
  if grep -vE '(Starting audit)|(warning)|(Audit done.)' .ci-temp/output.log ; then
    fail=1;
  elif grep 'warning' .ci-temp/output.log ; then
    fail=1;
  fi
  rm .ci-temp/output.log
  sleep 5
  exit $fail
  ;;

release-dry-run)
  if [ $(git log -1 | grep -E "\[maven-release-plugin\] prepare release" | cat | wc -l) -lt 1 ];then
    mvn -e release:prepare -DdryRun=true --batch-mode -Darguments='-DskipTests -DskipITs \
      -Djacoco.skip=true -Dpmd.skip=true -Dspotbugs.skip=true -Dxml.skip=true \
      -Dcheckstyle.ant.skip=true -Dcheckstyle.skip=true -Dgpg.skip=true'
    mvn -e release:clean
  fi
  ;;

releasenotes-gen)
  .ci/travis/xtr_releasenotes-gen.sh
  ;;

pr-description)
  .ci/travis/xtr_pr-description.sh
  ;;

pr-age)
  # Travis merges the PR commit into origin/master
  # This command undoes that to work with the original branch
  # if it notices a merge commit
  if git show --summary HEAD | grep ^Merge: ;
  then
    git reset --hard `git log -n 1 --no-merges --pretty=format:"%h"`
  fi

  PR_MASTER=`git merge-base origin/master HEAD`
  COMMITS_SINCE_MASTER=`git rev-list --count $PR_MASTER..origin/master`
  MAX_ALLOWED=10

  echo "The PR is based on a master that is $COMMITS_SINCE_MASTER commit(s) old."
  echo "The max allowed is $MAX_ALLOWED."

  if (( $COMMITS_SINCE_MASTER > $MAX_ALLOWED ));
  then
    echo "This PR is too old and should be rebased on origin/master."
    sleep 5s
    false
  fi
  ;;

check-chmod)
  .ci/travis/checkchmod.sh
  ;;

no-error-test-sbe)
  CS_POM_VERSION=$(mvn -e -q -Dexec.executable='echo' -Dexec.args='${project.version}' \
                    --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec)
  echo version:$CS_POM_VERSION
  mvn -e clean install -Pno-validations
  mkdir -p .ci-temp/
  cd .ci-temp/
  git clone https://github.com/real-logic/simple-binary-encoding.git
  cd simple-binary-encoding
  sed -i'' \
    "s/'com.puppycrawl.tools:checkstyle:.*'/'com.puppycrawl.tools:checkstyle:$CS_POM_VERSION'/" \
    build.gradle
  ./gradlew build --stacktrace
  cd ..
  removeFolderWithProtectedFiles simple-binary-encoding
  ;;

verify-no-exception-configs)
  mkdir -p .ci-temp/verify-no-exception-configs
  working_dir=.ci-temp/verify-no-exception-configs
  wget -q \
    --directory-prefix $working_dir \
    --no-clobber \
    https://raw.githubusercontent.com/checkstyle/contribution/master/checkstyle-tester/checks-nonjavadoc-error.xml
  wget -q \
    --directory-prefix $working_dir \
    --no-clobber \
    https://raw.githubusercontent.com/checkstyle/contribution/master/checkstyle-tester/checks-only-javadoc-error.xml
  MODULES_WITH_EXTERNAL_FILES="Filter|ImportControl"
  xmlstarlet sel --net --template -m .//module -v "@name" \
    -n $working_dir/checks-nonjavadoc-error.xml -n $working_dir/checks-only-javadoc-error.xml \
    | grep -vE $MODULES_WITH_EXTERNAL_FILES | grep -v "^$" \
    | sort | uniq | sed "s/Check$//" > $working_dir/web.txt
  xmlstarlet sel --net --template -m .//module -v "@name" -n config/checkstyle_checks.xml \
    | grep -vE $MODULES_WITH_EXTERNAL_FILES | grep -v "^$" \
    | sort | uniq | sed "s/Check$//" > $working_dir/file.txt
  DIFF_TEXT=$(diff -u $working_dir/web.txt $working_dir/file.txt | cat)
  fail=0
  if [[ $DIFF_TEXT != "" ]]; then
    echo "Diff is detected."
    if [[ $TRAVIS_PULL_REQUEST =~ ^([0-9]+)$ ]]; then
      LINK_PR=https://api.github.com/repos/checkstyle/checkstyle/pulls/$TRAVIS_PULL_REQUEST
      REGEXP="https://github.com/checkstyle/contribution/pull/"
      PR_DESC=$(curl -s -H "Authorization: token $READ_ONLY_TOKEN" $LINK_PR \
                  | jq '.body' | grep $REGEXP | cat )
      echo 'PR Description grepped:'${PR_DESC:0:180}
      if [[ -z $PR_DESC ]]; then
        echo 'You introduce new Check'
        diff -u $working_dir/web.txt $working_dir/file.txt | cat
        echo 'Please create PR to repository https://github.com/checkstyle/contribution'
        echo 'and add your new Check '
        echo '   to file checkstyle-tester/checks-nonjavadoc-error.xml'
        echo 'or to file checkstyle-tester/checks-only-javadoc-error.xml'
        echo 'PR for contribution repository will be merged right after this PR.'
        fail=1;
      fi
    else
      diff -u $working_dir/web.txt $working_dir/file.txt | cat
      echo 'file config/checkstyle_checks.xml contains Check that is not present at:'
      echo 'https://github.com/checkstyle/contribution/blob/master/checkstyle-tester/checks-nonjavadoc-error.xml'
      echo 'https://github.com/checkstyle/contribution/blob/master/checkstyle-tester/checks-only-javadoc-error.xml'
      echo 'Please add new Check to one of such files to let Check participate in auto testing'
      fail=1;
    fi
  fi
  removeFolderWithProtectedFiles .ci-temp/verify-no-exception-configs
  sleep 5
  exit $fail
  ;;

check-since-version)
  # Travis merges the PR commit into origin/master
  # This identifies the PR's original commit
  # if it notices a merge commit
  HEAD=`git rev-parse HEAD`
  if git show --summary HEAD | grep ^Merge: ; then
      echo "Merge detected."
      HEAD=`git log -n 1 --no-merges --pretty=format:"%H"`
  fi
  # Identify previous commit to know how much to examine
  # Script assumes we are only working with 1 commit if we are in master
  # Otherwise, it looks for the common ancestor with master
  COMMIT=`git rev-parse $HEAD`
  echo "PR commit: $COMMIT"

  HEAD_NEW_FILES=$(git show $COMMIT | cat | grep -A 1 "\-\-\- /dev/null" | cat)
  echo "New files in commit: $HEAD_NEW_FILES"
  MODULE_REG=".*(Check|Filter).java"
  REGEXP="b/src/main/java/com/puppycrawl/tools/checkstyle/(checks|filters|filefilters)/$MODULE_REG"
  NEW_CHECK_FILE=$(git show $COMMIT | cat | grep -A 1 "\-\-\- /dev/null" | cat | \
    grep -E "$REGEXP" | \
    cat | sed "s/+++ b\///")
  echo "New Check file: $NEW_CHECK_FILE"

  if [ -f "$NEW_CHECK_FILE" ]; then
    echo "New Check detected: $NEW_CHECK_FILE"
    CS_POM_VERSION=$(mvn -e -q -Dexec.executable='echo' -Dexec.args='${project.version}' \
                     --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec)
    CS_RELEASE_VERSION=$(echo $CS_POM_VERSION | cut -d '-' -f 1)
    echo "CS Release version: $CS_RELEASE_VERSION"
    echo "Grep for @since $CS_RELEASE_VERSION"
    sleep 5s
    grep "* @since $CS_RELEASE_VERSION" $NEW_CHECK_FILE
  else
    echo "No new Check, all is good."
  fi
  ;;

spotbugs-and-pmd)
  mkdir -p .ci-temp/spotbugs-and-pmd
  CHECKSTYLE_DIR=$(pwd)
  export MAVEN_OPTS='-Xmx2000m'
  mvn -e clean test-compile pmd:check spotbugs:check
  cd .ci-temp/spotbugs-and-pmd
  grep "Processing_Errors" "$CHECKSTYLE_DIR/target/site/pmd.html" | cat > errors.log
  RESULT=$(cat errors.log | wc -l)
  if [[ $RESULT != 0 ]]; then
    echo "Errors are detected in target/site/pmd.html."
    sleep 5s
  fi
  cd ..
  removeFolderWithProtectedFiles spotbugs-and-pmd
  exit "$RESULT"
;;

markdownlint)
  mdl -g . && echo "All .md files verified"
  ;;

*)
  echo "Unexpected argument: $1"
  sleep 5s
  false
  ;;

esac
