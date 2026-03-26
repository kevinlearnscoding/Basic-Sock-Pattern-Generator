#!/bin/sh
#
# Knitting Pattern Generator for Basic Socks
# POSIX-compliant script for generating custom knitting patterns
#

# Set strict mode for better error handling
set -e

# Color codes (will check if terminal supports colors)
if [ -t 1 ]; then
    BOLD='\033[1m'
    RESET='\033[0m'
    HIGHLIGHT='\033[1;32m'
else
    BOLD=''
    RESET=''
    HIGHLIGHT=''
fi

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

clear_screen() {
    clear
}

print_header() {
    clear_screen
    printf "%b=== BASIC SOCK PATTERN GENERATOR ===%b\n\n" "$BOLD" "$RESET"
}

print_section() {
    printf "\n%b>>> %s%b\n" "$HIGHLIGHT" "$1" "$RESET"
}

pause_for_user() {
    printf "\nPress Enter to continue..."
    read -r dummy
}

print_welcome() {
    printf "%b" "============================================\n${HIGHLIGHT}WELCOME TO THE BASIC SOCK PATTERN GENERATOR!${RESET}\n============================================\n\nThis tool will help you create a basic sock knitting pattern based on your measurements, gauge, and design preferences. Follow the prompts to input your information, review the generated pattern, and make any adjustments you'd like before finalizing it.\n\n${BOLD}NOTE: You must knit a gauge swatch before using this tool to ensure accurate stitch counts.${RESET}\n\nNOTE: This tool is for hand-knit socks - if you are looking for machine-knit sock patterns, please check out the resources linked in the README.\n\n${HIGHLIGHT}Let's get started!${RESET}\n" | fold -w 80 -s
}


# ============================================================================
# INPUT FUNCTIONS
# ============================================================================

get_construction_method() {
    print_section "Sock Construction Method"

    printf "How do you want to knit your socks?\n"
    printf "1) Cuff-Down (start at cuff, knit towards toe)\n"
    printf "2) Toe-Up (start at toe, knit towards cuff)\n"
    printf "\nChoice (1-2): "
    read -r method_choice

    case "$method_choice" in
        1)
            CONSTRUCTION_METHOD="cuff-down"
            ;;
        2)
            CONSTRUCTION_METHOD="toe-up"
            ;;
        *)
            CONSTRUCTION_METHOD="cuff-down"
            ;;
    esac
}

get_measurement_units() {
    print_section "Measurement Units"

    printf "Which measurement system do you prefer?\n"
    printf "1) Imperial (inches, yards)\n"
    printf "2) Metric (centimeters, meters)\n"
    printf "\nChoice (1-2): "
    read -r unit_choice

    case "$unit_choice" in
        1)
            MEASUREMENT_UNITS="imperial"
            UNIT_LENGTH="inches"
            UNIT_DISTANCE="yards"
            ;;
        2)
            MEASUREMENT_UNITS="metric"
            UNIT_LENGTH="cm"
            UNIT_DISTANCE="meters"
            ;;
        *)
            MEASUREMENT_UNITS="imperial"
            UNIT_LENGTH="inches"
            UNIT_DISTANCE="yards"
            ;;
    esac
}

# Conversion helper: cm to inches
cm_to_inches() {
    printf "%.1f" "$1" | awk '{printf "%.1f", $1 / 2.54}'
}

# Conversion helper: inches to cm
inches_to_cm() {
    printf "%.1f" "$1" | awk '{printf "%.1f", $1 * 2.54}'
}

get_foot_size() {
    print_section "Foot Size Selection"

    printf "Choose foot size input method:\n"
    printf "1) US Women's Shoe Size\n"
    printf "2) US Men's Shoe Size\n"
    printf "3) Enter foot dimensions\n"
    printf "\nChoice (1-3): "
    read -r size_method

    case "$size_method" in
        1)
            printf "\nUS Women's Shoe Size (5-13): "
            read -r size
            compute_foot_length_from_womens_size "$size"
            ;;
        2)
            printf "\nUS Men's Shoe Size (5-16): "
            read -r size
            compute_foot_length_from_mens_size "$size"
            ;;
        3)
            if [ "$MEASUREMENT_UNITS" = "metric" ]; then
                printf "\nFoot length (cm): "
            else
                printf "\nFoot length (inches): "
            fi
            read -r input_length
            if [ "$MEASUREMENT_UNITS" = "metric" ]; then
                FOOT_LENGTH=$(cm_to_inches "$input_length")
            else
                FOOT_LENGTH="$input_length"
            fi

            if [ "$MEASUREMENT_UNITS" = "metric" ]; then
                printf "Foot circumference (cm): "
            else
                printf "Foot circumference (inches): "
            fi
            read -r input_circumference
            if [ "$MEASUREMENT_UNITS" = "metric" ]; then
                FOOT_CIRCUMFERENCE=$(cm_to_inches "$input_circumference")
            else
                FOOT_CIRCUMFERENCE="$input_circumference"
            fi
            ;;
        *)
            printf "Invalid choice. Using default size 8.\n"
            FOOT_LENGTH=9.5
            FOOT_CIRCUMFERENCE=8
            ;;
    esac
}

