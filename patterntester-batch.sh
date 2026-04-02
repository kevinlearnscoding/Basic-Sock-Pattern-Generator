#!/bin/bash

TARGET_SCRIPT="./Double_bed_generator.sh"

# Function to get random float for specific fields
rand_float() {
  awk -v min=$1 -v max=$2 'BEGIN{srand(); printf "%.2f\n", min+rand()*(max-min)}'
}

for i in {1..50}; do
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
            1) echo $((5 + RANDOM % 4)); echo $((7 + RANDOM % 4)) ;;
            2) echo $((26 + RANDOM % 8)); echo $((30 + RANDOM % 6)) ;;
            3)
                STITCH_COUNT=$((26 + RANDOM % 8))
                STITCHES_PER_INCH=$((5 + RANDOM % 4))
                echo $STITCH_COUNT
                awk -v count="$STITCH_COUNT" -v spi="$STITCHES_PER_INCH" 'BEGIN { printf "%.2f\n", count / spi }'
                ROW_COUNT=$((30 + RANDOM % 6))
                ROWS_PER_INCH=$((7 + RANDOM % 4))
                echo $ROW_COUNT
                awk -v count="$ROW_COUNT" -v rpi="$ROWS_PER_INCH" 'BEGIN { printf "%.2f\n", count / rpi }'
                ;;
            4) echo $((26 + RANDOM % 8)); echo $((30 + RANDOM % 6)) ;;
            5)
                STITCH_COUNT=$((26 + RANDOM % 8))
                STITCHES_PER_INCH=$((5 + RANDOM % 4))
                echo $STITCH_COUNT
                awk -v count="$STITCH_COUNT" -v spi="$STITCHES_PER_INCH" 'BEGIN { printf "%.2f\n", count / spi * 2.54 }'
                ROW_COUNT=$((30 + RANDOM % 6))
                ROWS_PER_INCH=$((7 + RANDOM % 4))
                echo $ROW_COUNT
                awk -v count="$ROW_COUNT" -v rpi="$ROWS_PER_INCH" 'BEGIN { printf "%.2f\n", count / rpi * 2.54 }'
                ;;
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
        echo "$i" # Counter value
        echo ""
        echo "5"
    ) | bash "$TARGET_SCRIPT"

    echo "--- Run #$i Finished ---"
done
