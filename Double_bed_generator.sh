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
    printf "%b=== DOUBLE BED SOCK PATTERN GENERATOR ===%b\n\n" "$BOLD" "$RESET"
}

print_section() {
    printf "\n%b>>> %s%b\n" "$HIGHLIGHT" "$1" "$RESET"
}

pause_for_user() {
    printf "\nPress Enter to continue..."
    read -r dummy
}

printf_wrapped() {
    # Prints text with 80-character line wrapping
    printf "%b" "$@" | fold -w 80 -s
}

print_welcome() {
    printf "%b" "============================================\n${HIGHLIGHT}WELCOME TO THE DOUBLE BED SOCK GENERATOR!${RESET}\n============================================\n\nThis tool generates machine-agnostic instructions for a standard-gauge double bed sock workflow using your measurements, gauge, and design choices.\n\n${BOLD}NOTE: Knit a gauge swatch on your machine before using this tool to ensure accurate stitch and row counts.${RESET}\n\nThis script is designed for domestic double bed machines and uses neutral terminology that maps across brands.\n\n${HIGHLIGHT}Let's get started!${RESET}\n" | fold -w 80 -s
}


# ============================================================================
# INPUT FUNCTIONS
# ============================================================================

set_construction_method() {
    CONSTRUCTION_METHOD="toe-up"
}

get_measurement_units() {
    print_section "Measurement Units"

    printf "Which measurement system do you prefer?\n"
    printf "1) Imperial (inches)\n"
    printf "2) Metric (centimeters)\n"
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
            SHOE_SIZE="$size"
            SHOE_SIZE_TYPE="Women's"
            compute_foot_length_from_womens_size "$size"
            ;;
        2)
            printf "\nUS Men's Shoe Size (5-16): "
            read -r size
            SHOE_SIZE="$size"
            SHOE_SIZE_TYPE="Men's"
            compute_foot_length_from_mens_size "$size"
            ;;
        3)
            SHOE_SIZE=""
            SHOE_SIZE_TYPE=""
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
            SHOE_SIZE=""
            SHOE_SIZE_TYPE=""
            ;;
    esac
}

compute_foot_length_from_womens_size() {
    # Approximate conversion: Women's size to foot length in inches
    # Formula: ((US Size + 21) / 3) * 0.9 for 90% (negative ease for proper fit)
    size=$1
    FOOT_LENGTH=$(printf "%.1f" "$size" | awk '{printf "%.1f", (($1 + 21) / 3) * 0.9}')
    FOOT_CIRCUMFERENCE=$(printf "%.1f" "$size" | awk '{printf "%.1f", 7.5 + ($1 * 0.08)}')
}

compute_foot_length_from_mens_size() {
    # Approximate conversion: Men's size to foot length in inches
    # Formula: ((US Size + 22) / 3) * 0.9 for 90% (negative ease for proper fit)
    size=$1
    FOOT_LENGTH=$(printf "%.1f" "$size" | awk '{printf "%.1f", (($1 + 22) / 3) * 0.9}')
    FOOT_CIRCUMFERENCE=$(printf "%.1f" "$size" | awk '{printf "%.1f", 8.0 + ($1 * 0.08)}')
}