compute_foot_length_from_womens_size() {
    # Approximate conversion: Women's size to foot length in inches
    # Formula: 8.125 + (size * 0.3125)
    size=$1
    FOOT_LENGTH=$(printf "%.1f" "$size" | awk '{printf "%.1f", 8.125 + ($1 * 0.3125)}')
    FOOT_CIRCUMFERENCE=$(printf "%.1f" "$size" | awk '{printf "%.1f", 7.5 + ($1 * 0.08)}')
}

compute_foot_length_from_mens_size() {
    # Approximate conversion: Men's size to foot length in inches
    # Formula: 8.375 + (size * 0.3125)
    size=$1
    FOOT_LENGTH=$(printf "%.1f" "$size" | awk '{printf "%.1f", 8.375 + ($1 * 0.3125)}')
    FOOT_CIRCUMFERENCE=$(printf "%.1f" "$size" | awk '{printf "%.1f", 8.0 + ($1 * 0.08)}')
}

get_gauge() {
    print_section "Gauge Information"

    printf "How do you want to enter gauge?\n"
    printf "1) Stitches/rows per inch (standard)\n"
    printf "2) Stitches/rows per custom width\n"
    printf "Choice (1-2): "
    read -r gauge_method

    case "$gauge_method" in
        1)
            printf "\nStitches per inch: "
            read -r GAUGE_SPI
            GAUGE_WIDTH=1
            printf "Rows per inch: "
            read -r GAUGE_RPI
            GAUGE_HEIGHT=1
            ;;
        2)
            printf "\nHow many stitches over your measurement? "
            read -r GAUGE_SPI
            printf "How many inches was your measurement? "
            read -r GAUGE_WIDTH
            printf "How many rows over how your measurement? "
            read -r GAUGE_RPI
            printf "How many inches was your measurement? "
            read -r GAUGE_HEIGHT
            ;;
        *)
            printf "Invalid choice. Using 7 SPI, 10 RPI.\n"
            GAUGE_SPI=7
            GAUGE_WIDTH=1
            GAUGE_RPI=10
            GAUGE_HEIGHT=1
            ;;
    esac
}

get_leg_pattern() {
    print_section "Leg Pattern Choice"

    printf "Choose leg pattern:\n"
    printf "1) Stockinette\n"
    printf "2) Ribbing\n"
    printf "Choice (1-2): "
    read -r leg_choice

    case "$leg_choice" in
        1)
            LEG_PATTERN="stockinette"
            LEG_PATTERN_NOTES="Knit all rounds (stockinette stitch)"
            ;;
        2)
            LEG_PATTERN="ribbing"
            printf "\nRibbing pattern:\n"
            printf "1) 1x1 Ribs (K1, P1)\n"
            printf "2) 2x2 Ribs (K2, P2)\n"
            printf "Choice (1-2): "
            read -r rib_choice
            case "$rib_choice" in
                1)
                    LEG_PATTERN="1x1 ribbing"
                    LEG_PATTERN_NOTES="K1, P1 throughout"
                    ;;
                2)
                    LEG_PATTERN="2x2 ribbing"
                    LEG_PATTERN_NOTES="K2, P2 throughout"
                    ;;
                *)
                    LEG_PATTERN="1x1 ribbing"
                    LEG_PATTERN_NOTES="K1, P1 throughout"
                    ;;
            esac
            ;;
        *)
            LEG_PATTERN="stockinette"
            LEG_PATTERN_NOTES="Knit all rounds (stockinette stitch)"
            ;;
    esac
}

get_toe_type() {
    print_section "Toe Type Selection"

    if [ "$CONSTRUCTION_METHOD" = "toe-up" ]; then
        printf "Choose toe construction (Toe-Up):\n"
        printf "1) Short Row Toe (wrapped stitches)\n"
        printf "2) Wedge Toe with Judy's Magic Cast On\n"
        printf "Choice (1-2): "
        read -r toe_choice

        case "$toe_choice" in
            1)
                TOE_TYPE="short row"
                ;;
            2)
                TOE_TYPE="wedge"
                ;;
            *)
                TOE_TYPE="short row"
                ;;
        esac
    else
        printf "Choose toe construction (Cuff-Down):\n"
        printf "1) Short Row Toe (wrapped stitches)\n"
        printf "2) Wedge Toe (decreases on sides)\n"
        printf "Choice (1-2): "
        read -r toe_choice

        case "$toe_choice" in
            1)
                TOE_TYPE="short row"
                ;;
            2)
                TOE_TYPE="wedge"
                ;;
            *)
                TOE_TYPE="short row"
                ;;
        esac
    fi
}

