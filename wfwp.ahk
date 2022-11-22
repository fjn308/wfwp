;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Critical, On
Menu, Tray, Tip, initializing...
version := "v0.17"
If (A_ScriptName = "wfwpnew.exe")
{
    FileCopy, wfwpnew.exe, wfwp.exe, 1
    Run, wfwp.exe
    ExitApp
}
Else If (A_ScriptName = "wfwp.exe")
{
    If FileExist("wfwpnew.exe")
        TrayTip, , wfwp is updated to %version%., , 16
    FileDelete, wfwpnew.exe
}
Else If (A_ScriptName = "wfwp.ahk")
{
    If  FileExist("commons.ico")
        Menu, Tray, Icon, commons.ico
}
Else
{
    MsgBox, , wfwp, My name should be wfwp. I will exit.
    ExitApp
}
FileInstall, commons.png, commons.png, 1
; If (((A_MM = "10") && (A_DD = "30")) || ((A_MM = "10") && (A_DD = "31")) || ((A_MM = "11") && (A_DD = "01")))
; {
;     FileInstall, cache\1f383.png, cache\1f383.png, 1
;     If FileExist("cache\1f383.png")
;         Menu, Tray, Icon, cache\1f383.png
; }
; Else If (A_ScriptName = "wfwp.exe")
;     FileDelete, cache\1f383.png
; If (((A_MM = "12") && (A_DD = "24")) || ((A_MM = "12") && (A_DD = "25")) || ((A_MM = "12") && (A_DD = "26")))
; {
;     FileInstall, cache\1f384.png, cache\1f384.png, 1
;     If FileExist("cache\1f384.png")
;         Menu, Tray, Icon, cache\1f384.png
; }
; Else If (A_ScriptName = "wfwp.exe")
;     FileDelete, cache\1f384.png
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monitorcount := countmonitor()
monitors := []
monitortypes := []
overuhd := false
Loop, %monitorcount%
{
    indexfromzero := A_Index - 1
    monitor := detectmonitor(indexfromzero)
    If monitor
    {
        monitors.Push(monitor)
        monitororientation := SubStr(monitor, 1, 1)
        monitorresolution := SubStr(monitor, 2, 1)
        If (monitorresolution = 4)
            overuhd := true, monitorresolution := 3
        monitortype := monitororientation . monitorresolution
        monitortypes.Push(monitortype)
    }
}
monitorcount := monitors.Length()
If !monitorcount
{
    MsgBox, , wfwp, Failed to detect any monitor. wfwp will exit.
    ExitApp
}
If overuhd
    MsgBox, , wfwp, You have a screen with resolution over UHD (3840*2160), but wfwp will still set UHD wallpapers on it, which may cause a waste.
If setposition()
    MsgBox, , wfwp, Failed to set position. wfwp recommends you to set the display option for wallpapers as FILL manually.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
firstrun := false
If !FileExist("config")
    firstrun := true
Else
    FileRead, configurations, config
configarray := StrSplit(configurations, "@", , 2)
configuration := configarray[1]
If configuration Is Not xdigit
    firstrun := true
Else
{
    configuration := StrReplace(configuration, "0x")
    If (StrLen(configuration) != 18)
        firstrun := true
}
If firstrun
    FileDelete, config