get_gauge() {
    print_section "Gauge Information"

    printf "How do you want to enter gauge?\n"
    printf "1) Stitches/rows per inch (standard)\n"
    printf "2) Stitches/rows per 4 inches (common for swatches)\n"
    printf "3) Stitches/rows over customer number of inches\n"
    printf "4) Stitches/rows per 10 cm (metric swatch)\n"
    printf "5) Stitches/rows over custom number of cm\n"
    printf "Choice (1-5): "
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
            printf "\nStitches per 4 inches: "
            read -r GAUGE_SPI
            GAUGE_WIDTH=4
            printf "Rows per 4 inches: "
            read -r GAUGE_RPI
            GAUGE_HEIGHT=4
            ;;
        3)
            printf "\nHow many stitches over your measurement? "
            read -r GAUGE_SPI
            printf "How many inches was your measurement? "
            read -r GAUGE_WIDTH
            printf "How many rows over how your measurement? "
            read -r GAUGE_RPI
            printf "How many inches was your measurement? "
            read -r GAUGE_HEIGHT
            ;;
        4) 
            printf "\nStitches per 10 cm: "
            read -r GAUGE_SPI
            GAUGE_WIDTH=3.93701 # 10 cm in inches
            printf "Rows per 10 cm: "
            read -r GAUGE_RPI
            GAUGE_HEIGHT=3.93701
            ;;
        5)
            printf "\nHow many stitches over your measurement? "
            read -r GAUGE_SPI
            printf "How many cm was your measurement? "
            read -r GAUGE_WIDTH_CM
            GAUGE_WIDTH=$(cm_to_inches "$GAUGE_WIDTH_CM")
            printf "How many rows over how your measurement? "
            read -r GAUGE_RPI
            printf "How many cm was your measurement? "
            read -r GAUGE_HEIGHT_CM
            GAUGE_HEIGHT=$(cm_to_inches "$GAUGE_HEIGHT_CM")
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
            LEG_PATTERN_NOTES="Knit all rounds in the round on double bed stockinette"
            LEG_RIBBING_SELECTED="no"
            ;;
        2)
            LEG_PATTERN="ribbing"
            printf "\nLeg ribbing pattern:\n"
            printf "1) 1x1 Ribs (K1, P1)\n"
            printf "2) 2x2 Ribs (K2, P2)\n"
            printf "Choice (1-2): "
            read -r rib_choice
            case "$rib_choice" in
                1)
                    LEG_PATTERN="1x1 ribbing"
                    LEG_PATTERN_NOTES="Work 1x1 ribbing as a flat ribbing section"
                    LEG_RIBBING_SELECTED="yes"
                    ;;
                2)
                    LEG_PATTERN="2x2 ribbing"
                    LEG_PATTERN_NOTES="Work 2x2 ribbing as a flat ribbing section"
                    LEG_RIBBING_SELECTED="yes"
                    ;;
                *)
                    LEG_PATTERN="1x1 ribbing"
                    LEG_PATTERN_NOTES="Work 1x1 ribbing as a flat ribbing section"
                    LEG_RIBBING_SELECTED="yes"
                    ;;
            esac
            get_transfer_placement
            ;;
        *)
            LEG_PATTERN="stockinette"
            LEG_PATTERN_NOTES="Knit all rounds in the round on double bed stockinette"
            LEG_RIBBING_SELECTED="no"
            ;;
    esac

    update_seam_requirement
}

get_cuff_pattern() {
    print_section "Cuff Pattern Choice"

    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        printf "Leg is ribbed. Choose cuff ribbing pattern:\n"
        printf "1) 1x1 Ribs\n"
        printf "2) 2x2 Ribs\n"
        printf "Choice (1-2): "
        read -r cuff_rib_choice

        case "$cuff_rib_choice" in
            1)
                CUFF_PATTERN="1x1 ribbing"
                CUFF_PATTERN_NOTES="Work 1x1 ribbing as a flat ribbing section"
                CUFF_RIBBING_SELECTED="yes"
                ;;
            2)
                CUFF_PATTERN="2x2 ribbing"
                CUFF_PATTERN_NOTES="Work 2x2 ribbing as a flat ribbing section"
                CUFF_RIBBING_SELECTED="yes"
                ;;
            *)
                CUFF_PATTERN="1x1 ribbing"
                CUFF_PATTERN_NOTES="Work 1x1 ribbing as a flat ribbing section"
                CUFF_RIBBING_SELECTED="yes"
                ;;
        esac
        CUFF_FINISH_STYLE="ribbing"
        get_transfer_placement
    else
        printf "Leg is stockinette. Choose cuff finish:\n"
        printf "1) Folded hem (stockinette, hand stitch after removal)\n"
        printf "2) 1x1 ribbing\n"
        printf "3) 2x2 ribbing\n"
        printf "Choice (1-3): "
        read -r cuff_finish_choice

        case "$cuff_finish_choice" in
            1)
                CUFF_PATTERN="folded hem"
                CUFF_PATTERN_NOTES="Work stockinette for cuff depth, fold, and hand stitch down"
                CUFF_RIBBING_SELECTED="no"
                CUFF_FINISH_STYLE="folded hem"
                ;;
            2)
                CUFF_PATTERN="1x1 ribbing"
                CUFF_PATTERN_NOTES="Work 1x1 ribbing as a flat ribbing section"
                CUFF_RIBBING_SELECTED="yes"
                CUFF_FINISH_STYLE="ribbing"
                get_transfer_placement
                ;;
            3)
                CUFF_PATTERN="2x2 ribbing"
                CUFF_PATTERN_NOTES="Work 2x2 ribbing as a flat ribbing section"
                CUFF_RIBBING_SELECTED="yes"
                CUFF_FINISH_STYLE="ribbing"
                get_transfer_placement
                ;;
            *)
                CUFF_PATTERN="folded hem"
                CUFF_PATTERN_NOTES="Work stockinette for cuff depth, fold, and hand stitch down"
                CUFF_RIBBING_SELECTED="no"
                CUFF_FINISH_STYLE="folded hem"
                ;;
        esac
    fi

    update_seam_requirement
}