get_heel_type() {
    print_section "Heel Type Selection"

    if [ "$CONSTRUCTION_METHOD" = "toe-up" ]; then
        printf "Choose heel construction (Toe-Up):\n"
        printf "1) Short Row Heel (wrapped stitches)\n"
        printf "2) Afterthought Heel (knit leg first, pick up after)\n"
        printf "Choice (1-2): "
        read -r heel_choice

        case "$heel_choice" in
            1)
                HEEL_TYPE="short row"
                ;;
            2)
                HEEL_TYPE="afterthought"
                ;;
            *)
                HEEL_TYPE="short row"
                ;;
        esac
    else
        printf "Choose heel construction (Cuff-Down):\n"
        printf "1) Short Row Heel (wrapped stitches)\n"
        printf "2) Afterthought Heel (knit foot first, pick up after)\n"
        printf "3) Heel Flap & Gusset (traditional structure)\n"
        printf "Choice (1-3): "
        read -r heel_choice

        case "$heel_choice" in
            1)
                HEEL_TYPE="short row"
                ;;
            2)
                HEEL_TYPE="afterthought"
                ;;
            3)
                HEEL_TYPE="heel flap and gusset"
                ;;
            *)
                HEEL_TYPE="short row"
                ;;
        esac
    fi
}

get_lengths() {
    print_section "Leg and Cuff Lengths"

    if [ "$CONSTRUCTION_METHOD" = "toe-up" ]; then
        printf "Leg length (from foot to cuff, in %s): " "$UNIT_LENGTH"
    else
        printf "Leg length (from cuff to heel, in %s): " "$UNIT_LENGTH"
    fi
    read -r input_leg_length
    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        LEG_LENGTH=$(cm_to_inches "$input_leg_length")
    else
        LEG_LENGTH="$input_leg_length"
    fi

    printf "Cuff length (in %s): " "$UNIT_LENGTH"
    read -r input_cuff_length
    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        CUFF_LENGTH=$(cm_to_inches "$input_cuff_length")
    else
        CUFF_LENGTH="$input_cuff_length"
    fi
}

get_yarn_info() {
    print_section "Yarn Information (Optional)"

    printf "Yarn brand (leave blank to skip): "
    read -r YARN_BRAND

    printf "Yarn weight (e.g., Fingering, Sport, DK) (leave blank to skip): "
    read -r YARN_WEIGHT

    printf "Yarn color and/or dye lot (leave blank to skip): "
    read -r YARN_COLOR
}

get_needle_info() {
    print_section "Needle Information"

    printf "Needle size - Enter as US size or mm (e.g., '1' or '2.25mm'): "
    read -r NEEDLE_SIZE

    printf "\nNeedle method:\n"
    printf "1) DPNs (Double-Pointed Needles)\n"
    printf "2) Magic Loop\n"
    printf "3) Short Circulars\n"
    printf "Choice (1-3): "
    read -r needle_method

    case "$needle_method" in
        1)
            NEEDLE_METHOD="DPNs (Double-Pointed Needles)"
            ;;
        2)
            NEEDLE_METHOD="Magic Loop"
            ;;
        3)
            NEEDLE_METHOD="Short Circulars"
            ;;
        *)
            NEEDLE_METHOD="DPNs (Double-Pointed Needles)"
            ;;
    esac
}

# ============================================================================
# CALCULATION FUNCTIONS
# ============================================================================

calculate_cast_on() {
    # Cast-on stitches based on foot circumference and gauge
    # Formula: (foot circumference * stitches per inch) / gauge width
    # Use awk to handle decimal gauge values

    CAST_ON=$(printf "%s\n" "$FOOT_CIRCUMFERENCE" | awk -v gs="$GAUGE_SPI" -v gw="$GAUGE_WIDTH" '{printf "%.0f", ($1 * gs) / gw}')

    # Round to nearest even number for easier ribbing patterns
    if [ $((CAST_ON % 2)) -eq 1 ]; then
        CAST_ON=$((CAST_ON - 1))
    fi
}

calculate_leg_rounds() {
    # Number of rounds for the leg
    # Formula: (leg length * rows per inch) / gauge height
    LEG_ROUNDS=$(printf "%.0f" "$LEG_LENGTH" | awk -v rpi="$GAUGE_RPI" -v gh="$GAUGE_HEIGHT" '{printf "%.0f", ($1 * rpi) / gh}')
}

calculate_cuff_rounds() {
    # Number of rounds for the cuff
    # Formula: (cuff length * rows per inch) / gauge height
    CUFF_ROUNDS=$(printf "%.0f" "$CUFF_LENGTH" | awk -v rpi="$GAUGE_RPI" -v gh="$GAUGE_HEIGHT" '{printf "%.0f", ($1 * rpi) / gh}')
}

calculate_toe_stitches() {
    # Toe stitches: approximately 1/3 of cast-on total
    # For short row toe: stitches left unwrapped at start
    # For wedge toe: cast-on stitches for toe portion
    TOE_ROUNDS=$((CAST_ON / 3))

    # Ensure even number for division onto 2 needles
    if [ $((TOE_ROUNDS % 2)) -eq 1 ]; then
        TOE_ROUNDS=$((TOE_ROUNDS - 1))
    fi

    # Each needle gets half
    TOE_PER_NEEDLE=$((TOE_ROUNDS / 2))
}

calculate_heel_stitches() {
    # Heel flap stitches are half of cast-on
    HEEL_STITCHES=$((CAST_ON / 2))

    # For short row and afterthought heels, the unwrapped/remaining stitches
    # should be approximately 1/3 of the heel stitches
    HEEL_WRAP_STITCHES=$((HEEL_STITCHES / 3))

    # Ensure even number for division onto 2 needles
    if [ $((HEEL_WRAP_STITCHES % 2)) -eq 1 ]; then
        HEEL_WRAP_STITCHES=$((HEEL_WRAP_STITCHES - 1))
    fi

    # Each needle gets half
    HEEL_PER_NEEDLE=$((HEEL_WRAP_STITCHES / 2))
}


