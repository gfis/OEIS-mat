echo OFF
set DIR=%1
if "%DIR%" == "common"  (
  title %DIR%
  cd %GITS%/OEIS-mat/%DIR%
)
if "%DIR%" == "contrib"  (
  title %DIR%
  cd %GITS%/OEIS-mat/%DIR%
)
if "%DIR%" == "data"  (
  title %DIR%
  cd %GITS%/OEIS-mat/%DIR%
)
if "%DIR%" == "lite" (
  title %DIR%
  cd %GITS%/joeis-lite/internal/fischer
)
if "%DIR%" == "robot" (
  title %DIR%
  cd %GITS%/OEIS-mat/%DIR%
)
if "%DIR%" == "scripts" (
  title %DIR%
  cd %GITS%/OEIS-mat/%DIR%
)
