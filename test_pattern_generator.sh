#!/bin/sh
#
# Automated Test Script for Sock Pattern Generator
# Demonstrates pattern generation without interactive input
#

# Source the main script but don't run main()
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/sock_pattern_generator.sh"

# Test Case 1: Women's Size 8 with Fingering Weight
test_womens_size_8() {
    printf "\n=== TEST CASE 1: Women's Size 8 ===\n"

    # Set inputs as if user entered them
    FOOT_LENGTH=9.5
    FOOT_CIRCUMFERENCE=8
    GAUGE_SPI=7
    GAUGE_RPI=10
    GAUGE_WIDTH=1
    GAUGE_HEIGHT=1
    LEG_PATTERN="stockinette"
    LEG_PATTERN_NOTES="Knit all rounds (stockinette stitch)"
    TOE_TYPE="wedge"
    HEEL_TYPE="short row"
    LEG_LENGTH=8
    CUFF_LENGTH=2
    YARN_BRAND="Patons"
    YARN_WEIGHT="Fingering"
    YARN_COLOR="Purple 123"
    YARN_YARDAGE=400
    NEEDLE_SIZE="US 1"
    NEEDLE_METHOD="Magic Loop"

    # Run calculations
    calculate_cast_on
    calculate_leg_rounds
    calculate_cuff_rounds
    calculate_toe_stitches
    calculate_heel_stitches
    calculate_yardage_needed

    # Display results
    printf "Cast on: %d stitches\n" "$CAST_ON"
    printf "Leg rounds: %d\n" "$LEG_ROUNDS"
    printf "Cuff rounds: %d\n" "$CUFF_ROUNDS"
    printf "Heel stitches: %d\n" "$HEEL_STITCHES"
    printf "Estimated yardage: %d yards\n" "$ESTIMATED_YARDAGE"
    printf "Available yardage: %d yards\n" "$YARN_YARDAGE"

    if [ "$ESTIMATED_YARDAGE" -le "$YARN_YARDAGE" ]; then
        printf "✓ Sufficient yarn available\n"
    else
        printf "⚠ Warning: May need more yarn\n"
    fi
}

# Test Case 2: Men's Size 10 with DK Weight
test_mens_size_10() {
    printf "\n=== TEST CASE 2: Men's Size 10 ===\n"

    FOOT_LENGTH=10.8
    FOOT_CIRCUMFERENCE=8.8
    GAUGE_SPI=5
    GAUGE_RPI=6.5
    GAUGE_WIDTH=1
    GAUGE_HEIGHT=1
    LEG_PATTERN="2x2 ribbing"
    LEG_PATTERN_NOTES="K2, P2 throughout"
    TOE_TYPE="short row"
    HEEL_TYPE="afterthought"
    LEG_LENGTH=9
    CUFF_LENGTH=2.5
    YARN_BRAND="Merino DK"
    YARN_WEIGHT="DK"
    YARN_COLOR="Navy Blue"
    YARN_YARDAGE=500
    NEEDLE_SIZE="US 4"
    NEEDLE_METHOD="Short Circulars"

    calculate_cast_on
    calculate_leg_rounds
    calculate_cuff_rounds
    calculate_toe_stitches
    calculate_heel_stitches
    calculate_yardage_needed

    printf "Cast on: %d stitches\n" "$CAST_ON"
    printf "Leg rounds: %d\n" "$LEG_ROUNDS"
    printf "Cuff rounds: %d\n" "$CUFF_ROUNDS"
    printf "Heel stitches: %d\n" "$HEEL_STITCHES"
    printf "Estimated yardage: %d yards\n" "$ESTIMATED_YARDAGE"
    printf "Available yardage: %d yards\n" "$YARN_YARDAGE"

    if [ "$ESTIMATED_YARDAGE" -le "$YARN_YARDAGE" ]; then
        printf "✓ Sufficient yarn available\n"
    else
        printf "⚠ Warning: May need more yarn\n"
    fi
}

