set parm=%1
set subdir=a%parm:~1,3%
echo subdir: %subdir% dir: %parm%
cat C:/Users/User/work/gits/joeis-lite/src/irvine/oeis/%subdir%/%parm%.java