get_transfer_placement() {
    if [ "$TRANSFER_PLACEMENT_SET" = "yes" ]; then
        return
    fi

    print_section "Ribbing Transfer Layout"
    printf "When moving ribber stitches to main bed, where should added stitches go?\n"
    printf "1) Place all added stitches on one side\n"
    printf "2) Split added stitches evenly across both sides\n"
    printf "Choice (1-2): "
    read -r transfer_choice

    case "$transfer_choice" in
        1)
            TRANSFER_PLACEMENT="one-side"
            TRANSFER_PLACEMENT_NOTES="Place all added stitches on one side of the main bed"
            ;;
        2)
            TRANSFER_PLACEMENT="split"
            TRANSFER_PLACEMENT_NOTES="Split added stitches evenly to each side of the main bed"
            ;;
        *)
            TRANSFER_PLACEMENT="split"
            TRANSFER_PLACEMENT_NOTES="Split added stitches evenly to each side of the main bed"
            ;;
    esac

    TRANSFER_PLACEMENT_SET="yes"
}

update_seam_requirement() {
    if [ "$LEG_RIBBING_SELECTED" = "yes" ] || [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        SEAM_REQUIRED="yes"
    else
        SEAM_REQUIRED="no"
    fi
}

get_toe_type() {
    print_section "Toe Type Selection"

    printf "Choose toe construction (Toe-Up):\n"
    printf "1) Short Row Toe\n"
    printf "2) Wedge Toe\n"
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
}

get_heel_type() {
    print_section "Heel Type Selection"

    printf "Choose heel construction (Toe-Up):\n"
    printf "1) Short Row Heel\n"
    printf "2) Afterthought Heel\n"
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
}

get_lengths() {
    print_section "Leg and Cuff Lengths"

    printf "Leg length (from foot to cuff, in %s): " "$UNIT_LENGTH"
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

    printf "Yarn line and/or yarn weight (leave blank to skip): "
    read -r YARN_WEIGHT

    printf "Yarn color and/or dye lot (leave blank to skip): "
    read -r YARN_COLOR
}

get_dial_settings() {
    print_section "Machine Stitch Dial Settings"

    printf "Main bed stitch dial setting: "
    read -r MAIN_BED_DIAL

    printf "Ribber bed stitch dial setting: "
    read -r RIBBER_BED_DIAL
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
    printf "  Method: toe-up\n"
    printf "  Measurement units: %s\n" "$MEASUREMENT_UNITS"

    printf "\n%bFOOT MEASUREMENTS:%b\n" "$BOLD" "$RESET"
    if [ -n "$SHOE_SIZE" ]; then
        printf "  Shoe Size: US %s (%s)\n" "$SHOE_SIZE" "$SHOE_SIZE_TYPE"
    fi
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
    printf "  Cuff pattern: %s\n" "$CUFF_PATTERN"
    printf "  Cuff finish style: %s\n" "$CUFF_FINISH_STYLE"
    printf "  Toe type: %s\n" "$TOE_TYPE"
    printf "  Heel type: %s\n" "$HEEL_TYPE"
    printf "  Row counter style: RC000 baseline, in-the-round rows count by 2\n"

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

    printf "\n%bMACHINE DIALS:%b\n" "$BOLD" "$RESET"
    printf "  Main bed dial: %s\n" "$MAIN_BED_DIAL"
    printf "  Ribber bed dial: %s\n" "$RIBBER_BED_DIAL"

    if [ "$SEAM_REQUIRED" = "yes" ]; then
        printf "\n%bSEAM NOTE:%b\n" "$BOLD" "$RESET"
        printf "  Ribbing selection requires a flat section and a leg seam.\n"
        printf "  Transfer layout: %s\n" "$TRANSFER_PLACEMENT_NOTES"
    fi
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
    printf "1) Measurement units (imperial/metric)\n"
    printf "2) Foot size\n"
    printf "3) Gauge\n"
    printf "4) Leg pattern\n"
    printf "5) Cuff pattern\n"
    printf "6) Toe type\n"
    printf "7) Heel type\n"
    printf "8) Lengths (leg and cuff)\n"
    printf "9) Yarn information\n"
    printf "10) Machine stitch dial settings\n"
    printf "11) Return to summary\n"
    printf "\nChoice (1-11): "
    read -r edit_choice

    case "$edit_choice" in
        1)
            get_measurement_units
            ;;
        2)
            get_foot_size
            calculate_cast_on
            calculate_toe_stitches
            calculate_heel_stitches
            ;;
        3)
            get_gauge
            calculate_cast_on
            calculate_leg_rounds
            calculate_cuff_rounds
            ;;
        4)
            get_leg_pattern
            ;;
        5)
            get_cuff_pattern
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
            get_dial_settings
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

