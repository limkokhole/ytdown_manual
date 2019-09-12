#In case youtube-dl not able download, this is temporary solution before youtube-dl update.
#Go to network inspector from web browser -> right-click on youtube video page -> inspect element, to trace the video and audio url. You can click the top tab "Media" to easily recognize video/audio url.
<<"NOTE"
format code  extension  resolution note
249          webm       audio only tiny   60k , opus @ 50k (48000Hz), 1.46MiB
250          webm       audio only tiny   79k , opus @ 70k (48000Hz), 1.93MiB
140          m4a        audio only tiny  130k , m4a_dash container, mp4a.40.2@128k (44100Hz), 3.51MiB
251          webm       audio only tiny  153k , opus @160k (48000Hz), 3.78MiB
160          mp4        256x144    144p   83k , avc1.4d400c, 30fps, video only, 1.81MiB
278          webm       256x144    144p   84k , webm container, vp9, 30fps, video only, 2.14MiB
242          webm       426x240    240p  126k , vp9, 30fps, video only, 2.70MiB
133          mp4        426x240    240p  196k , avc1.4d4015, 30fps, video only, 4.24MiB
243          webm       640x360    360p  206k , vp9, 30fps, video only, 4.93MiB
244          webm       854x480    480p  331k , vp9, 30fps, video only, 7.74MiB
134          mp4        640x360    360p  380k , avc1.4d401e, 30fps, video only, 7.99MiB
135          mp4        854x480    480p  634k , avc1.4d401f, 30fps, video only, 14.69MiB
247          webm       1280x720   720p  683k , vp9, 30fps, video only, 16.74MiB
136          mp4        1280x720   720p 1269k , avc1.4d401f, 30fps, video only, 29.57MiB
43           webm       640x360    360p , vp8.0, vorbis@128k, 15.75MiB
18           mp4        640x360    360p  401k , avc1.42001E, mp4a.40.2@ 96k (44100Hz), 10.87MiB
22           mp4        1280x720   720p 1220k , avc1.64001F, mp4a.40.2@192k (44100Hz) (best)

#e.g. 720p, unlike youtube-dl which choose 136(mp4, avc1, 1269k) and 251(webm, opus), this trick will consistently download 247 (webm, vp9, 683k) and 251(same) only which get from network inspector which is smaller file size.
NOTE
if [ "$#" -ne 5 ]; then
	echo "Usage: ytdown <video url> <audio url> <name> <upload date> <video id>"
	echo "Tip: "
	echo "[1] The video url normally bigger size or itag=243/247, while audio url is smaller size or itag=251. You can quickly recognize the url by checking the filter by Media tab in network inspector,  then sort by file size and right-click to copy the biggest and smallest size url(but don't copy too small size in Bytes which neither audio nor video url), OR double click the url to see it's video or audio(only first two links works)."
	echo "[2] You choose highest quality on video settings first, click trash icon to clear inspector log, then get the latest/highest quaility media url by dragging the duration bar."
	echo "[3] The order of <video url> and <audio url> not important."
	exit 1
fi
#yt_list_f='/tmp/yt_list.txt' #ffmpeg
function download_yt_va_only() {
	echo 'start again'
    	#>"$yt_list_f" #ffmpeg
	>"$2" #ffmpeg disable this #nid this to prevent append prev abort file.
	#tmpdir=$(mktemp -d mscript.XXXXXXXXXX) #ffmpeg
	#The download speed of this fixed lenght 7500000 is normal speed(fast) to download compare to range=0- or remove range=x-xx
	#, while the cons is bigger size in temporary file size, but final output file will same.
	s=0 
	init=7500000 #if want test slow speed, simply increase this to big size
	#init=171786
	#init=140347
	#init=160000
	e=$init
	url=''
	tmpfile=''
	while :; do
		#echo 'while again'
		#tmpfile="$(mktemp -p "$tmpdir")" #ffmpeg
		url="$(echo $1 | sed 's/?/?range='"$s"-"$e"'&/g')" #to make duplicate &range= works, must put infront
		status="$(curl -sILk "$url" -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:70.0) Gecko/20100101 Firefox/70.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://www.youtube.com/' -H 'Origin: https://www.youtube.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache'  -w "%{http_code}" | tail -1)"
		if [ "$status" -eq 200 ]; then
			echo Download next "$tmpfile" segment ...

			#curl -sLk "$url" -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:70.0) Gecko/20100101 Firefox/70.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://www.youtube.com/' -H 'Origin: https://www.youtube.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' > "$tmpfile" #ffmpeg
			curl -Lk "$url" -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:70.0) Gecko/20100101 Firefox/70.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://www.youtube.com/' -H 'Origin: https://www.youtube.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' >> "$2" #ffmpeg disable this

			s=$(($e+1)) #the youtube also +1, not +0
			e=$(($s+$init))
			#echo file \'"$(realpath $tmpfile)"\' >> "$yt_list_f" #ffmpeg concat
			#echo "$(realpath $tmpfile)" >> "$yt_list_f" #for normal cat #[DEPRECATED], juz direct use curl >>
			#echo 'done 200'
		else
			#echo '[Start concat]' #ffmpeg
			#currently ffmpeg -c copy not working to access 2nd raw file.
			#if want test, this don't forget change the `echo file ... >> "$yt_list_f" ` above and enable #ffmpeg tag
			#if [ "$3" == true ]; then
			#	echo 'dream come true'
			#	#-flags +global_header
			#	ffmpeg -f concat -safe 0 -i "$yt_list_f" -c copy "$2"
			#else
			#	echo 'dream come false'
			#	ffmpeg -f concat -safe 0 -i "$yt_list_f" -c copy "$2"
			#fi

			#ffmpeg:
			#while read line; do
			#	echo Concating "$line" ...
			#	cat "$line" >> "$2"
			#done < "$yt_list_f"
			#echo 'break now'
			break
		fi
		#echo 'done this round'
	done
	#ffmpeg
	#echo removing "$tmpdir"...
	#rm -r "$tmpdir"
	#cat "$yt_list_f" #ffmpeg
}
export -f download_yt_va_only
#https://stackoverflow.com/questions/4814040/allowed-characters-in-filename
#Append ext only after sed, to not remove ext's dot
aname="$(echo "$3"_"$4"_"$5"_tmp_a | sed 's/[]*./\:"<>|[]/_/g')"'.webm' #if pass wrong .m4a may not works, so always pass .webm
echo '[Start download 1st url]'
download_yt_va_only "$2" "$aname" true
vname="$(echo "$3"_"$4"_"$5"_tmp_v | sed 's/[]*./\:"<>|[]/_/g')"'.webm'
echo '[Start download 2nd url]'
download_yt_va_only "$1" "$vname" false
final_name="$(echo "$3"_"$4"_"$5" | sed 's/[]*./\:"<>|[]/_/g')"'.webm' 
echo '[Start concat audio and video to final output]'
ffmpeg -i "$aname" -i "$vname" -c copy "$final_name"
echo removing "$aname"
rm "$aname"
echo removing "$vname"
rm "$vname"
echo '[Done]'

