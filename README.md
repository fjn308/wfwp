# 1. Introduction

`wfwp` is a wallpaper switcher for Windows. Using [Wikimedia Commons](https://commons.wikimedia.org/wiki/Main_Page) as its wallpaper source, `wfwp` detects orientations and resolutions of your monitors, automatically selects suitable pictures from over 15,000 high-quality [Featured Pictures](https://commons.wikimedia.org/wiki/Commons:Featured_pictures), and change them as your wallpaper at a given frequency.

Other notable features include: supporting multiple monitors, blacklisting specific pictures or excluding specific categories of pictures, manually switching over pictures, downloading original pictures or checking details of them, and HTTP proxy for people who have [limited access to Wikipedia](https://en.wikipedia.org/wiki/Censorship_of_Wikipedia).

# 2. Screenshots

![desktop](/screenshots/1.png)

### 2.1 Menu

![menu](/screenshots/2.png)![blacklist](/screenshots/3.png)

### 2.2 Settings

![general](/screenshots/4.png)![exclude](/screenshots/5.png)

### 2.3 Multiple Monitors

If there are multiple monitors, a clickable "Which One?" box will appear when **Switch**, **Undo**, **Blacklist**, **Details**, or **Original** button is clicked:

![whichone](/screenshots/6.png)

Here is a real example:

![photo](/screenshots/7.png)

# 3. Things You Need to Know

- `wfwp` assumes that aspect ratios of monitors are around 16:9, that is, for landscape monitors, it selects wallpapers from the pictures with ratios between 4:3 and 64:27; while for portrait monitors, the ratios would be between 64:27 and 3:4.

- `wfwp` caches pictures to ensure smooth switches. For each monitor, there is an independent limitation on its cache:
  - Resolution smaller or equal to FHD (1920*1080): ~9MB FHD pictures resized from higher resolution ones;
  - Resolution smaller or equal to QHD (2560*1440, aka 2K) but over FHD: ~16MB QHD pictures resized from higher resolution ones;
  - Resolution smaller or equal to UHD (3840*2160, aka 4K) but over QHD: ~36MB UHD pictures resized from higher resolution ones.

- `wfwp` treats monitors with resolutions larger than UHD as UHD for now, to ensure performance. If you have such monitors, sorry :(

- `wfwp` is only tested on my Windows 11, but it should work fine on Windows 10. The only potential limitations come from several PowerShell commands in support of proxy and checksum, while PowerShell 5.1 is pre-installed on all Windows 10, where the related commands are already supported.

# 4. Usage

### 4.1 Ordinary

Download the `wfwp.exe` from [Releases](https://github.com/fjn308/wfwp/releases) and put it into a proper folder, where `wfwp` can generate configuration or other files and cache pictures. During the first run, it will download the database (`resolved.dat`, ~5MB) automatically after initial settings are saved. You can also manually download the database [here](https://raw.githubusercontent.com/fjn308/wfwp/main/upload/resolved.dat) and put it into the same folder before running `wfwp`.

If your network is limited to accessing GitHub or Wikipedia, a proxy has to be set up. You can then configure it in the `wfwp` settings menu (only HTTP proxies are supported), or in the settings of Windows. For the latter, `wfwp` follows the proxy settings of your system and performs better.

### 4.2 Advanced

If you have [AutoHotkey](https://www.autohotkey.com/) (current version, not deprecated v1.0 or v2 beta) installed, you can also run the `wfwp.ahk` directly or compile a `wfwp.exe` yourself (select `commons.ico` as icon manually). The minimal source files required are `.\wfwp.ahk`, `.\commons.ico`, `.\commons.png`, and `.\scripts\functions.ahk`. The only difference between the script file and the executable binary is that the former does not have the ability to update itself.

# 5. Things You May Want to Know

- Known limitations:
  - For some particular systems, `TrayTip`, which creates a balloon message window near the tray icon, [does not work](https://www.autohotkey.com/boards/viewtopic.php?t=66010). While `wfwp` uses `TrayTip` to send weak notifications, that is, information not important enough to interrupt users, such as "Failed to ...", where users cannot do anything besides knowing it. Of course, this problem will be solved as soon as `wfwp` is re-written in another language. You can check whether your system has this problem by clicking the "Download the Original" button, after a few seconds, whether successful or not, a notification should show.

- `wfwp` is written in AutoHotkey, a script language exclusive for Windows. At first, I just wanted to fix my wallpaper shortage situation caused by mistakenly deleting my library. I am not even an amateur programmer, but AutoHotkey is easy to get started. The scripts aimed at downloading pictures eventually grew into `wfwp`. If necessary, I will re-write it in a more suitable language, but for now I think AutoHotkey is enough.

- `wfwp` selects pictures based on the `resolved.dat`, which has core information on all Featured Pictures. It can be generated by the script `featured.ahk`. Normally `resolved.dat` does not require frequent updates because of its large capacity, so I only gave `wfwp` the ability to get `resolved.dat` from GitHub, where I update it once a month. If there come situations requiring an up to date `resolved.dat`, it can be generated by manualy running `featured.ahk`.

- Except for `featured.ahk`, there is another script called `download.ahk`, which can work with `featured.ahk` to achieve an expanded freedom of selecting and downloading Featured Pictures. Check [here](https://github.com/fjn308/wfwp/tree/main/scripts) to learn more.

# 6. Icons and Legal Issues

Except for the wallpapers, which come from Wikimedia Commons, the icons used in `wfwp` are also from Wikimedia Commons:

```
commons.ico: https://commons.wikimedia.org/static/favicon/commons.ico
commons.png: https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Commons-logo.svg/720px-Commons-logo.svg.png
```

If there are any legal issues requiring further addressing, please let me know. Thank you.

# 7. 2023 Roadmap

- [ ] Support Monitors with Resolutions over UHD
- [ ] Re-write to be Cross-platform: Add Support for macOS
