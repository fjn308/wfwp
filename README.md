# 1. Introduction

`wfwp` is a wallpaper displayer for windows. Using [Wikimedia Commons](https://commons.wikimedia.org/wiki/Main_Page) as its wallpaper source, `wfwp` detects orientations and resolutions of your monitor, automatically selects suitable pictures from over 15,000 high-quality [featured pictures](https://commons.wikimedia.org/wiki/Commons:Featured_pictures), and change them as your wallpaper at a given frequency.

Other notable features include: multiple monitors, blacklisting specific pictures or excluding specific categories of pictures, manually switching over pictures, downloading or checking details of original pictures, and HTTP proxy for people who have [limited access to wikipedia](https://en.wikipedia.org/wiki/Censorship_of_Wikipedia).

# 2. Screenshots

![desktop](/screenshots/1.png)

### 2.1 Menu

![menu](/screenshots/2.png)![blacklist](/screenshots/3.png)

### 2.2 Settings

![general](/screenshots/4.png)![exclude](/screenshots/5.png)

### 2.3 Multiple Monitors

If there are multiple monitors, a clickable "Which One?" box will appear when **Switch**, **Blacklist**, **Details**, or **Original** button is clicked:

![whichone](/screenshots/6.png)

Here is a real example:

![photo](/screenshots/7.png)

# 3. Things You need to Know

- `wfwp` assumes that aspect ratios of monitors are around 16:9, that is, for landscape monitors, it selects wallpapers from the pictures with ratios between 4:3 and 256:81; while for portrait monitors, the ratios would be between 256:81 and 3:4.

- `wfwp` caches pictures to ensure smooth switches. For each monitor, there is an independent limitation on its cache:
  - resolution smaller or equal to FHD (1920*1080): 9MB FHD pictures resized from higher resolution ones;
  - resolution smaller or equal to QHD (2560*1440, a.k.a 2K) but over FHD: 16MB QHD pictures resized from higher resolution ones;
  - resolution smaller or equal to UHD (3840*2160, a.k.a 4K) but over QHD: 36MB UHD pictures resized from higher resolution ones.

- `wfwp` treats monitors with resolutions larger than UHD as UHD. If you have such monitor, sorry :(

- `wfwp` is only tested on my Windows 11, but it should work fine on Windows 10. The only potential limitations come from several Powershell commands in support of proxy and checksum, while Powershell 5.1 is pre-installed on all Windows 10, where the related commands are already supported.

# 4. Things You May Want to Know

- `wfwp` is written in [autohotkey](https://www.autohotkey.com/), a script language exclusive for Windows. At first, I just wanted to fix my wallpaper shortage situation caused by mistakenly deleting my library. I am not even an amateur programmer but `autohotkey` is easy to get started. The scripts aimed at downloading pictures eventually grew into `wfwp`. If necessary, I will re-write it in a more suitable language, but for now I think `autohotkey` is enough.

- `wfwp` selects pictures based on the [resolved.dat](https://raw.githubusercontent.com/fjn308/wfwp/main/upload/resolved.dat), which has information on all featured pictures at the time being. It can be generated by the script `featured.ahk`. Normally `resolved.dat` does not require frequent updates because of its large capacity, so I only gave `wfwp` the ability to get `resolved.dat` from GitHub, where it is updated once a month. If there come situations requiring an up-to-date `resolved.dat`, it can be generated by manualy running `featured.ahk`.

- Except for `featured.ahk`, there is another script called `download.ahk`, which can work with `featured.ahk` to achieve an expanded freedom of selecting and downloading featured pictures. Check [here](https://github.com/fjn308/wfwp/tree/main/scripts) to learn more.

# 5. Icons and Legal Issues

Except for the wallpapers, which come from [Wikimedia Commons](https://commons.wikimedia.org/wiki/Main_Page), the icons used in `wfwp` are also from Wiki Commons:

```
commons.ico: https://commons.wikimedia.org/static/favicon/commons.ico
commons.png: https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Commons-logo.svg/720px-Commons-logo.svg.png
```

If there are any legal issues requiring further addressing, please let me know. Thank you.

# 6. 2023 Roadmap

- [ ] Support Monitors with Resolutions over UHD
- [ ] Re-write to be Cross-platform: Add Support for macOS