nextswitch := 0
If ((!firstrun) && (configarray.Length() = 2))
{
    nextswitchcache := configarray[2]
    If nextswitchcache Is time
        nextswitch := nextswitchcache
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
If firstrun
    loaddefault(proxy, ip1, ip2, ip3, ip4, port, frequency, minute, nminute, binaryexclude)
Else
    loadconfiguration(configuration, proxy, ip1, ip2, ip3, ip4, port, frequency, minute, nminute, binaryexclude)
arthropod := extractbit(binaryexclude, 0)
bird := extractbit(binaryexclude, 1)
ppeople := extractbit(binaryexclude, 2)
amphibian := extractbit(binaryexclude, 3)
fish := extractbit(binaryexclude, 4)
reptile := extractbit(binaryexclude, 5)
oanimals := extractbit(binaryexclude, 6)
bone := extractbit(binaryexclude, 7)
shell := extractbit(binaryexclude, 8)
plant := extractbit(binaryexclude, 9)
fungi := extractbit(binaryexclude, 10)
olifeforms := extractbit(binaryexclude, 11)
GoSub, snapshot
If FileExist("download\redirect")
{
    FileRead, downloadfolder, download\redirect
    FileCreateDir, %downloadfolder%
    If ErrorLevel
    {
        downloadfolder := A_ScriptDir . "\download"
        FileDelete, download\redirect
    }
}
Else If FileExist("download")
    downloadfolder := A_ScriptDir . "\download"
Else
    downloadfolder := 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FileDelete, urls.sha1
moveonlist := 0
moveonlistreal := -1
qualifieddatanumber := 0
If FileExist("resolved.dat")
{
    If !firstrun
        qualifieddatanumber := superdat2sha1("resolved.dat", "urls.sha1", monitortypes, binaryexclude)
    If qualifieddatanumber
    {
        moveonlist := premoveon("urls.sha1", "cache", monitors)
        superremove("urls.sha1", "cache")
    }
    Else
    {
        FileDelete, urls.sha1
        FileDelete, resolved.dat
    }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
datfilelength := countdata("resolved.dat")
blacklistlength := countandsortblacklist("blacklist")
Menu, Tray, NoStandard
If (monitorcount > 1)
{
    Menu, Tray, Add, Switch One to the Next, switchonemenu, P3
    Menu, Tray, Add, Switch All to the Nexts, switchmenu, P2
}
Else
    Menu, Tray, Add, Switch to the Next, switchmenu, P3
Menu, Tray, Add, Check Picture Details, detailsmenu, P7
Menu, Tray, Add, Download the Original, originalmenu, P1
Menu, blacklistdotmenu, Add, Blacklist This Picture and Switch to the Next (%blacklistlength%), blacklistmenu, P4
Menu, blacklistdotmenu, Add, Un-Blacklist the Last Picture and Switch Back, unblacklistmenu, P6
Menu, blacklistdotmenu, Add, Clear the Blacklist (Caution!), clearblacklistmenu, P8
Menu, Tray, Add, Blacklist ..., :blacklistdotmenu
Menu, Tray, Add
Menu, Tray, Add, Settings, settingsmenu, P13
Menu, Tray, Add, Re-Detect Monitors (%monitorcount%), detectmenu, P15
Menu, updatedotmenu, Add, Update the Database (%qualifieddatanumber%/%datfilelength%), updatedatamenu, P11
Menu, updatedotmenu, Add, Update wfwp (%version%), updatewfwpmenu, P12
Menu, Tray, Add, Update ..., :updatedotmenu
If (A_ScriptName = "wfwp.ahk")
    Menu, updatedotmenu, Disable, 2&
Menu, Tray, Add
Menu, Tray, Add, Exit, exitmenu, P16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
monitortypecounts := types2countarray(monitortypes)
numberrestrictions := types2numberrestrictions(monitortypecounts)
sizerestrictions := types2sizerestrictions(monitortypecounts)
timerestrictions := [21, 21, 25, 25, 38, 38]
totalnumberrestriction := 0
Loop, 6
    totalnumberrestriction := totalnumberrestriction + numberrestrictions[A_Index]
downloading := false
fromdatabasecheck := false
fromdetails := false
fromoriginal := false
fromselectfolder := false
indexjustclicked := 0
switching := false
Global lifetime := 10
Global oddclick := false
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
If ((!firstrun) && qualifieddatanumber)
{
    If !nextswitch
        moveonlist := 0
    If ((!nextswitch) || moveonlist)
        GoSub, switchmenu
    Else
    {
        nextswitchtogo := preparetimer(nextswitch)
        If nextswitchtogo
            SetTimer, switchmenu, %nextswitchtogo%, -1
        Else
            GoSub, switchmenu
    }
}
Else
    GoSub, settingsmenu
Menu, Tray, Tip, wfwp
Critical, Off
OnMessage(0x404, "hotkeys")
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
snapshot:
ip1 := formatdigits(ip1, 8)
ip2 := formatdigits(ip2, 8)
ip3 := formatdigits(ip3, 8)
ip4 := formatdigits(ip4, 8)
port := formatdigits(port, 16)
If proxy
    server := "http://" . ip1 . "." . ip2 . "." . ip3 . "." . ip4 . ":" . port
Else
    server := false
nminute := !minute
speriod := (60 * minute + 60 * 60 * nminute) * frequency
period := 1000 * speriod
binaryexclude := (arthropod << 0) + (bird << 1) + (ppeople << 2) + (amphibian << 3) + (fish << 4) + (reptile << 5) + (oanimals << 6) + (bone << 7) + (shell << 8) + (plant << 9) + (fungi << 10) + (olifeforms << 11)
binaryexclude := "0x" . Format("{:04x}", binaryexclude)
osettings := (proxy << 0) + (ip1 << 1) + (ip2 << 9) + (ip3 << 17) + (ip4 << 25) + (port << 33) + (frequency << 49) + (minute << 55)
settings := binaryexclude . Format("{:014x}", osettings)
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
whichonequestion:
indexjustclicked := 0
SysGet, primary, Monitor
primarywidth := primaryRight - primaryLeft
primaryheight := primaryBottom - primaryTop
maxlongside := Max(primarywidth, primaryheight) * 14 / 16
maxshortsdie := Min(primarywidth, primaryheight) / 3
If (primarywidth > primaryheight)
    xory := "x", worh := "w-1 h"
Else
    xory := "y", worh := "h-1 w"
resizewindow:
Gui, whichone:New, , wfwp: Which One? (Click It!)
totallengthalonglongside := 0
plusm := "m"
Loop, %monitorcount%
{
    wallpapername := trackwallpaper(monitors, A_Index, "cache")
    wallpaperratio := getratio(wallpapername, "resolved.dat")
    If (primarywidth > primaryheight)
        commonratio := 720 / 968
    Else
        commonratio := 968 / 720, wallpaperratio := 1 / wallpaperratio
    wallpaperpath := "cache\" . wallpapername
    If (wallpaperratio && FileExist(wallpaperpath))
    {
        Gui, Add, Picture, %xory%%plusm% %worh%%maxshortsdie% vpdot%A_Index% gtellwhichone, %wallpaperpath%
        totallengthalonglongside := totallengthalonglongside + wallpaperratio * maxshortsdie
    }
    Else
    {
        Gui, Add, Picture, %xory%%plusm% %worh%%maxshortsdie% vpdot%A_Index% gtellwhichone, commons.png
        totallengthalonglongside := totallengthalonglongside + commonratio * maxshortsdie
    }
    plusm := "+m"
}
If (totallengthalonglongside > maxlongside)
{
    maxshortsdie := maxlongside / totallengthalonglongside * maxshortsdie
    Gui, whichone:Default
    Gui, Destroy
    Goto, resizewindow
}
Gui, Show, Center
Thread, Priority, 0
WinWaitClose, wfwp: Which One? (Click It!)
Return
tellwhichone:
indexjustclicked := StrReplace(A_GuiControl, "pdot")
Gui, whichone:Default
Gui, Destroy
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
switchonemenu:
GoSub, whichonequestion
If !indexjustclicked
    Return
moveonlist := indexjustclicked
indexjustclicked := 0
GoSub, switchmenu
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
switchmenu:
If switching
{
    moveonlist := randomdisplayothers("cache", monitors, moveonlist, true)
    If moveonlist
    {
        If (moveonlistreal != -1)
        {
            If !moveonlistreal
                moveonlistreal := moveonlist
            Else
            {
                mergedlist := moveonlist . "," . moveonlistreal
                Sort, mergedlist, D, N U
                moveonlistreal := mergedlist
                moveonlist := 0
            }
        }
        Else
            TrayTip, , Monitor #%moveonlist% failed to switch., , 16
    }
    Return
}
Else
{
    switching := true
    Menu, Tray, Tip, switching...
}
If !moveonlist
{
    SetTimer, switchmenu, %period%, -1
    nextswitch := A_NowUTC
    EnvAdd, nextswitch, speriod, Seconds
    FileDelete, config
    FileAppend, %settings%@%nextswitch%, config
}
moveonlistreal := randomdisplayothers("cache", monitors, moveonlist, true), moveonlist := 0
FileCreateDir, cache
randomlistsagain:
refrencenewlists := false
FileRead, randomedlist, urls.sha1
Sort, randomedlist, Random
FileDelete, temp-random.sha1
FileAppend, %randomedlist%, temp-random.sha1
numberrestrictionscache := ""
numberrestrictionscache := []
sizerestrictionscache := ""
sizerestrictionscache := []
sparesapces := ""
sparesapces := []
arraypm(numberrestrictionscache, numberrestrictions)
arraypm(sizerestrictionscache, sizerestrictions)
arraypm(sparesapces, sizerestrictionscache)
linenumbers := ""
linenumbers := [0, 0, 0, 0, 0, 0]
Loop, %totalnumberrestriction%
{
    whichmonitor := Mod(A_Index, monitorcount)
    If !whichmonitor
        whichmonitor := monitorcount
    whichmonitortype := monitortypes[whichmonitor]
    whichmonitortypeindex := matches(whichmonitortype, match1, match2)
    If !Max(numberrestrictionscache*)
        Break
    If !numberrestrictionscache[whichmonitortypeindex]
        Continue
    If moveonlistreal
    {
        If whichmonitor Not In %moveonlistreal%
        {
            temptype := ""
            tempcountarry := ""
            tempnumberrestriction := ""
            tempsizerestriction := ""
            temptype := []
            temptype.Push(whichmonitortype)
            tempcountarry := types2countarray(temptype)
            tempnumberrestriction := types2numberrestrictions(tempcountarry)
            tempsizerestriction := types2sizerestrictions(tempcountarry)
            arraypm(numberrestrictionscache, tempnumberrestriction, -1)
            arraypm(sizerestrictionscache, tempsizerestriction, -1)
            Continue
        }
    }
    Else
    {
        Thread, Priority, -1
        Menu, Tray, Tip, caching...
    }
    sparesapces[whichmonitortypeindex] := sizerestrictionscache[whichmonitortypeindex] - folderpicturesize("cache", match1, match2)
    If (Max(sparesapces*) <= 0)
        Break
    If (sparesapces[whichmonitortypeindex] <= 0)
        Continue
    Loop, Read, temp-random.sha1
    {
        If (A_Index <= linenumbers[whichmonitortypeindex])
            Continue
        RegExMatch(A_LoopReadLine, "[^ ]+", filename)
        filepath := "cache\" . filename
        If (InStr(filename, match1) && InStr(filename, match2) && (!FileExist(filepath)))
            oneline := A_LoopReadLine, linenumbers[whichmonitortypeindex] := A_Index
        Else
            Continue
        If FileExist("blacklist")
        {
            bingo := false
            Loop, Read, blacklist
            {
                RegExMatch(A_LoopReadLine, "[^.]+", baldsha1)
                If InStr(oneline, baldsha1)
                {
                    bingo := true
                    Break
                }
            }
            If bingo
                Continue
        }
        Break
    }
    numberrestrictionscache[whichmonitortypeindex] := numberrestrictionscache[whichmonitortypeindex] - 1
    If refrencenewlists
        Goto, randomlistsagain
    simplefile := simpledownload(oneline, "cache", server, timerestrictions[whichmonitortypeindex])
    If (moveonlistreal && simplefile)
        moveonlistreal := randomdisplayothers("cache", monitors, moveonlistreal, true)
}
FileDelete, temp-random.sha1
If moveonlistreal
    TrayTip, , Monitor #%moveonlistreal% failed to switch., , 16
moveonlistreal := -1
switching := false
Menu, Tray, Tip, wfwp
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
detailsmenu:
fromdetails := true
If (monitorcount > 1)
{
    GoSub, whichonequestion
    If !indexjustclicked
        Return
}
GoSub, originalmenu
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
originalmenu:
If downloading
{
    TrayTip, , Please wait until the last download process completes., , 16
    Return
}
If (monitorcount > 1)
{
    If !indexjustclicked
    {
        GoSub, whichonequestion
        If !indexjustclicked
            Return
    }
    originalsha1 := trackwallpaper(monitors, indexjustclicked, "cache")
    indexjustclicked := 0
}
Else
    originalsha1 := trackwallpaper(monitors, 1, "cache")
If ((!originalsha1) || (RegExMatch(originalsha1, "tmp-[0-9]+\.jpg") = 1))
    Return
RegExMatch(originalsha1, "[0-9a-f]+", originalsha1)
originalline := 0
Loop, Read, resolved.dat
{
    If InStr(A_LoopReadLine, originalsha1)
        originalline := A_LoopReadLine
}
If !originalline
    Return
RegExMatch(originalline, "https://[^""]+", originalurl)
If fromdetails
{
    fromdetails := false
    originalurl := RegExReplace(originalurl, "https://upload.wikimedia.org/wikipedia/commons/[0-9a-f]+/[0-9a-f]+/", "https://commons.wikimedia.org/wiki/File:")
    Run, %originalurl%
    Return
}
originalname := originalsha1 . "." . RegExReplace(originalurl, ".*\.")
RegExMatch(originalline, "size = +[0-9]+", originalsize)
originalsize := RegExReplace(originalsize, "size = +")
originalsizeinmb := originalsize / 1024 / 1024
If (originalsizeinmb > 64)
{
    MsgBox, 1, This original file sizes %originalsizeinmb% MB. Are you sure you want to download it?
    IfMsgBox, Ok
        Goto, confirmed
    Return
}
confirmed:
If downloadfolder
    targetfolder := downloadfolder
Else
{
    downloadfoldercache := 0
    fromoriginal := true
    GoSub, specifypbutton
    fromoriginal := false
    If downloadfoldercache
    {
        downloadfolder := downloadfoldercache
        targetfolder := downloadfolder
        FileDelete, download\redirect
        FileCreateDir, download
        FileAppend, %downloadfolder%, download\redirect
    }
    Else
        targetfolder := A_ScriptDir . "\download"
}
FileCreateDir, %targetfolder%
targetfile := targetfolder . "\" . originalname
downloading := true
Menu, Tray, Tip, downloading...
Thread, Priority, -2
udtlp(originalurl, targetfile, server, true)
Menu, Tray, Tip, wfwp
downloading := false
If ErrorLevel
    TrayTip, , Failed., , 16
Else If (sha(targetfile, true) != originalsha1)
{
    FileDelete, %targetfile%
    TrayTip, , Failed., , 16
}
Else
    TrayTip, , Succeed., , 16
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
blacklistmenu:
If (monitorcount > 1)
{
    GoSub, whichonequestion
    If !indexjustclicked
        Return
    banfilename := trackwallpaper(monitors, indexjustclicked, "cache")
    resolutiontag := monitortypes[indexjustclicked]
    moveonlist := indexjustclicked
    indexjustclicked := 0
}
Else
    banfilename := trackwallpaper(monitors, 1, "cache"), resolutiontag := monitortypes[1], moveonlist := 1
If ((!banfilename) || RegExMatch(banfilename, "tmp-[0-9]+\.jpg", , 1))
{
    moveonlist := 0
    Return
}
RegExMatch(banfilename, "[0-9a-f]+", bannedsha1)
resolutiontag := Ceil(matches(resolutiontag) / 2)
FileAppend, %bannedsha1%.%resolutiontag%`r`n, blacklist
blacklistlength := countandsortblacklist("blacklist")
Menu, blacklistdotmenu, Rename, 1&, Blacklist This Picture and Switch to the Next (%blacklistlength%)
refrencenewlists := true
GoSub, switchmenu
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unblacklistmenu:
If !FileExist("blacklist")
    Return
lastline := false
blacklistlength := 0
Loop, Read, blacklist, blacklistcopy
{
    If !A_LoopReadLine
        Continue
    RegExMatch(A_LoopReadLine, "[^.]+\.[1-3]", thisline)
    If (thisline != A_LoopReadLine)
        Continue
    RegExMatch(thisline, "[^.]+", thisline)
    If thisline Is Not xdigit
        Continue
    If lastline
    {
        FileAppend, %lastline%`r`n
        blacklistlength := blacklistlength + 1
    }
    lastline := A_LoopReadLine
}
If FileExist("blacklistcopy")
    FileMove, blacklistcopy, blacklist, 1
Else
    FileDelete, blacklist
If !lastline
{
    Menu, blacklistdotmenu, Rename, 1&, Blacklist This Picture and Switch to the Next (0)
    Return
}
RegExMatch(lastline, "[^.]+", extractedsha1)
extractresolution := SubStr(lastline, 0)
If (extractresolution = 1)
    resolutionmatch := ".fhd."
Else If (extractresolution = 2)
    resolutionmatch := ".qhd."
Else If (extractresolution = 3)
    resolutionmatch := ".uhd."
Else
    Return
switchbackto := false
Loop, Read, urls.sha1
{
    RegExMatch(A_LoopReadLine, "[^ ]+", fileformatch)
    If (InStr(fileformatch, extractedsha1) && InStr(fileformatch, resolutionmatch))
    {
        switchbackto := A_LoopReadLine
        Break
    }
}
If !switchbackto
{
    Loop, Read, urls.sha1
    {
        RegExMatch(A_LoopReadLine, "[^ ]+", fileformatch)
        If InStr(fileformatch, extractedsha1)
        {
            switchbackto := A_LoopReadLine
            Break
        }
    }
}
If !switchbackto
{
    MsgBox, 3, Un-Blacklist or Move to the Top, This balcklisted picture can not be be switched back to because it is not in the playlist, which is mostly caused by none of its suitable monitors being attached, or one of its categories having been excluded, so it shoud not be displayed anyway.`n`nThe question is:`n`nDo you still want to un-blacklist it (Click Yes), or move it to the top of the blacklist (Click No) to avoid this window popping up all the time?
    IfMsgBox Yes
    {}
    Else IfMsgBox No
    {
        FileAppend, %lastline%`r`n, blacklistcopy
        Loop, Read, blacklist, blacklistcopy
            FileAppend, %A_LoopReadLine%`r`n
        blacklistlength := blacklistlength + 1
        FileMove, blacklistcopy, blacklist, 1
    }
    Else
    {
        FileAppend, %lastline%`r`n, blacklist
        blacklistlength := blacklistlength + 1
    }
    Menu, blacklistdotmenu, Rename, 1&, Blacklist This Picture and Switch to the Next (%blacklistlength%)
    Return
}
Menu, Tray, Tip, reloading...
switchbackto := simpledownload(switchbackto, "cache", server, timerestrictions[2 * extractresolution])
Menu, Tray, Tip, wfwp
If !switchbackto
{
    FileAppend, %lastline%`r`n, blacklist
    blacklistlength := blacklistlength + 1
    Menu, blacklistdotmenu, Rename, 1&, Blacklist This Picture and Switch to the Next (%blacklistlength%)
    TrayTip, , Failed to download. The blacklist remains untouched., , 16
    Return
}
readyformatch := 0
Loop, %monitorcount%
{
    typeformatch := monitortypes[A_Index]
    matches(typeformatch, match1formatch, match2formatch)
    If (InStr(switchbackto, match1formatch) && InStr(switchbackto, match2formatch))
    {
        readyformatch := A_Index
        Break
    }
}
switchbackto := A_ScriptDir . "\" . switchbackto
If (!readyformatch || switchwallpaper(switchbackto, monitors, readyformatch))
{
    FileAppend, %lastline%`r`n, blacklist
    blacklistlength := blacklistlength + 1
    TrayTip, , Failed to display. The blacklist remains untouched., , 16
}
Menu, blacklistdotmenu, Rename, 1&, Blacklist This Picture and Switch to the Next (%blacklistlength%)
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clearblacklistmenu:
FileDelete, blacklist
Menu, blacklistdotmenu, Rename, 1&, Blacklist This Picture and Switch to the Next (0)
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updatedatamenu:
reupdatedat:
FileCreateDir, update
Menu, Tray, Tip, updating...
udtlp("https://raw.githubusercontent.com/fjn308/wfwp/main/upload/sha256andtimestamp.log", "update\sha256andtimestamp.log", server, true, 16)
If ErrorLevel
{
    Menu, Tray, Tip, wfwp
    FileRemoveDir, update, 1
    TrayTip, , Failed to check., , 16
    Return
}
FileRead, sha256andtimestamp, update\sha256andtimestamp.log
sha256andtimestamp:= StrSplit(sha256andtimestamp, "@")
sha256 := sha256andtimestamp[1]
timestampremote := sha256andtimestamp[2]
If !fromdatabasecheck
{
    Loop, Read, resolved.dat
        tagandtimestamp := A_LoopReadLine
    tagandtimestamp := StrSplit(tagandtimestamp, "@")
    timestamplocal := tagandtimestamp[2]
    If (timestamplocal >= timestampremote)
    {
        Menu, Tray, Tip, wfwp
        FileRemoveDir, update, 1
        TrayTip, , No need to update., , 16
        Return
    }
}
udtlp("https://raw.githubusercontent.com/fjn308/wfwp/main/upload/resolved.dat", "update\reference.dat", server, true, 64)
Menu, Tray, Tip, wfwp
If ErrorLevel
{
    FileRemoveDir, update, 1
    TrayTip, , Failed to download., , 16
    Return
}
If (sha("update\reference.dat") != sha256)
{
    FileRemoveDir, update, 1
    MsgBox, 5, Update Error, SHA-256 does not match. Retry or Cancel?
    IfMsgBox, Retry
        Goto, reupdatedat
    Return
}
FileMove, update\reference.dat, resolved.dat, 1
FileRemoveDir, update, 1
datfilelength := countdata("resolved.dat")
qualifieddatanumber := superdat2sha1("resolved.dat", "urls.sha1", monitortypes, binaryexclude)
Menu, updatedotmenu, Rename, 1&, Update the Database (%qualifieddatanumber%/%datfilelength%)
TrayTip, , Succeed., , 16
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updatewfwpmenu:
reupdatewfwp:
FileCreateDir, update
Menu, Tray, Tip, updating...
udtlp("https://api.github.com/repos/fjn308/wfwp/releases/latest", "update\github.json", server, true, 16)
If ErrorLevel
{
    TrayTip, , Failed to check., , 16
    Goto, quit
}
FileRead, github, update\github.json
github := jsonmatch(github, "tag_name", ".*?[0-9v.]+")
If (version = github)
{
    TrayTip, , No need to update., , 16
    Goto, quit
}
udtlp("https://github.com/fjn308/wfwp/releases/latest/download/wfwp.exe", "update\wfwp.exe", server, true, 32)
If ErrorLevel
{
    TrayTip, , Failed to download., , 16
    Goto, quit
}
FileGetSize, binsize, update\wfwp.exe
If (binsize < 4096)
{
    TrayTip, , wfwp is missing. Update is aborted., , 16
    Goto, quit
}
udtlp("https://github.com/fjn308/wfwp/releases/latest/download/sha256", "update\sha256", server, true, 16)
If ErrorLevel
{
    TrayTip, , Failed to fetch checksum., , 16
    Goto, quit
}
FileRead, sha256, update\sha256
If (sha("update\wfwp.exe") != sha256)
{
    MsgBox, 5, Update Error, SHA-256 does not match. Retry or Cancel?
    IfMsgBox, Retry
    {
        FileRemoveDir, update, 1
        Goto, reupdatewfwp
    }
    Goto, quit
}
FileMove, update\wfwp.exe, wfwpnew.exe, 1
FileRemoveDir, update, 1
Run, wfwpnew.exe
ExitApp
quit:
Menu, Tray, Tip, wfwp
FileRemoveDir, update, 1
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
settingsmenu:
If !fromselectfolder
    downloadfoldercache := downloadfolder
If downloadfoldercache
{
    downloadfolderforshow := downloadfoldercache
    pathlength := StrLen(downloadfolderforshow)
    If (pathlength > 32)
    {
        downloadfolderforshow := SubStr(downloadfolderforshow, -28)
        firstslash := InStr(downloadfolderforshow, "\")
        If firstslash
            downloadfolderforshow := SubStr(downloadfolderforshow, firstslash)
        downloadfolderforshow := "..." . downloadfolderforshow
    }
}
Else
    downloadfolderforshow := "Not Specified"
blanklength := 32 - StrLen(downloadfolderforshow)
Loop, %blanklength%
    downloadfolderforshow := downloadfolderforshow . " "
proxychecked :=checked(proxy)
minutechecked := checked(minute)
nminutechecked := checked(nminute)
arthropod := extractbit(binaryexclude, 0)
bird := extractbit(binaryexclude, 1)
ppeople := extractbit(binaryexclude, 2)
amphibian := extractbit(binaryexclude, 3)
fish := extractbit(binaryexclude, 4)
reptile := extractbit(binaryexclude, 5)
oanimals := extractbit(binaryexclude, 6)
bone := extractbit(binaryexclude, 7)
shell := extractbit(binaryexclude, 8)
plant := extractbit(binaryexclude, 9)
fungi := extractbit(binaryexclude, 10)
olifeforms := extractbit(binaryexclude, 11)
arthropodchecked := checked(arthropod)
birdchecked := checked(bird)
ppeoplechecked := checked(ppeople)
amphibianchecked := checked(amphibian)
fishchecked := checked(fish)
reptilechecked := checked(reptile)
oanimalschecked := checked(oanimals)
bonechecked := checked(bone)
shellchecked := checked(shell)
plantchecked := checked(plant)
fungichecked := checked(fungi)
olifeformschecked := checked(olifeforms)
Gui, settings:New, , wfwp: Settings
Gui, Add, Tab3, , General|Exclude
Gui, Tab, 1
Gui, Add, Text, xm ym
Gui, Add, Text, xm y+m
Gui, Add, Text, x+m y+m, Connect via a Proxy:
Gui, Add, CheckBox, x+m %proxychecked% vproxy, http://
Gui, Add, Edit, x+0 Limit3 Number vip1, %ip1%
Gui, Add, Text, x+0, .
Gui, Add, Edit, x+0 Limit3 Number vip2, %ip2%
Gui, Add, Text, x+0, .
Gui, Add, Edit, x+0 Limit3 Number vip3, %ip3%
Gui, Add, Text, x+0, .
Gui, Add, Edit, x+0 Limit3 Number vip4, %ip4%
Gui, Add, Text, x+0, :
Gui, Add, Edit, x+0 Limit5 Number vport, %port%
Gui, Add, Text, xm y+m
Gui, Add, Text, x+m y+m, Switching Frequency:
Gui, Add, Text, x+m, Every ` `
Gui, Add, Edit, x+m wp vfrequency
Gui, Add, UpDown, Range1-60, %frequency%
Gui, Add, Text, x+m, ` `
Gui, Add, Radio, x+m %minutechecked% vminute, Minuetes
Gui, Add, Radio, x+m %nminutechecked% vnminute, Hours ` ` `
Gui, Add, Text, xm y+m
Gui, Add, Text, x+m y+m, Save Originals into:
Gui, Add, Text, x+m cblue gspecifypbutton, %downloadfolderforshow%
Gui, Add, Text, xm y+m
Gui, Add, Text, x+m y+m Section, If you want to add wfwp to run automatically at startup, you may follow
Gui, Add, Text, x+0 cblue gmsbutton, ` this
Gui, Add, Text, xs y+m cblue gmsbutton, guidance `
Gui, Add, Text, x+0, provided by Microsoft.
Gui, Tab, 2
Gui, Add, Text, xm ym
Gui, Add, Text, xm y+m
Gui, Add, Text, x+m y+m Section, Some specific categories of pictures may not be proper as wallpapers, which can be
Gui, Add, Text, xs y+m, excluded here (check the list at the bottom of
Gui, Add, Text, x+0 cblue gwikibutton, ` this page
Gui, Add, Text, x+0, ` for more infomation):`n
Gui, Add, CheckBox, xs y+m %arthropodchecked% varthropod, Arthropods ` ` ` ` ` ` `
Gui, Add, CheckBox, x+m %birdchecked% vbird, Birds ` ` ` ` ` ` ` ` ` ` ` `
Gui, Add, CheckBox, x+m Disabled, Mammals
Gui, Add, CheckBox, xs y+m %amphibianchecked% vamphibian, Amphibians ` ` ` ` ` ` `
Gui, Add, CheckBox, x+m %fishchecked% vfish, Fish ` ` ` ` ` ` ` ` ` ` ` ` `
Gui, Add, CheckBox, x+m %reptilechecked% vreptile, Reptiles
Gui, Add, CheckBox, xs y+m %oanimalschecked% voanimals, Other Animals ` ` ` `
Gui, Add, CheckBox, x+m %bonechecked% vbone, Bones and Fossils
Gui, Add, CheckBox, x+m %shellchecked% vshell, Shells
Gui, Add, CheckBox, xs y+m %plantchecked% vplant, Plants ` ` ` ` ` ` ` ` ` ` `
Gui, Add, CheckBox, x+m %fungichecked% vfungi, Fungi ` ` ` ` ` ` ` ` ` ` ` `
Gui, Add, CheckBox, x+m %olifeformschecked% volifeforms, Other Lifeforms
Gui, Add, Text, xm y+m
Gui, Add, CheckBox, x+m y+m %ppeoplechecked% vppeople, Reduce Portraits of People on Portrait (Non-Landscape) Monitors
Gui, Tab
Gui, Add, Button, xm y+m ghelpbutton, ` ` ` ` ` Help / About ` ` ` `
Gui, Add, Button, x+m grestorebutton, ` ` Restore to Default `
Gui, Add, Text, x+0, ` ` ` ` ` ` ` ` ` ` ` ` ` ` ` ` ` `
Gui, Add, Button, x+0 gsubmitbutton, ` ` ` Save and Exit ` ` ` `
Gui, Show, Center
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
submitbutton:
binaryexcludecache := binaryexclude
speriodcache := speriod
Gui, Submit
Gui, settings:Default
Gui, Destroy
GoSub, snapshot
FileDelete, config
If nextswitch
    FileAppend, %settings%@%nextswitch%, config
Else
    FileAppend, %settings%, config
downloadfolder := downloadfoldercache
FileDelete, download\redirect
If downloadfoldercache
{
    FileCreateDir, download
    If (downloadfoldercache != A_ScriptDir . "\download")
        FileAppend, %downloadfolder%, download\redirect
}
databasecheck:
If !datfilelength
{
    fromdatabasecheck := true
    If !firstrun
    {
        MsgBox, 3, Download or Not, The database is missing. May wfwp download it?
        IfMsgBox Yes
        {}
        Else
        {
            MsgBox, , wfwp, wfwp will exit.
            ExitApp
        }
    }
    Else
        TrayTip, , It is the first run. wfwp is downloading the database., , 16
    GoSub, updatedatamenu
    fromdatabasecheck := false
    Goto, databasecheck
}
firstrun := false
If ((!qualifieddatanumber) || (binaryexclude != binaryexcludecache))
{
    qualifieddatanumber := superdat2sha1("resolved.dat", "urls.sha1", monitortypes, binaryexclude)
    If !qualifieddatanumber
    {
        FileDelete, urls.sha1
        FileDelete, resolved.dat
        datfilelength := 0
        Goto, databasecheck
    }
    Menu, updatedotmenu, Rename, 1&, Update the Database (%qualifieddatanumber%/%datfilelength%)
    refrencenewlists := true
    moveonlist := premoveon("urls.sha1", "cache", monitors)
    superremove("urls.sha1", "cache")
}
If !nextswitch
    moveonlist := 0
If ((!nextswitch) || moveonlist)
    GoSub, switchmenu
Else
{
    sperioddelta := speriod - speriodcache
    EnvAdd, nextswitch, sperioddelta, Seconds
    nextswitchtogo := preparetimer(nextswitch)
    If nextswitchtogo
        SetTimer, switchmenu, %nextswitchtogo%, -1
    Else
        GoSub, switchmenu
}
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
specifypbutton:
downloadfoldercachecache := downloadfoldercache
specifyagain:
If downloadfoldercachecache
    FileSelectFolder, downloadfoldercache, *%downloadfoldercachecache%, , wfwp: Select Folder
Else
    FileSelectFolder, downloadfoldercache, *%A_ScriptDir%, , wfwp: Select Folder
If ErrorLevel
{
    downloadfoldercache := downloadfoldercachecache
    Return
}
If (downloadfoldercache = A_ScriptDir . "\cache")
{
    MsgBox, , wfwp, Not this one, please.
    downloadfoldercache := downloadfoldercachecache
    Goto, specifyagain
}
If fromoriginal
    Return
GoSub, snapshot
settingscache := StrReplace(settings, "0x")
Gui, Submit
GoSub, snapshot
Gui, settings:Default
Gui, Destroy
fromselectfolder := true
GoSub, settingsmenu
fromselectfolder := false
loadconfiguration(settingscache, proxy, ip1, ip2, ip3, ip4, port, frequency, minute, nminute, binaryexclude)
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
restorebutton:
GoSub, snapshot
settingscache := StrReplace(settings, "0x")
Gui, settings:Default
Gui, Destroy
loaddefault(proxy, ip1, ip2, ip3, ip4, port, frequency, minute, nminute, binaryexclude)
downloadfoldercache := 0
fromselectfolder := true
GoSub, settingsmenu
fromselectfolder := false
loadconfiguration(settingscache, proxy, ip1, ip2, ip3, ip4, port, frequency, minute, nminute, binaryexclude)
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
helpbutton:
Run, https://github.com/fjn308/wfwp
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msbutton:
Run, https://support.microsoft.com/en-us/windows/add-an-app-to-run-automatically-at-startup-in-windows-10-150da165-dcd9-7230-517b-cf3c295d89dd
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wikibutton:
Run, https://commons.wikimedia.org/wiki/Commons:Featured_pictures
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
detectmenu:
Reload
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exitmenu:
ExitApp
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
refreshtip:
lifetimecache := lifetimecache - 1
If !lifetimecache
{
    lifetimecache := lifetime
    oddclick := !oddclick
    ToolTip
    SetTimer, refreshtip, Delete
    Return
}
Else
    SetTimer, refreshtip, -1000, 14
If !downloading
{
    ToolTip, Short Cuts:`nShift + Click: Switch to the Next`nCtrl  + Click: Download the Original`nAlt   + Click: Blacklist and Switch`nClick Again to Hide This Tip: %lifetimecache%s, %xcoordinate%, %ycoordinate%
    Return
}
If FileExist(targetfile)
    FileGetSize, downloadedsize, %targetfile%
Else
    downloadedsize := 0
progress := Floor(downloadedsize / originalsize * 100)
ToolTip, Downloading: %progress%`%`nClick Again to Hide This Tip: %lifetimecache%s, %xcoordinate%, %ycoordinate% ;`nCtrl + Click: Abort the Download
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hotkeys(wparam, lparam)
{
    If (lparam != 0x202)
        Return
    If (GetKeyState("Ctrl") && (!GetKeyState("Alt")) && (!GetKeyState("Shift")))
        GoSub, originalmenu
    Else If ((!GetKeyState("Ctrl")) && GetKeyState("Alt") && (!GetKeyState("Shift")))
        GoSub, blacklistmenu
    Else If ((!GetKeyState("Ctrl")) && (!GetKeyState("Alt")) && GetKeyState("Shift"))
    {
        If (monitorcount > 1)
            GoSub, switchonemenu
        Else
            GoSub, switchmenu
    }
    Else
    {
        Global lifetime
        Global lifetimecache := lifetime
        Global oddclick
        oddclick := !oddclick
        If oddclick
        {
            Global xcoordinate
            Global ycoordinate
            MouseGetPos, xcoordinate, ycoordinate
            SetTimer, refreshtip, -1, 14
        }
        Else
        {
            ToolTip
            SetTimer, refreshtip, Delete
        }
    }
    Return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include, scripts\functions.ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
