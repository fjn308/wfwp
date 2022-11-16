FileDelete, sha256
sha256 := sha("wfwp.exe")
If !sha256
{
    Msgbox, Failed.
    ExitApp
}
FileAppend, %sha256%, sha256
#Include, scripts\functions.ahk
