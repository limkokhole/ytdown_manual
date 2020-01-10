# ytdown_manual
Download Youtube manually, a temporary workaround before your downloader such as youtube-dl patch if youtube website changed. 

### Usage:

    xb@dnxb:~/note/sh/ytdown_manual$ ytdown 
    Usage: ytdown <video url> <audio url> <name> <upload date> <video id>
    Tip: 
    [1] The video url normally bigger size or itag=243/247, while audio url is smaller size or itag=251. You can quickly recognize the url by checking the filter by Media tab in network inspector,  then sort by file size and right-click to copy the biggest and smallest size url, OR double click the url to see it's video or audio(only first two links works).
    [2] You choose highest quality on video settings first, click trash icon to clear inspector log, then get the latest/highest quaility media url by dragging the duration bar.
    [3] The order of <video url> and <audio url> not important.
    xb@dnxb:~/note/sh/ytdown_manual$ 

### Why not just use `&range=0-` or remove `&range=` ?:

Download as chunk of segments required to keep the initial fast download speed, or else it probably drop to very slow speed.

### Command alias:

You probably want to make it as alias in ~/.bash_aliases, e.g.:

    alias ytdown='bash ~/n/sh/ytdown_manual/ytdown.sh'

### Demo video (Click image to play at YouTube):

[![watch in youtube](https://i.ytimg.com/vi/M2qlShbm2os/hqdefault.jpg)](https://www.youtube.com/watch?v=M2qlShbm2os "ytdown manual")
