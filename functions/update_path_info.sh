#!/bin/bash

update_path_info() {
    local file path line rating last_cd now_cd
    file="../test_file"
    path=$1
    line=("$(\grep -n "$path" "$file")")
    rating=${line[1]}
    last_cd=${line[2]}
    now_cd=$(\date +%s)
    echo ${line[*]}
}