rc_label() {
    printf "RC%03d" "$1"
}

generate_pattern() {
    PATTERN_TEXT=""

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

    local actual_spi=$(printf "%.1f" "$GAUGE_SPI" | awk -v gw="$GAUGE_WIDTH" '{printf "%.1f", $1 / gw}')
    local actual_rpi=$(printf "%.1f" "$GAUGE_RPI" | awk -v gh="$GAUGE_HEIGHT" '{printf "%.1f", $1 / gh}')

    local toe_rounds_used
    if [ "$TOE_TYPE" = "wedge" ]; then
        toe_rounds_used=$(( (CAST_ON - TOE_ROUNDS) / 2 ))
    else
        toe_rounds_used=$(( CAST_ON - TOE_ROUNDS ))
    fi

    local foot_total_rounds
    foot_total_rounds=$(printf "%.0f" "$FOOT_LENGTH" | awk -v rpi="$GAUGE_RPI" -v gh="$GAUGE_HEIGHT" '{printf "%.0f", ($1 * rpi) / gh}')

    local foot_only_rounds=$((foot_total_rounds - toe_rounds_used))
    if [ "$foot_only_rounds" -lt 0 ]; then
        foot_only_rounds=0
    fi

    local heel_short_rows=$((HEEL_STITCHES - HEEL_WRAP_STITCHES))
    local afterthought_heel_rounds=$(( (HEEL_STITCHES - HEEL_WRAP_STITCHES) / 2 ))

    local toe_rc_end
    if [ "$TOE_TYPE" = "wedge" ]; then
        toe_rc_end=$((toe_rounds_used * 2))
    else
        toe_rc_end=$toe_rounds_used
    fi

    local foot_rc_end=$((foot_only_rounds * 2))
    local heel_rc_end=$heel_short_rows

    local leg_rc_end
    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        leg_rc_end=$LEG_ROUNDS
    else
        leg_rc_end=$((LEG_ROUNDS * 2))
    fi

    local cuff_rc_end
    if [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        cuff_rc_end=$CUFF_ROUNDS
    else
        cuff_rc_end=$((CUFF_ROUNDS * 2))
    fi

    PATTERN_TEXT="${PATTERN_TEXT}================================================================================
DOUBLE BED MACHINE SOCK PATTERN (TOE-UP)
Generated from Double Bed Sock Pattern Generator
================================================================================

MACHINE ASSUMPTIONS
===================
- Standard gauge class double bed machine (4.5 mm)
- Brand-neutral terminology: front bed, back bed, hold position, working position
- In-the-round sections: one round = two carriage passes (RC advances by 2)
- Short-row sections worked flat on main bed: RC advances by 1 per row

PROJECT DETAILS
===============
Main bed stitch dial: $MAIN_BED_DIAL
Ribber bed stitch dial: $RIBBER_BED_DIAL
Construction: toe-up
Toe Type: $TOE_TYPE
Heel Type: $HEEL_TYPE
Leg Pattern: $LEG_PATTERN
Cuff Pattern: $CUFF_PATTERN

MEASUREMENTS & GAUGE
====================
Foot Length: $foot_len $unit_display
Foot Circumference: $foot_circ $unit_display
Leg Length: $leg_len $unit_display
Cuff Length: $cuff_len $unit_display
Gauge: $actual_spi stitches and $actual_rpi rows per inch

CALCULATED COUNTS
=================
Cast-on target circumference: $CAST_ON stitches
Toe base stitches: $TOE_ROUNDS
Heel stitches: $HEEL_STITCHES
Leg rows/rounds input: $LEG_ROUNDS
Cuff rows/rounds input: $CUFF_ROUNDS
"

    if [ -n "$YARN_BRAND" ] || [ -n "$YARN_WEIGHT" ] || [ -n "$YARN_COLOR" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}

YARN
====
Brand: $YARN_BRAND
Weight/Line: $YARN_WEIGHT
Color/Dye lot: $YARN_COLOR"
    fi

    if [ "$SEAM_REQUIRED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}

SEAM NOTICE
===========
Leg and/or cuff ribbing requires a flat section while ribber stitches are transferred.
This creates a seam line up the leg/cuff section.
Transfer layout selected: $TRANSFER_PLACEMENT_NOTES"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

PATTERN CONSTRUCTION
====================
"

    if [ "$TOE_TYPE" = "wedge" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
TOE SECTION (WEDGE TOE, IN THE ROUND)
-------------------------------------
- Cast on toe using your preferred machine-compatible closed-toe setup at $(rc_label 0).
- Start with $TOE_ROUNDS stitches total.
- Increase in the round to $CAST_ON stitches total.
- RC reference: $(rc_label 0) to $(rc_label "$toe_rc_end").
"
    else
        PATTERN_TEXT="${PATTERN_TEXT}
TOE SECTION (SHORT ROW TOE, FLAT ON MAIN BED)
----------------------------------------------
- Cast on toe setup at $(rc_label 0).
- Work short rows on the main bed to shape toe.
- Do not apply in-the-round doubling in this section.
- RC reference: $(rc_label 0) to $(rc_label "$toe_rc_end").

- Reset row counter to $(rc_label 0) after toe is complete.
"
    fi

    if [ "$TOE_TYPE" = "wedge" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}

FOOT SECTION (IN THE ROUND)
---------------------------
- Knit in the round for approximately $foot_only_rounds rounds.
- Foot RC reference: $(rc_label "$toe_rc_end") to $(rc_label $((toe_rc_end + foot_rc_end))).
- Total foot length target: $foot_len $unit_display.
"
    else
        PATTERN_TEXT="${PATTERN_TEXT}

FOOT SECTION (IN THE ROUND)
---------------------------
- Knit in the round for approximately $foot_only_rounds rounds.
- Foot RC reference: $(rc_label 0) to $(rc_label "$foot_rc_end").
- Total foot length target: $foot_len $unit_display.
"
    fi

    if [ "$HEEL_TYPE" = "short row" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}

HEEL SECTION (SHORT ROW HEEL, FLAT ON MAIN BED)
------------------------------------------------
- Reset row counter to $(rc_label 0) before heel shaping.
- Bring non-heel stitches to hold and set carriage so hold stitches do not knit.
- Work short row heel across $HEEL_STITCHES heel stitches.
- RC reference: $(rc_label 0) to $(rc_label "$heel_rc_end").

- Reset row counter to $(rc_label 0) after heel is complete.
"
    else
        PATTERN_TEXT="${PATTERN_TEXT}

AFTERTHOUGHT HEEL PLACEMENT (AT END OF FOOT)
---------------------------------------------
- At foot end, place future heel opening using waste yarn on the heel half of stitches.
- disengage knitting in the round, and knit two rows of waste yarn at a looser tension on the main bed, you will probably want to use your main bed sinker plate for this, and then switch back to your ribber arm.

- Reset row counter to $(rc_label 0) before starting leg.
"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

LEG SECTION
-----------
Pattern: $LEG_PATTERN
- $LEG_PATTERN_NOTES
"

    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Move ribber stitches to waste yarn, clear ribber bed for in-the-round stockinette workflow.
- Add the same number of stitches to the main bed: $TRANSFER_PLACEMENT_NOTES.
- Leg is worked flat for ribbing and will include a seam.
- Leg RC reference: $(rc_label 0) to $(rc_label "$leg_rc_end")."
    else
        PATTERN_TEXT="${PATTERN_TEXT}
- Continue in-the-round stockinette on double bed.
- Leg RC reference: $(rc_label 0) to $(rc_label "$leg_rc_end")."
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

CUFF SECTION
------------
- Reset row counter to $(rc_label 0) at cuff start.
"

    if [ "$CUFF_FINISH_STYLE" = "folded hem" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Work stockinette cuff depth for folded hem.
- Cuff RC reference: $(rc_label 0) to $(rc_label "$cuff_rc_end").
- Remove from machine and hand stitch folded hem in place."
    elif [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Work cuff ribbing as flat section: $CUFF_PATTERN.
- If needed, transfer ribber stitches to waste yarn and rebalance stitches to main bed: $TRANSFER_PLACEMENT_NOTES.
- Cuff RC reference: $(rc_label 0) to $(rc_label "$cuff_rc_end")."

        if [ "$LEG_RIBBING_SELECTED" != "yes" ]; then
            PATTERN_TEXT="${PATTERN_TEXT}
- Optional alternative: remove sock on waste yarn, pick up stitches, and knit cuff ribbing in the round by hand."
        fi
    else
        PATTERN_TEXT="${PATTERN_TEXT}
- Work cuff in stockinette and finish per preference.
- Cuff RC reference: $(rc_label 0) to $(rc_label "$cuff_rc_end")."
    fi

    if [ "$HEEL_TYPE" = "afterthought" ]; then
        local afterthought_rc_end=$((afterthought_heel_rounds * 2))
        PATTERN_TEXT="${PATTERN_TEXT}

AFTERTHOUGHT HEEL (WORK AFTER CUFF)
-----------------------------------
- Rehang heel opening stitches from waste-yarn section onto machine.
- Re-engage in-the-round knitting for heel.
- Work wedge-reverse shaping: start at full heel circumference and decrease in the round to approximately one-third of heel stitches ($HEEL_WRAP_STITCHES stitches).
- Heel RC reference: $(rc_label 0) to $(rc_label "$afterthought_rc_end").
- Close remaining heel stitches with Kitchener stitch.
"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

FINISHING INSTRUCTIONS
======================
1. Remove sock from machine securely.
2. Weave in ends.
3. If folded hem was selected, fold and hand stitch cuff.
4. If seam sections were worked, seam neatly for comfort.

================================================================================
Pattern generated by Double Bed Sock Pattern Generator
================================================================================"

}

display_pattern() {
    clear_screen
    printf "%s\n" "$PATTERN_TEXT" | fold -w 80 -s
}

save_pattern() {
    while true; do
        printf "\n\nWhere would you like to save the pattern?\n"
        printf "1) Current directory ($(pwd))\n"
        printf "2) Specify another directory\n"
        printf "Choice (1-2): "
        read -r save_location

        case "$save_location" in
            1)
                save_dir="$(pwd)"
                ;;
            2)
                printf "Enter directory path: "
                read -r save_dir

                # Expand ~ to home directory if present
                save_dir="${save_dir/#\~/$HOME}"

                # Check if directory exists
                if [ ! -d "$save_dir" ]; then
                    printf "Directory does not exist. Create it? (y/n): "
                    read -r create_dir
                    case "$create_dir" in
                        [Yy]*)
                            mkdir -p "$save_dir" || {
                                printf "Failed to create directory: %s\n" "$save_dir"
                                continue
                            }
                            ;;
                        *)
                            printf "Save cancelled.\n"
                            return
                            ;;
                    esac
                fi
                ;;
            *)
                printf "Invalid choice. Using current directory.\n"
                save_dir="$(pwd)"
                ;;
        esac

        printf "\nEnter filename for pattern (without extension): "
        read -r filename

        if [ -z "$filename" ]; then
            filename="sock_pattern"
        fi

        filename="${filename}.txt"
        filepath="${save_dir}/${filename}"

        printf "%s\n" "$PATTERN_TEXT" | fold -w 80 -s > "$filepath"
        printf "\nPattern saved to: %s\n" "$filepath"
        break
    done
}

output_options() {
    print_header
    print_section "Generated Pattern"

    printf "\nWhat would you like to do with your pattern?\n"
    printf "1) Display pattern on screen\n"
    printf "2) Save pattern to file\n"
    printf "3) Both display and save\n"
    printf "4) Regenerate pattern with different options\n"
    printf "5) Done (exit)\n"
    printf "\nChoice (1-5): "
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
            while edit_selection; do
                calculate_cast_on
                calculate_leg_rounds
                calculate_cuff_rounds
                calculate_toe_stitches
                calculate_heel_stitches
            done
            generate_pattern
            return 0
            ;;
        5)
            return 1
            ;; 
        *)
            printf "Invalid choice.\n"
            pause_for_user
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
    set_construction_method
    get_measurement_units
    get_foot_size
    get_gauge
    get_leg_pattern
    get_cuff_pattern
    get_toe_type
    get_heel_type
    get_lengths
    get_yarn_info
    get_dial_settings

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
    printf "Thank you for using the Double Bed Sock Pattern Generator!\n"
    printf "Happy machine knitting!\n\n"
}

# Run main function
main "$@"
