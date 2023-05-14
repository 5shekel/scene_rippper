# adapt in directory and output directory, fit your operating system
# all movie scenes will be saved in output dir in a new folder (media name)
[CmdletBinding()]
param (
    $indir='/home/user/vidz/movies/A_Machine_To_Die_For_The_Quest_For_Free_Energy-c6UgV3gVmd0.webm-streamReady.ogv',
    $outdir="/home/user/vidz/scenes/"
)

#check if indir exists
if (!(Test-Path $indir)) {
    Write-Host "Input directory/file does not exist"
    exit
}

Get-ChildItem $indir -Filter *.* | ForEach-Object {
    #next 5 lines are housekeeping, getting the filenames in order. 
    $infile = $_.FullName
    $baseName = $_.BaseName.Replace(' ', '_')
    $outputFolder = $outdir + $baseName
    New-Item -ItemType Directory -Force -Path $outputFolder -ea 0 | Out-Null
    $output = $outputFolder + '/' + $baseName

    #print in
    Write-Host $infile
    #detect if media has P/B frames and if so, use scene detection, otherwise use keyframes
    $frameTypes = ffprobe -hide_banner -v error -read_intervals %00:02:00 -select_streams v -show_entries "frame=pict_type" -of csv "$infile" #| Out-File $outputFolder/frameTypes.txt 

    foreach ($line in $frameTypes) {
        if ($line -match "[PB]") {
            $keyframeFound = $true
            "we found P|B keyframe, run fast keyframe extractor"
            break
        }else{
            $keyframeFound = $false
            "no P|B keyframe found, run scene detection"
        }
    }

    #if input stream codec is not supported by mp4, change to mkv
    $codec = ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$infile"
    Write-Host "codec is $codec"
    if ($codec -ne "h264") {
        $ext = "mkv"
    } else {
        $ext = "mp4"
    }

    if ($keyframeFound) {
        #using source KEYframe data
        & ffmpeg -hide_banner -i "$infile" -c copy -map 0 -segment_time 0.01 -f segment "${output}__%07d_key.$($ext)"
    } else {
        #using scene detection
        & ffmpeg -hide_banner -i "$infile" -vf "scdet" -sn -map 0 -f segment -segment_format $ext "${output}__%07d_detect.$($ext)"
    }
}