# ============================================================================
# REVIEW AND CONFIRM FUNCTIONS
# ============================================================================

display_summary() {
    print_header
    print_section "Pattern Summary - Review Your Selections"

    printf "\n%bCONSTRUCTION METHOD:%b\n" "$BOLD" "$RESET"
    printf "  Method: %s\n" "$CONSTRUCTION_METHOD"
    printf "  Measurement units: %s\n" "$MEASUREMENT_UNITS"

    printf "\n%bFOOT MEASUREMENTS:%b\n" "$BOLD" "$RESET"
    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        printf "  Foot length: %.1f cm\n" "$(inches_to_cm "$FOOT_LENGTH")"
        printf "  Foot circumference: %.1f cm\n" "$(inches_to_cm "$FOOT_CIRCUMFERENCE")"
    else
        printf "  Foot length: %.1f inches\n" "$FOOT_LENGTH"
        printf "  Foot circumference: %.1f inches\n" "$FOOT_CIRCUMFERENCE"
    fi

    printf "\n%bGAUGE:%b\n" "$BOLD" "$RESET"
    printf "  Stitch gauge: %.1f stitches per inch\n" "$GAUGE_SPI"
    printf "  Row gauge: %.1f rows per inch\n" "$GAUGE_RPI"

    printf "\n%bPATTERN DETAILS:%b\n" "$BOLD" "$RESET"
    printf "  Leg pattern: %s\n" "$LEG_PATTERN"
    printf "  Toe type: %s\n" "$TOE_TYPE"
    printf "  Heel type: %s\n" "$HEEL_TYPE"

    printf "\n%bLENGTHS:%b\n" "$BOLD" "$RESET"
    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        printf "  Leg length: %.1f cm\n" "$(inches_to_cm "$LEG_LENGTH")"
        printf "  Cuff length: %.1f cm\n" "$(inches_to_cm "$CUFF_LENGTH")"
    else
        printf "  Leg length: %.1f inches\n" "$LEG_LENGTH"
        printf "  Cuff length: %.1f inches\n" "$CUFF_LENGTH"
    fi

    printf "\n%bCALCULATED STITCH COUNTS:%b\n" "$BOLD" "$RESET"
    printf "  Cast-on: %d stitches\n" "$CAST_ON"
    printf "  Leg rounds: %d\n" "$LEG_ROUNDS"
    printf "  Cuff rounds: %d\n" "$CUFF_ROUNDS"
    printf "  Heel stitches: %d\n" "$HEEL_STITCHES"

    # Only show yarn section if user entered any yarn info
    if [ -n "$YARN_BRAND" ] || [ -n "$YARN_WEIGHT" ] || [ -n "$YARN_COLOR" ]; then
        printf "\n%bYARN:%b\n" "$BOLD" "$RESET"
        if [ -n "$YARN_BRAND" ]; then
            printf "  Brand: %s\n" "$YARN_BRAND"
        fi
        if [ -n "$YARN_WEIGHT" ]; then
            printf "  Weight: %s\n" "$YARN_WEIGHT"
        fi
        if [ -n "$YARN_COLOR" ]; then
            printf "  Color/Dye lot: %s\n" "$YARN_COLOR"
        fi
    fi

    printf "\n%bNEEDLES:%b\n" "$BOLD" "$RESET"
    printf "  Size: %s\n" "$NEEDLE_SIZE"
    printf "  Method: %s\n" "$NEEDLE_METHOD"
}

confirm_changes() {
    printf "\n\n%b" "$BOLD"
    printf "Do you want to make any changes? (y/n): "
    printf "%b" "$RESET"
    read -r change_choice

    case "$change_choice" in
        [Yy]*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

edit_selection() {
    print_header
    printf "What would you like to change?\n"
    printf "1) Construction method (cuff-down/toe-up)\n"
    printf "2) Measurement units (imperial/metric)\n"
    printf "3) Foot size\n"
    printf "4) Gauge\n"
    printf "5) Leg pattern\n"
    printf "6) Toe type\n"
    printf "7) Heel type\n"
    printf "8) Lengths (leg and cuff)\n"
    printf "9) Yarn information\n"
    printf "10) Needle information\n"
    printf "11) Return to summary\n"
    printf "\nChoice (1-11): "
    read -r edit_choice

    case "$edit_choice" in
        1)
            get_construction_method
            get_toe_type
            get_heel_type
            ;;
        2)
            get_measurement_units
            ;;
        3)
            get_foot_size
            calculate_cast_on
            calculate_toe_stitches
            calculate_heel_stitches
            ;;
        4)
            get_gauge
            calculate_cast_on
            calculate_leg_rounds
            calculate_cuff_rounds
            ;;
        5)
            get_leg_pattern
            ;;
        6)
            get_toe_type
            ;;
        7)
            get_heel_type
            ;;
        8)
            get_lengths
            calculate_leg_rounds
            calculate_cuff_rounds
            ;;
        9)
            get_yarn_info
            ;;
        10)
            get_needle_info
            ;;
        11)
            return 1
            ;;
        *)
            printf "Invalid choice.\n"
            pause_for_user
            ;;
    esac
    return 0
}

