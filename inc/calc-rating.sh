#!/bin/bash

#######################################
# get_new_rating
# Description:
#   Calculate a new value based on the provided parameters.
# Arguments:
#   $1 : old_rating - The original value (between 0 and 100).
#   $2 : last_time_cd - The last time the directory was changed (unixtime).
# Outputs:
#   Integer - The calculated new value.
# Returns:
#   None
#######################################
get_new_rating() {
    local old_rating=$1
    local last_time_cd=$2

    local date_multiplier multiplier result
    date_multiplier=$(rating::get_date_value "$last_time_cd")

    # scale the multiplier to the old_rating
    multiplier=$(rating::get_scaled_multiplier "$old_rating" "$date_multiplier")

    # integer new value, calculated by old value and manipulated multiplier
    result=$(printf "%.0f\n" "$(echo "scale=0; $old_rating * $multiplier" | bc)")
    if [ "$result" -gt 100 ]; then
        result=100
    elif [ "$result" -lt 1 ]; then
        result=1
    fi
    echo $result
}

#######################################
# get_date_value
# Description:
#   Calculate a float value relative to the time difference to the current moment.
# Arguments:
#   $1 : timestamp - The timestamp for which to calculate the relative value.
# Outputs:
#   Float - A value between 0 (long ago) and 10 (now) representing the time difference.
# Returns:
#   None
#######################################
rating::get_date_value() {
    # the timestamp we want a representation of
    local timestamp=$1

    local current_time
    current_time=$(date +%s)
    # Check if the input timestamp is in the future
    if [ "$timestamp" -gt "$current_time" ]; then
        echo "Error: Input date is in the future."
        return 1
    fi

    # the difference between that timestamp and now.
    local time_difference=$((current_time - timestamp))
    # static definitions
    local short_period=360     # 1 minute
    local medium_period=604800 # 1 week
    local long_period=2419200  # 1 month
    local max_return_value=10
    local exponential_factor=2
    # 1 hour or less
    if [ $time_difference -le $short_period ]; then
        echo $max_return_value
    # 1 week or less
    elif [ $time_difference -le $medium_period ]; then
        # Mapping the time difference to a curve between 10 (when $time_difference == $short_period) and 1 (when $time_difference == $medium_period)
        echo "scale=2; e((-$time_difference / $medium_period) * $exponential_factor) * $max_return_value" | bc -l
    else
        # Mapping the time difference to a curve between 1 (when $time_difference == $medium_period) and 0 (when $time_difference >= $long_period)
        echo "scale=2; e((-$time_difference / $long_period) * $exponential_factor)" | bc -l
    fi
}

#######################################
# get_scaled_multiplier
# Description:
#   Calculate a float value relative to the second parameter (0-100).
# Arguments:
#   $1 : value - The original value (between 0 and 100).
#   $2 : input_multiplier - The multiplier to be changed relative to the value.
# Outputs:
#   Float - The calculated multiplier based on the value.
# Returns:
#   None
#######################################
rating::get_scaled_multiplier() {
    # the value is between 0 and 100
    local value=$1
    # the multiplier we want to change relative to the value
    local input_multiplier=$2

    local factor multiplier
    # the factor as a float, how heavy the multiplier should be. (1 = full weight, 0 = no weight)
    factor=$(echo "scale=2; (100 - $value) / 100" | bc)
    # calc and echo the multiplier
    multiplier=$(echo "scale=2; ($input_multiplier * $factor)" | bc)
    # if the input_multiplier is positiv, but the multiplier is negativ, we must change something (idk if it's the right thing)
    echo "scale=2; $multiplier " | bc
}