# Test Case 3: Child's Size with Custom Gauge
test_child_custom_gauge() {
    printf "\n=== TEST CASE 3: Child's Sock with Custom Gauge ===\n"

    FOOT_LENGTH=7.5
    FOOT_CIRCUMFERENCE=6.5
    GAUGE_SPI=8
    GAUGE_WIDTH=2
    GAUGE_RPI=11
    GAUGE_HEIGHT=2
    LEG_PATTERN="1x1 ribbing"
    LEG_PATTERN_NOTES="K1, P1 throughout"
    TOE_TYPE="wedge"
    HEEL_TYPE="short row"
    LEG_LENGTH=5
    CUFF_LENGTH=1.5
    YARN_BRAND="Red Heart"
    YARN_WEIGHT="Sport"
    YARN_COLOR="Red"
    YARN_YARDAGE=300
    NEEDLE_SIZE="US 2"
    NEEDLE_METHOD="DPNs"

    calculate_cast_on
    calculate_leg_rounds
    calculate_cuff_rounds
    calculate_toe_stitches
    calculate_heel_stitches
    calculate_yardage_needed

    printf "Cast on: %d stitches\n" "$CAST_ON"
    printf "Leg rounds: %d\n" "$LEG_ROUNDS"
    printf "Cuff rounds: %d\n" "$CUFF_ROUNDS"
    printf "Heel stitches: %d\n" "$HEEL_STITCHES"
    printf "Estimated yardage: %d yards\n" "$ESTIMATED_YARDAGE"
    printf "Available yardage: %d yards\n" "$YARN_YARDAGE"

    if [ "$ESTIMATED_YARDAGE" -le "$YARN_YARDAGE" ]; then
        printf "✓ Sufficient yarn available\n"
    else
        printf "⚠ Warning: May need more yarn\n"
    fi
}

# Test Case 4: Generate and Save Full Pattern
test_generate_pattern() {
    printf "\n=== TEST CASE 4: Generate Full Pattern ===\n"

    FOOT_LENGTH=9.5
    FOOT_CIRCUMFERENCE=8
    GAUGE_SPI=7
    GAUGE_RPI=10
    GAUGE_WIDTH=1
    GAUGE_HEIGHT=1
    LEG_PATTERN="stockinette"
    LEG_PATTERN_NOTES="Knit all rounds (stockinette stitch)"
    TOE_TYPE="wedge"
    HEEL_TYPE="short row"
    LEG_LENGTH=8
    CUFF_LENGTH=2
    YARN_BRAND="Test Yarn"
    YARN_WEIGHT="Fingering"
    YARN_COLOR="Test Color"
    YARN_YARDAGE=400
    NEEDLE_SIZE="US 1"
    NEEDLE_METHOD="Magic Loop"
    CAST_ON=56
    LEG_ROUNDS=80
    CUFF_ROUNDS=20
    HEEL_STITCHES=28
    TOE_ROUNDS=14
    ESTIMATED_YARDAGE=75

    generate_pattern

    # Check that pattern contains expected sections
    if echo "$PATTERN_TEXT" | grep -q "CAST ON SECTION"; then
        printf "✓ Pattern contains CAST ON SECTION\n"
    else
        printf "✗ Pattern missing CAST ON SECTION\n"
    fi

    if echo "$PATTERN_TEXT" | grep -q "Cast on:"; then
        printf "✓ Pattern contains cast-on count\n"
    else
        printf "✗ Pattern missing cast-on count\n"
    fi

    if echo "$PATTERN_TEXT" | grep -q "Test Yarn"; then
        printf "✓ Pattern contains yarn brand\n"
    else
        printf "✗ Pattern missing yarn brand\n"
    fi

    # Save test pattern
    PATTERN_FILE="/tmp/sock_test_pattern.txt"
    printf "%s\n" "$PATTERN_TEXT" > "$PATTERN_FILE"
    if [ -f "$PATTERN_FILE" ]; then
        printf "✓ Pattern saved to %s\n" "$PATTERN_FILE"
        printf "  Pattern size: %d lines\n" "$(wc -l < "$PATTERN_FILE")"
    else
        printf "✗ Failed to save pattern\n"
    fi
}

# Run all tests
printf "\n========================================\n"
printf "SOCK PATTERN GENERATOR - TEST SUITE\n"
printf "========================================\n"

test_womens_size_8
test_mens_size_10
test_child_custom_gauge
test_generate_pattern

printf "\n========================================\n"
printf "TEST SUITE COMPLETE\n"
printf "========================================\n"