# ============================================================================
# PATTERN GENERATION FUNCTIONS
# ============================================================================

generate_pattern() {
    PATTERN_TEXT=""

    # Format measurements based on units
    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        local foot_len=$(inches_to_cm "$FOOT_LENGTH")
        local foot_circ=$(inches_to_cm "$FOOT_CIRCUMFERENCE")
        local leg_len=$(inches_to_cm "$LEG_LENGTH")
        local cuff_len=$(inches_to_cm "$CUFF_LENGTH")
        local unit_display="cm"
    else
        local foot_len="$(printf "%.1f" "$FOOT_LENGTH")"
        local foot_circ="$(printf "%.1f" "$FOOT_CIRCUMFERENCE")"
        local leg_len="$(printf "%.1f" "$LEG_LENGTH")"
        local cuff_len="$(printf "%.1f" "$CUFF_LENGTH")"
        local unit_display="inches"
    fi

    # Calculate actual gauge per inch (divide by measurement width/height)
    local actual_spi=$(printf "%.1f" "$GAUGE_SPI" | awk -v gw="$GAUGE_WIDTH" '{printf "%.1f", $1 / gw}')
    local actual_rpi=$(printf "%.1f" "$GAUGE_RPI" | awk -v gh="$GAUGE_HEIGHT" '{printf "%.1f", $1 / gh}')

    # Format construction method details (order varies by method)
    local construction_details
    if [ "$CONSTRUCTION_METHOD" = "toe-up" ]; then
        construction_details="$CONSTRUCTION_METHOD ($TOE_TYPE toe, $HEEL_TYPE heel)"
    else
        construction_details="$CONSTRUCTION_METHOD ($HEEL_TYPE heel, $TOE_TYPE toe)"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}================================================================================
CUSTOM SOCK KNITTING PATTERN ($CONSTRUCTION_METHOD)
Generated from Basic Sock Pattern Generator
================================================================================

PROJECT DETAILS
==============="

    # Add yarn info if user provided any
    if [ -n "$YARN_BRAND" ] || [ -n "$YARN_WEIGHT" ] || [ -n "$YARN_COLOR" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
Yarn: $YARN_BRAND, $YARN_WEIGHT, Color: $YARN_COLOR"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
Needle Size: $NEEDLE_SIZE
Needle Method: $NEEDLE_METHOD

Construction Method: $construction_details

MEASUREMENTS & GAUGE
====================
Foot Length: $foot_len $unit_display
Foot Circumference: $foot_circ $unit_display
Leg Length: $leg_len $unit_display
Cuff Length: $cuff_len $unit_display

Gauge: $actual_spi stitches and $actual_rpi rows per inch

STITCH COUNTS
==============
Cast on: $CAST_ON stitches
Divide evenly onto needle method of choice.

Cuff rounds: $CUFF_ROUNDS
Leg rounds: $LEG_ROUNDS
Heel stitches: $HEEL_STITCHES
Toe starting stitches: $TOE_ROUNDS

PATTERN CONSTRUCTION
====================

"

    # Different structure for toe-up vs cuff-down
    if [ "$CONSTRUCTION_METHOD" = "toe-up" ]; then
        # TOE-UP STRUCTURE: TOE → FOOT → HEEL → LEG → CUFF → (optional HEEL if afterthought)
        case "$TOE_TYPE" in
            "short row")
                PATTERN_TEXT="${PATTERN_TEXT}TOE SECTION (SHORT ROW METHOD) - START HERE
--------
Initial Cast-On:
- Cast on $TOE_ROUNDS stitches total (approximately 1/3 of your finished stitch count)
- Divide: $TOE_PER_NEEDLE stitches on each needle
- Divide evenly onto your chosen needles
- Join in the round carefully

Short Rows:
- Round 1: Knit to last 2 stitches, W&T (wrap and turn)
- Round 2: Purl to last 2 stitches, W&T
- Each round, work to 2 stitches before the gap, W&T
- Continue until only a few stitches remain unwrapped ($HEEL_WRAP_STITCHES stitches unwrapped)
- Pick up wraps and knit them together with their stitches
- You now have approximately $TOE_ROUNDS stitches

Toe Shaping:
- Next, increase evenly to $CAST_ON stitches:
  - Round 1: K1, M1, knit to last 2 stitches, M1, K1 (on each side)
  - Continue increasing until you have $CAST_ON stitches
- Make increases every other round until at full stitch count

"
                ;;
            "wedge")
                PATTERN_TEXT="${PATTERN_TEXT}TOE SECTION (WEDGE TOE WITH JUDY'S MAGIC CAST ON) - START HERE
--------
Setup with Judy's Magic Cast On:
- Use Judy's Magic method or your preferred provisional cast-on
- Cast on $TOE_ROUNDS stitches total (approximately 1/3 of your finished stitch count)
  - $TOE_PER_NEEDLE stitches on top needle
  - $TOE_PER_NEEDLE stitches on bottom needle
- This creates two parallel rows of stitches ready to join

