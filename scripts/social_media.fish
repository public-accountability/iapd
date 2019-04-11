#!/usr/bin/env fish

set out_file iapd_social_media.txt

truncate -s0 $out_file


find . -name '*Schedule_D_1I*.csv' | while read file
    tail -n +2 $file \
    | awk -F ',' '{ print $2 }' \
    | tr -d '"' \
    | sort | uniq \
    >> $out_file 
end

    
