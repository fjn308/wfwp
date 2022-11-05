;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
countmonitor()
{
    idesktopwallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")
    offset := 6 * A_PtrSize
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "UInt*", count)
    ObjRelease(idesktopwallpaper)
    Return, count
}
detectmonitor(indexfromzero)
{
    path := detectmonitorpath(indexfromzero)
    idesktopwallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")
    offset := 7 * A_PtrSize
    VarSetCapacity(rect, 32)
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "WStr", path, "Ptr", &rect)
    width := NumGet(&rect, 8, "Int") - NumGet(&rect, 0, "Int")
    height := NumGet(&rect, 12, "Int") - NumGet(&rect, 4, "Int")
    ObjRelease(idesktopwallpaper)
    If width Is Not integer
        Return, 0
    If height Is Not integer
        Return, 0
    If ((width <= 0) || (height <= 0))
        Return, 0
    If (width > height)
        landscape := "+"
    Else
        landscape := "-"
    longside := Max(width, height)
    shortside := Min(width, height)
    If (longside > 3840 && shortside > 2160)
        resolution := 4
    Else If (longside > 2560 && shortside > 1440)
        resolution := 3
    Else If (longside > 1920 && shortside > 1080)
        resolution := 2
    Else
        resolution := 1
    Return, landscape . resolution . path
}
detectmonitorpath(indexfromzero)
{
    idesktopwallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")
    offset := 5 * A_PtrSize
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "UInt", indexfromzero, "Ptr*", pointer)
    path := StrGet(pointer, , "UTF-16")
    DllCall("Ole32\CoTaskMemFree", "Ptr", pointer)
    ObjRelease(idesktopwallpaper)
    Return, path
}
setposition()
{
    idesktopwallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")
    offset := 10 * A_PtrSize
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "UInt", 4)
    offset := 11 * A_PtrSize
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "UInt*", position)
    ObjRelease(idesktopwallpaper)
    If (position = 4)
        Return, 0
    Return, 1
}
switchwallpaper(filepathfull, monitors, monitorindex)
{
    monitorpath := SubStr(monitors[monitorindex], 3)
    idesktopwallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")
    offset := 3 * A_PtrSize
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "Ptr", &monitorpath, "WStr", filepathfull)
    ObjRelease(idesktopwallpaper)
    If (trackwallpaper(monitors, monitorindex) = filepathfull)
        Return, 0
    Return, 1
}
trackwallpaper(monitors, monitorindex, filter := false)
{
    monitorpath := SubStr(monitors[monitorindex], 3)
    idesktopwallpaper := ComObjCreate("{C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD}", "{B92B56A9-8B55-4E14-9A89-0199BBB6F93B}")
    offset := 4 * A_PtrSize
    DllCall(NumGet(NumGet(idesktopwallpaper+0), offset), "Ptr", idesktopwallpaper, "Ptr", &monitorpath, "Ptr*", pointer)
    filepathfull := StrGet(pointer, , "UTF-16")
    DllCall("Ole32\CoTaskMemFree", "Ptr", pointer)
    ObjRelease(idesktopwallpaper)
    If filter
    {
        filter := A_ScriptDir . "\" . filter . "\"
        If InStr(filepathfull, filter)
        {
            filename := StrReplace(filepathfull, filter)
            If ((RegExMatch(filename, "tmp-[0-9]+\.jpg") != 1) && (RegExMatch(filename, "[0-9a-f]+\.[+-]\..*\.jpg") != 1))
                Return, 0
            Return, filename
        }
        Return, 0
    }
    Return, filepathfull
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
premoveon(sha1file, folder, monitors)
{
    moveonlist := ""
    monitorcount := monitors.Length()
    Loop, %monitorcount%
    {
        moveon := false
        current := trackwallpaper(monitors, A_Index, folder)
        If current
        {
            moveon := true
            Loop, Read, %sha1file%
            {
                RegExMatch(A_LoopReadLine, "[^ ]+", filename)
                If (filename = current)
                {
                    moveon := false
                    Break
                }
            }
        }
        If moveon
        {
            moveonlist := moveonlist . "," . A_Index
            FileCopy, %folder%\%current%, %folder%\tmp-%A_Index%.jpg, 1
            fullpathtotmp := A_ScriptDir . "\" . folder . "\tmp-" . A_Index . ".jpg"
            switchwallpaper(fullpathtotmp, monitors, A_Index)
        }
    }
    If (moveonlist = "")
        Return, 0
    Return, SubStr(moveonlist, 2)
}
randomdisplayothers(folder, monitors, moveonlist, deletecurrent := false)
{
    moveonlistcopy := ""
    monitorcount := monitors.Length()
    Loop, %monitorcount%
    {
        If moveonlist
        {
            If A_Index Not In %moveonlist%
                Continue
        }
        current := trackwallpaper(monitors, A_Index, folder)
        monitor := monitors[A_Index]
        matches(monitor, match1, match2)
        randomlist := ""
        Loop, Files, %folder%\*.*
        {
            If (A_LoopFileExt != "jpg")
                Continue
            If (RegExMatch(A_LoopFileName, "[0-9a-f]+\.[+-]\.") != 1)
                Continue
            If !InStr(A_LoopFileName, match1)
                Continue
            If !InStr(A_LoopFileName, match2)
                Continue
            If (A_LoopFileName != current)
                randomlist := randomlist . "," . A_LoopFileName
        }
        If (randomlist = "")
        {
            moveonlistcopy := moveonlistcopy . "," . A_Index
            Continue
        }
        Else
            randomlist := SubStr(randomlist, 2)
        Sort, randomlist, D, Random
        RegExMatch(randomlist, "[^,]+", firstfile)
        firstfilefullpath := A_ScriptDir . "\" . folder . "\" . firstfile
        If switchwallpaper(firstfilefullpath, monitors, A_Index)
            moveonlistcopy := moveonlistcopy . "," . A_Index
        Else If (deletecurrent && current)
            FileDelete, %folder%\%current%
    }
    If (moveonlistcopy = "")
        Return, 0
    Return, SubStr(moveonlistcopy, 2)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
arraypm(array1, array2, pm := 0)
{
    If !pm
    {
        length := array2.Length()
        Loop, %length%
            array1.Push(array2[A_Index])
    }
    Else If (array1.Length() = array2.Length())
    {
        length := array1.Length()
        If (pm = 1)
        {
            Loop, %length%
                array1[A_Index] := array1[A_Index] + array2[A_Index]
        }
        Else If (pm = -1)
        {
            Loop, %length%
                array1[A_Index] := array1[A_Index] - array2[A_Index]
        }
    }
}
byte2hex(byte)
{
    If (byte = "0000")
        Return, "0"
    If (byte = "0001")
        Return, "1"
    If (byte = "0010")
        Return, "2"
    If (byte = "0011")
        Return, "3"
    If (byte = "0100")
        Return, "4"
    If (byte = "0101")
        Return, "5"
    If (byte = "0110")
        Return, "6"
    If (byte = "0111")
        Return, "7"
    If (byte = "1000")
        Return, "8"
    If (byte = "1001")
        Return, "9"
    If (byte = "1010")
        Return, "a"
    If (byte = "1011")
        Return, "b"
    If (byte = "1100")
        Return, "c"
    If (byte = "1101")
        Return, "d"
    If (byte = "1110")
        Return, "e"
    If (byte = "1111")
        Return, "f"
    Return, "h"
}
category(list)
{
    arthropod := 0, bird := 0, people := 0, amphibian := 0, fish := 0, reptile := 0, oanimals := 0, bone := 0, shell := 0, plant := 0, fungi := 0, olifeforms := 0
    If InStr(list, "/arthropod")
        arthropod := 1
    If InStr(list, "/bird")
        bird := 1
    If InStr(list, "/people")
        people := 1
    If InStr(list, "/amphibian")
        amphibian := 1
    If InStr(list, "/fish")
        fish := 1
    If InStr(list, "/reptile")
        reptile := 1
    If RegExMatch(list, "/[Aa]nimals[^/]")
        oanimals := 1
    If InStr(list, "/bone")
        bone := 1
    If InStr(list, "/shell")
        shell := 1
    If InStr(list, "/plant")
        plant := 1
    If InStr(list, "/fungi")
        fungi := 1
    If InStr(list, "lifeforms")
        olifeforms := 1
    category := (arthropod << 0) + (bird << 1) + (people << 2) + (amphibian << 3) + (fish << 4) + (reptile << 5) + (oanimals << 6) + (bone << 7) + (shell << 8) + (plant << 9) + (fungi << 10) + (olifeforms << 11)
    Return, Format("{:04x}", category)
}
checked(key)
{
    If key
        Return, "Checked"
    Return, ""
}
countandsortblacklist(blacklist)
{
    If !FileExist(blacklist)
        Return, 0
    blacklistcopy := blacklist . "copy", length := 0
    Loop, Read, %blacklist%, %blacklistcopy%
    {
        If !A_LoopReadLine
            Continue
        RegExMatch(A_LoopReadLine, "[^.]+\.[1-3]", sha1dotresolution)
        If (sha1dotresolution != A_LoopReadLine)
            Continue
        RegExMatch(sha1, "[^.]+", sha1dotresolution)
        If sha1 Is Not xdigit
            Continue
        FileAppend, %A_LoopReadLine%`r`n
        length := length + 1
    }
    If FileExist(blacklistcopy)
        FileMove, %blacklistcopy%, %blacklist%, 1
    Else
        FileDelete, %blacklist%
    Return, length
}
countdata(datfile)
{
    If !FileExist(datfile)
        Return, 0
    count := 0
    Loop, Read, %datfile%
    {
        If InStr(A_LoopReadLine, "sha1 =")
            count := count + 1
    }
    Return, count
}
countdown(seconds)
{
    seconds := Round(seconds)
    minutes := Floor(seconds / 60)
    seconds := seconds - minutes * 60
    hours := Floor(minutes / 60)
    minutes := minutes - hours * 60
    If (seconds < 10)
        seconds := "0" . seconds
    If (minutes < 10)
        minutes := "0" . minutes
    If (hours < 10)
        hours := "0" . hours
    Return, hours . ":" . minutes . ":" . seconds
}
dat2sha1(datfile, sha1file, append := false, orientation := "+", minimalresolution := 2, binaryexclude := "0x0000", removeduplicate := true, ByRef qualifiednumberdelta := 0, ByRef qualifiedsizedelta := 0, resize := true, safetylock := true)
{
    If (orientation = "-")
        orientationmatch := "orientation = -"
    Else
        orientationmatch := "orientation = +"
    If (minimalresolution = 3)
        resolutionmatch := "resolution = 3", targetwidth := 3840, targetheight := 2160, resizedto := "uhd"
    Else If (minimalresolution = 1)
        resolutionmatch := "resolution = 1,resolution = 2,resolution = 3", targetwidth := 1920, targetheight := 1080, resizedto := "fhd"
    Else
        resolutionmatch := "resolution = 2,resolution = 3", targetwidth := 2560, targetheight := 1440, resizedto := "qhd"
    If safetylock
        resize := true
    Else
    {
        If !orientation
            orientationmatch := "orientation ="
        If !minimalresolution
            resolutionmatch := "resolution =", resize := false
    }
    If !append
        FileDelete, %sha1file%
    Loop, Read, %datfile%, %sha1file%
    {
        If !InStr(A_LoopReadLine, "sha1 =")
            Continue
        If A_LoopReadLine Not Contains %orientationmatch%
            Continue
        If A_LoopReadLine Not Contains %resolutionmatch%
            Continue
        RegExMatch(A_LoopReadLine, "category = 0x[0-9a-f]+", category)
        category := StrReplace(category, "category = ")
        probe := category & binaryexclude
        If (probe != 0)
        {
            If ((!InStr(A_LoopReadLine, "orientation = -")) || (probe != 1 << 2))
                Continue
        }
        qualifiednumberdelta := qualifiednumberdelta + 1
        RegExMatch(A_LoopReadLine, "url = "".*?""", url)
        url := Trim(StrReplace(url, "url = "), """")
        RegExMatch(A_LoopReadLine, "sha1 = 0x[0-9a-f]+", sha1)
        sha1 := StrReplace(sha1, "sha1 = 0x")
        RegExMatch(A_LoopReadLine, "size = +[0-9]+", size)
        size := RegExReplace(size, "size = +")
        qualifiedsizedelta := qualifiedsizedelta + size
        RegExMatch(url, "https.*\.", urlbody)
        urlhead := StrReplace(url, urlbody)
        headfororiginal := orientation . "." . urlhead
        headforresized := headfororiginal . "." . resizedto . ".jpg"
        If (StrLen(urlhead) = 3)
            headfororiginal := headfororiginal . " ", headforresized := headforresized . " "
        If resize
        {
            outputsha1 := sha1 . "." . headforresized
            RegExMatch(A_LoopReadLine, "width = +[0-9]+", width)
            RegExMatch(A_LoopReadLine, "height = +[0-9]+", height)
            width := RegExReplace(width, "width = +")
            height := RegExReplace(height, "height = +")
            ratio := width / height
            If (ratio > 1)
                reference := ratio - 16 / 9, realtargetwidth := targetwidth, realtargetheight := targetheight
            Else
                reference := ratio - 9 / 16, realtargetwidth := targetheight, realtargetheight := targetwidth
            If (reference > 0)
                resizeto := Round(realtargetheight * width / height)
            Else
                resizeto := realtargetwidth
            tie := "/" . resizeto . "px-"
            RegExMatch(url, "https.*/", parta)
            partb := StrReplace(url, parta)
            partb := partb . tie . partb . ".jpg"
            parta := StrReplace(parta, "/commons/", "/commons/thumb/")
            outputurl := parta . partb
        }
        Else
        {
            outputsha1 := sha1 . "." . headfororiginal
            outputurl := url
        }
        FileAppend, %outputsha1% %outputurl%`r`n
    }
    If removeduplicate
    {
        FileRead, sha1s, %sha1file%
        FileDelete, %sha1file%
        Sort, sha1s, U
        duplicatenumber := ErrorLevel
        FileAppend, %sha1s%, %sha1file%
    }
    Else
        duplicatenumber := 0
    Return, duplicatenumber
}
extractbit(input, power)
{
    probe := 1 << power
    If (input & probe > 0)
        Return, 1
    Return, 0
}
extractbits(input, startingpower, length)
{
    times := 0
    sum := 0
    Loop, %length%
        power := startingpower + times, sum := sum + (extractbit(input, power) << times), times := times + 1
    Return, sum
}
folderpicturesize(folder, match1 := false, match2 := false)
{
    folderpicturesize := 0
    Loop, Files, %folder%\*.*
    {
        If (A_LoopFileExt != "jpg")
            Continue
        If (RegExMatch(A_LoopFileName, "[0-9a-f]+\.[+-]\.") != 1)
            Continue
        If (match1 && (!InStr(A_LoopFileName, match1)))
            Continue
        If (match2 && (!InStr(A_LoopFileName, match2)))
            Continue
        FileGetSize, size, %folder%\%A_LoopFileName%
        folderpicturesize := folderpicturesize + size
    }
    Return, folderpicturesize
}
formatdigits(maybedigit, power)
{
    If maybedigit Is Not digit
        Return, 2 << power
    If ((maybedigit >= 2 << power) || (maybedigit < 0))
        Return, 2 << power
    Return, maybedigit
}
formatoutputdec(output, key, length)
{
    length := length + 1
    keyeq := key . " ="
    keyreg := keyeq . " +[0-9]+"
    If RegExMatch(output, keyreg, formatfrom)
        template := "{: " . length . "d}", formatto := keyeq . Format(template, Trim(StrReplace(formatfrom, keyeq))), output := StrReplace(output, formatfrom, formatto)
    Return, output
}
formatsize(size)
{
    If (size < 0)
        Return, 0
    If (size < 1024)
        Return, size . " b"
    If (size < 1024 * 1024)
        Return, size / 1024 . " kb"
    If (size < 1024 * 1024 * 1024)
        Return, size / 1024 / 1024 . " mb"
    Return, size / 1024 / 1024 / 1024 . " gb"
}
formattriple(first, second, third)
{
    If (first && (!second) && (!third))
        Return, 1
    If ((!first) && second && (!third))
        Return, 2
    If ((!first) && (!second) && third)
        Return, 3
    Return, 0
}
getratio(filename, datfile)
{
    If !filename
        Return, 0
    If (RegExMatch(filename, "[0-9a-f]+", sha1fromfilename) != 1)
        Return, 0
    ratio := 0
    Loop, Read, %datfile%
    {
        If !InStr(A_LoopReadLine, "sha1 =")
            Continue
        RegExMatch(A_LoopReadLine, "sha1 = 0x[0-9a-f]+", sha1)
        sha1 := StrReplace(sha1, "sha1 = 0x")
        If (sha1 != sha1fromfilename)
            Continue
        RegExMatch(A_LoopReadLine, "width = +[0-9]+", width)
        width := RegExReplace(width, "width = +")
        RegExMatch(A_LoopReadLine, "height = +[0-9]+", height)
        height := RegExReplace(height, "height = +")
        ratio := width / height
        Break
    }
    Return, ratio
}
hex2byte(hex)
{
    If (hex = "0")
        Return, "0000"
    If (hex = "1")
        Return, "0001"
    If (hex = "2")
        Return, "0010"
    If (hex = "3")
        Return, "0011"
    If (hex = "4")
        Return, "0100"
    If (hex = "5")
        Return, "0101"
    If (hex = "6")
        Return, "0110"
    If (hex = "7")
        Return, "0111"
    If (hex = "8")
        Return, "1000"
    If (hex = "9")
        Return, "1001"
    If (hex = "a")
        Return, "1010"
    If (hex = "b")
        Return, "1011"
    If (hex = "c")
        Return, "1100"
    If (hex = "d")
        Return, "1101"
    If (hex = "e")
        Return, "1110"
    If (hex = "f")
        Return, "1111"
    Return, "byte"
}
jsonmatch(haystack, key, regex)
{
    key := """" . key . """"
    needle := key . regex
    If RegExMatch(haystack, needle, matched)
        Return, Trim(StrReplace(matched, key), """:, ")
    Return, 0
}
loadconfiguration(configuration, ByRef proxy, ByRef ip1, ByRef ip2, ByRef ip3, ByRef ip4, ByRef port, ByRef frequency, ByRef minute, ByRef nminute, ByRef binaryexclude)
{
    binaryexclude := "0x" . SubStr(configuration, 1, 4), osettings := "0x" . SubStr(configuration, 5)
    proxy := extractbit(osettings, 0), ip1 := extractbits(osettings, 1, 8), ip2 := extractbits(osettings, 9, 8), ip3 := extractbits(osettings, 17, 8), ip4 := extractbits(osettings, 25, 8), port := extractbits(osettings, 33, 16)
    frequency := extractbits(osettings, 49, 6), minute := extractbit(osettings, 55), nminute := !minute
}
loaddefault(ByRef proxy, ByRef ip1, ByRef ip2, ByRef ip3, ByRef ip4, ByRef port, ByRef frequency, ByRef minute, ByRef nminute, ByRef binaryexclude)
{
    proxy := 0, ip1 := 255, ip2 := 255, ip3 := 255, ip4 := 255, port := 65535
    frequency := 30, minute := 1, nminute := !minute
    inputexclude := "/arthropod,/bird,/amphibian,/reptile,/animalso,/fungi,lifeforms", binaryexclude := "0x" . category(inputexclude)
}
matches(monitortype, ByRef match1 := "", ByRef match2 := "")
{
    orientation := SubStr(monitortype, 1, 1)
    If orientation Not In -,+
        Return, 0
    match1 := "." . orientation . "."
    resolution := SubStr(monitortype, 2, 1)
    If (resolution = 1)
        match2 := ".fhd."
    Else If (resolution = 2)
        match2 := ".qhd."
    Else If (resolution = 3)
        match2 := ".uhd."
    Else
        Return, 0
    typeindex := 2 * resolution
    If (orientation = "-")
        typeindex := typeindex - 1
    Return, typeindex
}
oct2hexhex(oct)
{
    If (StrLen(oct) != 8)
        Return, "hh"
    Return, byte2hex(SubStr(oct, 1, 4)) . byte2hex(SubStr(oct, 5))
}
remeovefile(filepath, ByRef numberdelta, ByRef sizedelta)
{
    FileGetSize, size, %filepath%
    FileDelete, %filepath%
    If !ErrorLevel
        numberdelta := numberdelta + 1, sizedelta := sizedelta + size
}
removethumb(ByRef somelink)
{
    If InStr(somelink, "/thumb/")
    {
        somelink := StrReplace(somelink, "/thumb/", "/")
        RegExMatch(somelink, "https.*/", somelink)
        RegExMatch(somelink, "https.*[^/]", somelink)
    }
    RegExMatch(somelink, "https.*\.", somelinkwithoutextension)
    Return, StrReplace(somelink, somelinkwithoutextension)
}
resumetimer(timer, ringtime)
{
    EnvSub, ringtime, A_NowUTC, Seconds
    If (ringtime <= 0)
        GoSub, %timer%
    Else
    {
        ringtime := 1000 * ringtime
        SetTimer, %timer%, %ringtime%
    }
}
sha(file, sha1 := false)
{
    sha := ""
    file := "'" . StrReplace(file, "'", "''") . "'"
    If sha1
        RunWait, powershell.exe Get-FileHash -Algorithm SHA1 -Path %file% | Select-Object -Property Hash | Out-File -FilePath temp-sha.log, , Hide
    Else
        RunWait, powershell.exe Get-FileHash -Algorithm SHA256 -Path %file% | Select-Object -Property Hash | Out-File -FilePath temp-sha.log, , Hide
    Loop, Read, temp-sha.log
    {
        realline := Trim(A_LoopReadLine)
        If (realline = "")
            Continue
        If realline Is xdigit
            sha := realline
    }
    FileDelete, temp-sha.log
    If (sha = "")
        Return, 0
    StringLower, sha, sha
    Return, sha
}
simpledownload(oneline, folder, proxy := false, mute := true, timeout := false)
{
    RegExMatch(oneline, "[^ ]+", filename)
    RegExMatch(oneline, "https://.*", url)
    renameto := folder . "\" . filename
    If FileExist(renameto)
        Return, renameto
    Else
        udtlp(url, renameto, proxy, mute, timeout)
    If ErrorLevel
        Return, 0
    Else
        FileGetSize, size, %renameto%
    If (size < 4096)
    {
        FileDelete, %renameto%
        Return, 0
    }
    Return, renameto
}
superdat2sha1(datfile, sha1file, monitortypes, binaryexclude)
{
    monitorcount := monitortypes.Length()
    finishlist := ""
    Loop, %monitorcount%
    {
        monitortype := monitortypes[A_Index]
        If monitortype In %finishlist%
            Continue
        dat2sha1(datfile, sha1file, A_Index - 1, SubStr(monitortype, 1, 1), SubStr(monitortype, 2, 1), binaryexclude, false)
        If (A_Index = 1)
            finishlist := finishlist . "," . monitortype
        Else
            finishlist := monitortype
    }
    FileRead, sha1s, %sha1file%
    FileDelete, %sha1file%
    Sort, sha1s, U
    FileAppend, %sha1s%, %sha1file%
    Loop, Read, %sha1file%, temp-sha1s.log
    {
        RegExMatch(A_LoopReadLine, "[^.]+", sha1)
        FileAppend, %sha1%`r`n
    }
    FileRead, sha1s, temp-sha1s.log
    FileDelete, temp-sha1s.log
    Sort, sha1s, U
    FileAppend, %sha1s%, temp-sha1s.log
    qualifieddatanumber := 0
    Loop, Read, temp-sha1s.log
        qualifieddatanumber := A_Index
    FileDelete, temp-sha1s.log
    Return, qualifieddatanumber
}
superremove(sha1file, folder, simple := true, ByRef removednumberdelta := 0, ByRef removedsizedelta := 0, showprocess := false)
{
    If showprocess
    {
        totalfilenumber := 0
        Loop, Files, download\*.*
            totalfilenumber := A_Index
    }
    FileDelete, temp-filenames.log
    Loop, Read, %sha1file%, temp-filenames.log
    {
        RegExMatch(A_LoopReadLine, "[^ ]+", filename)
        FileAppend, %filename%`r`n
    }
    Loop, Files, %folder%\*.*
    {
        process := process + 1
        If showprocess
            Menu, Tray, Tip, finishing: %process%/%totalfilenumber%
        If A_LoopFileExt Not Contains jpg,jpeg,png,tif,tiff
            Continue
        If (RegExMatch(A_LoopFileName, "[0-9a-f]+\.[+-]\.", sha1dotpmdot) != 1)
            Continue
        file := A_LoopFileName
        filepath := folder . "\" . A_LoopFileName
        extensions := StrReplace(A_LoopFileName, sha1dotpmdot)
        RegExMatch(extensions, "[^.]+", extension1)
        remove := true
        If (extensions = A_LoopFileExt)
        {
            If !simple
            {
                Loop, Read, temp-filenames.log
                {
                    If (A_LoopReadLine = file)
                    {
                        remove := false
                        Break
                    }
                    Else If InStr(A_LoopReadLine, file)
                    {
                        resizedversion := folder . "\" . A_LoopReadLine
                        If !FileExist(resizedversion)
                        {
                            remove := false
                            Break
                        }
                    }
                }
            }
        }
        Else
        {
            Loop, Read, temp-filenames.log
            {
                If (A_LoopReadLine = file)
                {
                    remove := false
                    Break
                }
            }
        }
        If remove
            remeovefile(filepath, removednumberdelta, removedsizedelta)
    }
    FileDelete, temp-filenames.log
}
types2countarray(monitortypes)
{
    countarray := [0, 0, 0, 0, 0, 0]
    monitorcount := monitortypes.Length()
    Loop, %monitorcount%
        typeindex := matches(monitortypes[A_Index]), countarray[typeindex] := countarray[typeindex] + 1
    Return, countarray
}
types2numberrestrictions(countarray)
{
    numberarray := [0, 0, 0, 0, 0, 0]
    numberarray[1] := 16 * countarray[1]
    numberarray[2] := 16 * countarray[2]
    numberarray[3] := 9 * countarray[3]
    numberarray[4] := 9 * countarray[4]
    numberarray[5] := 4 * countarray[5]
    numberarray[6] := 4 * countarray[6]
    Return, numberarray
}
types2sizerestrictions(countarray)
{
    sizearray := [0, 0, 0, 0, 0, 0]
    sizearray[1] := 9 * 1024 * 1024 * countarray[1]
    sizearray[2] := 9 * 1024 * 1024 * countarray[2]
    sizearray[3] := 16 * 1024 * 1024 * countarray[3]
    sizearray[4] := 16 * 1024 * 1024 * countarray[4]
    sizearray[5] := 36 * 1024 * 1024 * countarray[5]
    sizearray[6] := 36 * 1024 * 1024 * countarray[6]
    Return, sizearray
}
udtlp(uri, outfile, proxy := false, mute := false, timeout := false)
{
    Loop
    {
        If !proxy
            UrlDownloadToFile, %uri%, %outfile%
        Else
        {
            If timeout
                tail := "-TimeoutSec " . timeout
            Else
                tail := ""
            cmd := "Invoke-WebRequest -Uri '" . uri . "' -Proxy '" . proxy . "' -OutFile '" . outfile . "'" . tail
            RunWait, powershell.exe %cmd%, , Hide
        }
        If ErrorLevel
        {
            If (InStr(A_ScriptName, ".ahk") && (A_Index = 2))
            {
                If proxy
                    FileAppend, powershell.exe %cmd%`r`n, downloaderror.log
                Else
                    FileAppend, UrlDownloadToFile`, %uri%`, %outfile%`r`n, downloaderror.log
            }
            If mute
                Break
            MsgBox, 5, Download Error, Retry or Cancel?
            IfMsgBox Cancel
                Break
        }
        Else
            Break
    }
    Return, ErrorLevel
}
unicodeplus(string, wiki := false)
{
    string := StrReplace(string, "%", "%25"), string := StrReplace(string, " ", "%20"), string := StrReplace(string, "&", "%26"), string := StrReplace(string, "+", "%2b"), string := StrReplace(string, "'", "%27"), string := StrReplace(string, """", "%22"), string := StrReplace(string, "``", "%60")
    Loop
    {
        If !RegExMatch(string, "\\u[0-9a-f][0-9a-f][0-9a-f][0-9a-f]", transfrom)
            Break
        If wiki
        {
            wikicode := StrReplace(transfrom, "\u")
            If (SubStr(wikicode, 1, 1) = "0")
                length := 3, wikicode := SubStr(wikicode, 2)
            Else
                length := 4
            Loop, %length%
                hex := SubStr(wikicode, 1, 1), wikicode := SubStr(wikicode, 2) . hex2byte(hex)
            If (length = 3)
            {
                part1 := "10" . SubStr(wikicode, 7), part2 := SubStr(wikicode, 1, 6)
                lead2 := SubStr(part2, 1, 1)
                If (lead2 = "0")
                    part2 := "11" . part2, wikicode := "%" . oct2hexhex(part2) . "%" . oct2hexhex(part1)
                Else
                    part2 := "10" . part2, wikicode := "%E0%" . oct2hexhex(part2) . "%" . oct2hexhex(part1)
            }
            Else
                part1 := "10" . SubStr(wikicode, 11), part2 := "10" . SubStr(wikicode, 5, 6), part3 := "1110" . SubStr(wikicode, 1, 4), wikicode := "%" . oct2hexhex(part3) . "%" . oct2hexhex(part2) . "%" . oct2hexhex(part1)
            transto := wikicode
        }
        Else
        {
            utf8code := Chr(StrReplace(transfrom, "\u", "0x"))
            transto := utf8code
        }
        string := StrReplace(string, transfrom, transto)
    }
    string := StrReplace(string, "\")
    Return, string
}
