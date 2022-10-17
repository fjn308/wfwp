With autohotkey installed, parameters of featured.ahk and download.ahk can be adjusted by simply editing the top few lines of the scripts. Such lines are listed as follows.

#### 1. featured.ahk

```ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proxy := false ; false means following windows
server := "http://127.0.0.1:1079" ; have to be http
screenorientation := "+" ; "+"(4:3 <= landscape <= 256:81), "-"(81:256 <= portrait <= 3:4), 0(any)
minimalresolution := 2 ; 3(uhd+), 2(qhd+), 1(fhd+), 0(any)
resize := true ; false means writing urls of original pictures (can be extremely large) to the sha1 file
exclude := "/arthropod,/bird,/amphibian,/reptile,/oanimals,/fungi,/olifeforms"
; full list: "/arthropod,/bird,/mammal,/amphibian,/fish,/reptile,/oanimals,/bone,/shell,/plant,/fungi,/olifeforms", empty list: ""
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
formats := "tif,tiff,jpg,jpeg,png" ; do not edited this unless confident enough
skipgeneratingdat := false ; true means using an existing resolved.dat
skipgeneratingsha1 := true ; true means generating the resolved.dat only
update := true ; false means generating the resolved.dat without referencing a refernce.dat
upload := false ; true means generating a reference.dat as well
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```

Here the special values, `screenorientation := 0`, `minimalresolution := 0`, and `resize := false`, can be achieved, which allows more freedom together with download.ahk, such as downloading all original files of featured pictures (do not abuse).

If you want to generate a resolved.dat from scratch, set `update := false`, but which may take a few hours. A more convenient way is to set `update := true` and put the [upload folder](https://github.com/fjn308/wfwp) in the same folder, featured.ahk will only generate new items and append them after the old ones.

#### 2. download.ahk

```ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proxy := false
server := "http://127.0.0.1:1079"
restrictioninmb := 16 ; 0 for skipping resizing failures
; downloading original pictures is taken as a workaround of temporary resizing failures, where a restriction on size is necessary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```

download.ahk takes the output sha1 files from featured.ahk as inputs, then downloads and saves them as normalized filenames. If some picture cannot be resized by wikimedia, download.ahk will try to fetch its original version, where a restriction on file size can be set.

#### 3. functions.ahk

functions.ahk serves as a library for wfwp.ahk, featured.ahk, and download.ahk.