Initial Rounds:
- Pick up $TOE_PER_NEEDLE stitches from the bottom strand
- Now you have $CAST_ON stitches total (half from above, half from below)
- Join in the round carefully

Wedge Toe Increases:
- Round 1: Knit all stitches
- Round 2: K1, M1, knit to last 2 stitches, M1, K1 (on each side)
- Repeat rounds 1-2, working increases every other round
- Continue until you have $CAST_ON stitches total

"
                ;;
        esac

        # FOOT SECTION (for toe-up socks, after toe shaping)
        PATTERN_TEXT="${PATTERN_TEXT}FOOT SECTION
--------
- Continue in stockinette stitch for approximately $foot_len $unit_display
- Foot should measure from toe approximately $foot_len $unit_display

"

        # HEEL PLACEMENT/SETUP (for toe-up socks, before leg)
        case "$HEEL_TYPE" in
            "short row")
                PATTERN_TEXT="${PATTERN_TEXT}HEEL SECTION (SHORT ROW METHOD)
--------
Heel is worked back and forth on $HEEL_STITCHES stitches (half of cast-on).

Setup:
- Knit $((CAST_ON / 2)) stitches, turn (leaving remaining stitches on hold for leg)

Heel Flap:
- Work back and forth on $HEEL_STITCHES stitches using slip stitch selvedge
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat rows 1-2 for approximately $((HEEL_STITCHES * 2 / 3)) rows
- Heel flap should be roughly square

Short Row Turning:
- Work $((HEEL_STITCHES - 1)) stitches, W&T (wrap and turn)
- Work to 1 stitch before the gap, W&T
- Continue until $HEEL_WRAP_STITCHES stitches remain unwrapped (approximately 1/3 of heel stitches: $HEEL_WRAP_STITCHES total, $HEEL_PER_NEEDLE per needle)
- Pick up wraps and work them together with their stitches

Reshaping:
- Pick up stitches along the side of the heel flap
- Continue around to the leg stitches on hold
- Pick up stitches on the other side of heel flap
- You should now have $CAST_ON stitches ready for leg

"
                ;;
            "afterthought")
                PATTERN_TEXT="${PATTERN_TEXT}HEEL PLACEMENT (AFTERTHOUGHT METHOD)
--------
Setting up for afterthought heel - you'll knit the heel after finishing the cuff.

Heel Marker:
- Knit across $((CAST_ON / 2)) stitches (half the total)
- Replace these $HEEL_STITCHES stitches with waste yarn
  (Knit 2 rows with waste yarn over these stitches, return yarn to main ball)
- Continue knitting the remaining $((CAST_ON / 2)) stitches with main yarn

The waste yarn marker now holds your future heel stitches.

"
                ;;
        esac

        # LEG SECTION (for toe-up socks)
        PATTERN_TEXT="${PATTERN_TEXT}LEG SECTION ($leg_len $unit_display / $LEG_ROUNDS rounds)
-------
Pattern: $LEG_PATTERN

Instructions:
- $LEG_PATTERN_NOTES
- Continue for $LEG_ROUNDS rounds
- Leg should measure approximately $leg_len $unit_display from foot

"

        # CUFF SECTION (for toe-up socks)
        PATTERN_TEXT="${PATTERN_TEXT}CUFF SECTION ($cuff_len $unit_display / $CUFF_ROUNDS rounds)
-------
Ribbing pattern: $LEG_PATTERN_NOTES

Instructions:
- Work $CUFF_ROUNDS rounds of $LEG_PATTERN
- Bind off loosely in pattern

"

        # AFTERTHOUGHT HEEL INSTRUCTIONS (if applicable, at the very end for toe-up)
        if [ "$HEEL_TYPE" = "afterthought" ]; then
            PATTERN_TEXT="${PATTERN_TEXT}HEEL SECTION (AFTERTHOUGHT - work after cuff is complete)
--------
After finishing and binding off the cuff:

Setup for Heel:
- Carefully remove the waste yarn from your heel marker (placed during the heel placement section)
- Pick up $HEEL_STITCHES stitches from below the waste yarn
- Pick up $HEEL_STITCHES stitches from above the waste yarn
- You now have $HEEL_STITCHES stitches for your heel

Heel Flap:
- Work back and forth on these $HEEL_STITCHES stitches using slip stitch selvedge
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat rows 1-2 for approximately $((HEEL_STITCHES * 2 / 3)) rows
- Heel flap should be roughly square

Short Row Heel Turning:
- Work $((HEEL_STITCHES - 1)) stitches, W&T (wrap and turn)
- Work to 1 stitch before the gap, W&T
- Continue until $HEEL_WRAP_STITCHES stitches remain unwrapped (approximately 1/3 of heel stitches: $HEEL_WRAP_STITCHES total, $HEEL_PER_NEEDLE per needle)
- Pick up wraps with their stitches and knit together
- Graft or bind off remaining stitches

"
        fi

    else
        # CUFF-DOWN STRUCTURE: CUFF → LEG → HEEL → FOOT → TOE → (optional HEEL if afterthought)
        PATTERN_TEXT="${PATTERN_TEXT}CUFF SECTION ($cuff_len $unit_display / $CUFF_ROUNDS rounds) - START HERE
