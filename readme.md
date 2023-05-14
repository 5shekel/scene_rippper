## cut a movie (folder) to scenes

currntly working is the simple ffmpeg keyframe split. its very fast. 
might not cover all edge cases, but for h264 encoded stuff (95% of downloaded content) it works great.

### requirements
  * ffmpeg
  * powershell

### usage
```
./scene_ripper.ps1 -indir "/videodir" -outdir "/outdir"
```


### links
  * [gist](https://gist.github.com/5shekel/c06aa36b88dd325735405833e903cf9b) 
  * https://www.geeksforgeeks.org/difference-between-inter-and-intra-frame-compression/
  
