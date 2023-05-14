import os
import subprocess
import re

input_path = '/home/user/Storage/Movies/Tokyo Godfathers/Tokyo Godfathers.avi'
outdir = '/home/user/vidz/scenes/'


def print_pink(*args):
    text = ' '.join(map(str, args))
    print('\033[95m' + text + '\033[0m')


# If the input is a directory, get a list of files. If it's a single file, make a one-item list.
if os.path.isdir(input_path):
    infiles = [os.path.join(input_path, fname) for fname in os.listdir(input_path)]
elif os.path.isfile(input_path):
    infiles = [input_path]
else:
    print_pink(f"{input_path} does not exist")
    exit()

for infile in infiles:
    baseName = os.path.splitext(os.path.basename(infile))[0].replace(' ', '_')
    outputFolder = os.path.join(outdir, baseName)
    os.makedirs(outputFolder, exist_ok=True)
    output = os.path.join(outputFolder, baseName)

    print_pink("working on:" + infile)
    frameTypes = subprocess.run(['ffprobe', '-hide_banner', '-v', 'error', '-read_intervals', '%00:02:00', '-select_streams', 'v', '-show_entries', 'frame=pict_type', '-of', 'csv', infile], capture_output=True, text=True).stdout

    keyframeFound = False
    for line in frameTypes.split('\n'):
        if re.search("[PB]", line):
            keyframeFound = True
            print_pink("we found P|B keyframe, run fast keyframe extractor")
            break
    if not keyframeFound:
        print_pink("no P|B keyframe found, run scene detection")

    codec = subprocess.run(['ffprobe', '-hide_banner', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=codec_name', '-of', 'default=nw=1:nk=1', infile], capture_output=True, text=True).stdout.strip()
    print_pink("codec is", codec)


    # if codec not h264 or xvid, use mkv
    if codec in ['h264']:
        ext = 'mp4'
    else:
        ext = 'mkv'

    if keyframeFound:
        #not sure if this fflags and vsync are ok for all cases
        #they helped with melformed mpeg4/avi
        subprocess.run(['ffmpeg', '-hide_banner', '-fflags', '+genpts', '-i', infile, '-c', 'copy', '-map', '0', '-segment_time', '0.01', '-f', 'segment', '-vsync', '0', f"{output}__%07d_key.{ext}"])
    else:
        subprocess.run(['ffmpeg', '-hide_banner', '-i', infile, '-vf', 'scdet', '-sn', '-map', '0', '-f', 'segment', '-segment_format', ext, f"{output}__%07d_detect.{ext}"])