-------
Ribbing pattern: $LEG_PATTERN_NOTES

Instructions:
- Cast on $CAST_ON stitches loosely using long-tail cast-on
- Join in the round, being careful not to twist
- Work $CUFF_ROUNDS rounds of $LEG_PATTERN
- Tip: Keep first few stitches loose to avoid tight cuff

"

        # LEG SECTION (for cuff-down socks)
        PATTERN_TEXT="${PATTERN_TEXT}LEG SECTION ($leg_len $unit_display / $LEG_ROUNDS rounds)
-------
Pattern: $LEG_PATTERN

Instructions:
- $LEG_PATTERN_NOTES
- Continue for $LEG_ROUNDS rounds
- Leg should measure approximately $leg_len $unit_display from cuff

"

        # HEEL PLACEMENT/SETUP (for cuff-down socks)
        case "$HEEL_TYPE" in
            "short row")
                PATTERN_TEXT="${PATTERN_TEXT}HEEL SECTION (SHORT ROW METHOD)
--------
Heel is worked back and forth on $HEEL_STITCHES stitches (half of cast-on).

Setup:
- Knit $((CAST_ON / 2)) stitches, turn (leaving remaining stitches on hold for foot)

Heel Flap:
- Work back and forth on $HEEL_STITCHES stitches using slip stitch selvedge
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat rows 1-2 for approximately $((HEEL_STITCHES * 2 / 3)) rows
- Heel flap should be roughly square

Short Row Turning:
- Work $((HEEL_STITCHES - 1)) stitches, W&T (wrap and turn)
- Work to 1 stitch before the gap, W&T
- Continue until $HEEL_WRAP_STITCHES stitches remain unwrapped (approximately 1/3 of heel stitches: $HEEL_WRAP_STITCHES total, $HEEL_PER_NEEDLE per needle)
- Pick up wraps and work them together with their stitches

Reshaping:
- Pick up stitches along the side of the heel flap
- Continue around to the foot stitches on hold
- Pick up stitches on the other side of heel flap
- You should now have $CAST_ON stitches ready for foot

"
                ;;
            "afterthought")
                PATTERN_TEXT="${PATTERN_TEXT}HEEL PLACEMENT (AFTERTHOUGHT METHOD)
--------
Setting up for afterthought heel - you'll knit the heel after completing the foot and toe.

Heel Marker:
- Knit across $((CAST_ON / 2)) stitches (half the total)
- Replace these $HEEL_STITCHES stitches with waste yarn
  (Knit 2 rows with waste yarn over these stitches, return yarn to main ball)
- Continue knitting the remaining $((CAST_ON / 2)) stitches with main yarn

The waste yarn marker now holds your future heel stitches.

"
                ;;
            "heel flap and gusset")
                PATTERN_TEXT="${PATTERN_TEXT}HEEL SECTION (HEEL FLAP & GUSSET - TRADITIONAL METHOD)
--------
This traditional heel creates a well-fitted heel with a gusset.

Setup:
- Work across $((CAST_ON / 2)) stitches for heel (slip remaining stitches to holder for foot)

Heel Flap:
- Work back and forth on $HEEL_STITCHES stitches
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat rows 1-2 for approximately $((HEEL_STITCHES * 2 / 3)) rows (aim for square)

Heel Turn (Short Rows):
- Work $((HEEL_STITCHES - 1)) stitches, W&T (wrap and turn)
- Pull yarn to front, skip next stitch, slip it back, return yarn to back
- Purl back to 1 stitch before gap, W&T
- Continue working toward center, working wraps with stitches
- Until you have worked all but a few stitches

Picking Up the Gusset:
- Pick up $((HEEL_STITCHES / 2 + 2)) stitches along one side of heel flap
- Knit across heel stitches
- Pick up $((HEEL_STITCHES / 2 + 2)) stitches along other side
- You now have more than $CAST_ON stitches (will decrease back down)

Gusset Decreases:
- Round 1: Knit around
- Round 2 (decrease round):
  - Knit to last 3 stitches before center foot stitches, K2tog, K1
  - Knit across foot stitches
  - K1, ssk to decrease other gusset side
- Continue decreasing every other round until back to $CAST_ON stitches

"
                ;;
        esac

        # FOOT SECTION (for cuff-down socks, after heel)
        PATTERN_TEXT="${PATTERN_TEXT}FOOT SECTION
--------
- Continue in stockinette stitch until sock measures approximately $foot_len $unit_display from back of heel

"

        # TOE SECTION (for cuff-down socks, after foot)
        case "$TOE_TYPE" in
            "short row")
                PATTERN_TEXT="${PATTERN_TEXT}TOE SECTION (SHORT ROW METHOD)
------
Short row toe creates a rounded point and works well with structured feet.

Setup:
- Knit to middle of sole with $CAST_ON stitches
- Begin short rows at center of foot

Toe Decreases:
- Turn work and work back across
- Each row, work to 1-2 stitches before the gap
- Wrap stitch and turn
- Continue until $TOE_ROUNDS stitches remain unwrapped (approximately 1/3 of total stitches)
  - Total remaining stitches: $TOE_ROUNDS ($TOE_PER_NEEDLE per needle)

