#!/bin/bash

TARGET_SCRIPT="./Double_bed_generator.sh"

# Function to get random float for specific fields
rand_float() {
  awk -v min=$1 -v max=$2 'BEGIN{srand(); printf "%.2f\n", min+rand()*(max-min)}'
}

    echo "--- Starting Test Run #$i ---"
    (
        echo "" # Initial Enter
        
        UNIT=$((1 + RANDOM % 2))
        echo $UNIT
        
        SIZE=$((1 + RANDOM % 3))
        echo $SIZE

        # Shoe Logic
        if [ $SIZE -eq 1 ]; then
            echo $((5 + RANDOM % 9))
        elif [ $SIZE -eq 2 ]; then
            echo $((5 + RANDOM % 12))
        elif [ $SIZE -eq 3 ]; then
            if [ $UNIT -eq 2 ]; then
                rand_float 22 30   # foot length in cm
                rand_float 20 28   # foot circumference in cm
            else
                rand_float 8.5 12  # foot length in inches
                rand_float 7.5 11   # foot circumference in inches
            fi
        fi

        # Gauge Logic
        GAUGE=$((1 + RANDOM % 5))
        echo $GAUGE
        case $GAUGE in
            1) echo $((5 + RANDOM % 5)); echo $((7 + RANDOM % 7)) ;;
            2) echo $((25 + RANDOM % 11)); echo $((34 + RANDOM % 13)) ;;
            3) echo $((25 + RANDOM % 11)); rand_float 3.5 4.25; echo $((34 + RANDOM % 13)); rand_float 3.5 4.25 ;;
            4) echo $((25 + RANDOM % 11)); echo $((34 + RANDOM % 13)) ;;
            5) echo $((25 + RANDOM % 11)); rand_float 3.5 4.25; echo $((34 + RANDOM % 13)); rand_float 3.5 4.25 ;;
        esac

        # Leg/Cuff
        LEG=$((1 + RANDOM % 2))
        echo $LEG
        if [ $LEG -eq 2 ]; then
            echo $((1 + RANDOM % 2)) # leg ribbing pattern (1-2)
            echo $((1 + RANDOM % 2)) # transfer placement (1-2)
            echo $((1 + RANDOM % 2)) # cuff ribbing pattern (1-2)
        else
            CUFF_FINISH=$((1 + RANDOM % 3))
            echo $CUFF_FINISH          # cuff finish (1-3)
            if [ $CUFF_FINISH -ne 1 ]; then
                echo $((1 + RANDOM % 2)) # transfer placement (1-2)
            fi
        fi

        echo $((1 + RANDOM % 2)) # toe
        echo $((1 + RANDOM % 2)) # heel

        # Leg & Cuff Lengths
        if [ $UNIT -eq 1 ]; then
            rand_float 0.5 11   # leglength
            rand_float 0.5 2.5  # cufflength
        else
            echo $((1 + RANDOM % 28)) # leglength2
            echo $((1 + RANDOM % 4))  # cufflength2
        fi

        echo ""; echo ""; echo "" # Triple enter

        MAIN=$((5 + RANDOM % 6))
        echo $MAIN
        echo $((MAIN - 2))

        # Static outputs
        echo "n"
        echo "2"
        echo "2"
        echo "/Users/kevinduncan/Documents/Coding Projects/Basic-Sock-Pattern-Generator/Tests/"
        echo "single" # Counter value
        echo ""
        echo "5"
    ) | bash "$TARGET_SCRIPT"

    echo "--- Run #$i Finished ---"
