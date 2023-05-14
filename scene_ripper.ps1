# adapt input directory and output directory, fit your operating system
# all movie scenes will be saved in output dir in a new folder (media name)

$indir='/mnt/Video/Au Service De La France - season 2/'
$outdir="au/"

Get-ChildItem $indir -Filter *.* | ForEach-Object {
    #next 5 lines are housekeeping, getting the filenames in order. 
    $input = $_.FullName
    $baseName = $_.BaseName.Replace(' ', '_')
    $outputFolder = $outdir + $baseName
    New-Item -ItemType Directory -Force -Path $outputFolder 
    $output = $outputFolder + '/' + $baseName

    #using scene detection
    # & ffmpeg -hide_banner -i "$input" -vf "scdet" -sn -map 0 -f segment -segment_format mp4 "${output}__%07d_detect.mp4"
    
    #using source keyframe data
    & ffmpeg -hide_banner -i "$input" -c copy -map 0 -segment_time 0.01 -f segment "${output}__%07d_key.mp4"

}