Finishing:
- Graft remaining stitches using Kitchener stitch
- Or bind off if stitches cannot be grafted

"
                ;;
            "wedge")
                PATTERN_TEXT="${PATTERN_TEXT}TOE SECTION (WEDGE METHOD)
------
Wedge toe uses strategic decreases to create a tapered toe.

Setup:
- Work in stockinette until you need to begin toe decreases
- Divide stitches into 4 sections: right top, left top, right sole, left sole

Decrease Rounds:
- Round 1:
  * Right top: Knit to last 3, K2tog, K1
  * Left top: K1, ssk, knit to end
  * Right sole: Knit to last 3, K2tog, K1
  * Left sole: K1, ssk, knit to end
- Round 2: Knit all stitches
- Alternate decrease rounds and plain knit rounds

Continue until approximately $TOE_ROUNDS stitches remain (approximately 1/3 of total stitches):
  - Target stitches: $TOE_ROUNDS ($TOE_PER_NEEDLE per needle)
- Cut yarn leaving 6-inch tail
- Thread through remaining stitches
- Pull tight and secure

"
                ;;
        esac

        # AFTERTHOUGHT HEEL INSTRUCTIONS (if applicable, at the very end for cuff-down)
        if [ "$HEEL_TYPE" = "afterthought" ]; then
            PATTERN_TEXT="${PATTERN_TEXT}HEEL SECTION (AFTERTHOUGHT - work after toe is complete)
--------
After finishing and grafting/binding off the toe:

Setup for Heel:
- Carefully remove the waste yarn from your heel marker (placed during the heel placement section)
- Pick up $HEEL_STITCHES stitches from below the waste yarn
- Pick up $HEEL_STITCHES stitches from above the waste yarn
- You now have $HEEL_STITCHES stitches for your heel

Heel Flap:
- Work back and forth on these $HEEL_STITCHES stitches using slip stitch selvedge
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat rows 1-2 for approximately $((HEEL_STITCHES * 2 / 3)) rows
- Heel flap should be roughly square

Short Row Heel Turning:
- Work $((HEEL_STITCHES - 1)) stitches, W&T (wrap and turn)
- Work to 1 stitch before the gap, W&T
- Continue until $HEEL_WRAP_STITCHES stitches remain unwrapped (approximately 1/3 of heel stitches: $HEEL_WRAP_STITCHES total, $HEEL_PER_NEEDLE per needle)
- Pick up wraps with their stitches and knit together
- Graft or bind off remaining stitches

"
        fi
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
FINISHING INSTRUCTIONS
======================
1. Weave in all ends using yarn needle
2. Wet block if desired for better fit
3. Let dry flat or on sock blocker
4. Try on with shoes you plan to wear

================================================================================
Pattern generated by Basic Sock Pattern Generator
$construction_details
================================================================================"

}

display_pattern() {
    clear_screen
    printf "%s\n" "$PATTERN_TEXT"
}

save_pattern() {
    printf "\n\nEnter filename for pattern (without extension): "
    read -r filename

    if [ -z "$filename" ]; then
        filename="sock_pattern"
    fi

    filename="${filename}.txt"

    printf "%s\n" "$PATTERN_TEXT" > "$filename"
    printf "\nPattern saved to: %s\n" "$filename"
}

output_options() {
    print_header
    print_section "Generated Pattern"

    printf "\nWhat would you like to do with your pattern?\n"
    printf "1) Display pattern on screen\n"
    printf "2) Save pattern to file\n"
    printf "3) Both display and save\n"
    printf "4) Done (exit)\n"
    printf "\nChoice (1-4): "
    read -r output_choice

    case "$output_choice" in
        1)
            display_pattern
            pause_for_user
            ;;
        2)
            save_pattern
            pause_for_user
            ;;
        3)
            display_pattern
            pause_for_user
            save_pattern
            ;;
        4)
            return 1
            ;;
        *)
            printf "Invalid choice.\n"
            pause_for_user
            output_options
            return 0
            ;;
    esac
    return 0
}

# ============================================================================
# MAIN FLOW
# ============================================================================

main() {
    # Display welcome message
    clear_screen
    print_welcome
    pause_for_user

    # Gather all input
    get_construction_method
    get_measurement_units
    get_foot_size
    get_gauge
    get_leg_pattern
    get_toe_type
    get_heel_type
    get_lengths
    get_yarn_info
    get_needle_info

    # Calculate values
    calculate_cast_on
    calculate_leg_rounds
    calculate_cuff_rounds
    calculate_toe_stitches
    calculate_heel_stitches

    # Review and allow changes
    while true; do
        display_summary
        if ! confirm_changes; then
            break
        fi
        while edit_selection; do
            calculate_cast_on
            calculate_leg_rounds
            calculate_cuff_rounds
            calculate_toe_stitches
            calculate_heel_stitches
            display_summary
            if ! confirm_changes; then
                break 2
            fi
        done
    done

    # Generate and display pattern
    generate_pattern

    while output_options; do
        :
    done

    print_header
    printf "Thank you for using the Basic Sock Pattern Generator!\n"
    printf "Happy knitting!\n\n"
}

# Run main function
main "$@"
