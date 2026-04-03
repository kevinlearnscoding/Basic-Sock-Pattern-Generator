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
    # shellcheck disable=SC2034
    read -r dummy
}

printf_wrapped() {
    # Prints text with 80-character line wrapping
    printf "%b" "$@" | fold -w 80 -s
}

print_welcome() {
    printf "%b" "============================================\n${HIGHLIGHT}WELCOME TO THE DOUBLE BED SOCK GENERATOR!${RESET}\n============================================\n\nThis tool generates instructions for a sock knitting pattern that is constructed on a domestic double bed knitting machine, based on your measurements, gauge, and preferences.\n\n${BOLD}NOTE: Knit a gauge swatch on your machine before using this tool to ensure accurate stitch and row counts.\nThis pattern is set to 90% ease.${RESET}\n\n${HIGHLIGHT}Let's get started!${RESET}\n" | fold -w 80 -s
}


# ============================================================================
# INPUT FUNCTIONS
# ============================================================================

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
            ;;
        2)
            MEASUREMENT_UNITS="metric"
            UNIT_LENGTH="cm"
            ;;
        *)
            MEASUREMENT_UNITS="imperial"
            UNIT_LENGTH="inches"
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
            SHOE_GENDER="Women's"
            compute_foot_length_from_womens_size "$size"
            ;;
        2)
            printf "\nUS Men's Shoe Size (5-16): "
            read -r size
            SHOE_SIZE="$size"
            SHOE_GENDER="Men's"
            compute_foot_length_from_mens_size "$size"
            ;;
        3)
            SHOE_SIZE=""
            SHOE_GENDER=""
            if [ "$MEASUREMENT_UNITS" = "metric" ]; then
                printf "\nFoot length (cm): "
            else
                printf "\nFoot length (inches): "
            fi
            read -r input_length
            if [ "$MEASUREMENT_UNITS" = "metric" ]; then
                TARGET_SOCK_LENGTH=$(cm_to_inches "$input_length")
            else
                TARGET_SOCK_LENGTH="$input_length"
            fi
            RAW_FOOT_LENGTH="$TARGET_SOCK_LENGTH"

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
            TARGET_SOCK_LENGTH=9.5
            RAW_FOOT_LENGTH=9.5
            FOOT_CIRCUMFERENCE=8
            SHOE_SIZE=""
            SHOE_GENDER=""
            ;;
    esac
}

compute_foot_length_from_womens_size() {
    # Approximate conversion: Women's size to foot length in inches.
    # RAW_FOOT_LENGTH is estimated foot size, TARGET_SOCK_LENGTH is sock target at 90% ease.
    size=$1
    RAW_FOOT_LENGTH=$(printf "%.1f" "$size" | awk '{printf "%.1f", (($1 + 21) / 3)}')
    TARGET_SOCK_LENGTH=$(printf "%.1f" "$RAW_FOOT_LENGTH" | awk '{printf "%.1f", $1 * 0.9}')
    FOOT_CIRCUMFERENCE=$(printf "%.1f" "$size" | awk '{printf "%.1f", 7.5 + ($1 * 0.08)}')
}

compute_foot_length_from_mens_size() {
    # Approximate conversion: Men's size to foot length in inches.
    # RAW_FOOT_LENGTH is estimated foot size, TARGET_SOCK_LENGTH is sock target at 90% ease.
    size=$1
    RAW_FOOT_LENGTH=$(printf "%.1f" "$size" | awk '{printf "%.1f", (($1 + 22) / 3)}')
    TARGET_SOCK_LENGTH=$(printf "%.1f" "$RAW_FOOT_LENGTH" | awk '{printf "%.1f", $1 * 0.9}')
    FOOT_CIRCUMFERENCE=$(printf "%.1f" "$size" | awk '{printf "%.1f", 8.0 + ($1 * 0.08)}')
}

get_gauge() {
    print_section "Gauge Information"

    printf "How do you want to enter gauge?\n"
    printf "1) Stitches/rows per inch (standard)\n"
    printf "2) Stitches/rows per 4 inches (common for swatches)\n"
    printf "3) Stitches/rows over custom number of inches\n"
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
    printf "NOTE: Ribbing patterns will be worked as a flat section with transfers to the main bed, not in the round, and will need to be Kitchener stitched to the foot and seamed up the leg after knitting.\n"
    printf "Choice (1-2): "
    read -r leg_choice

    case "$leg_choice" in
        1)
            LEG_PATTERN="stockinette"
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
                    LEG_RIBBING_SELECTED="yes"
                    ;;
                2)
                    LEG_PATTERN="2x2 ribbing"
                    LEG_RIBBING_SELECTED="yes"
                    ;;
                *)
                    LEG_PATTERN="1x1 ribbing"
                    LEG_RIBBING_SELECTED="yes"
                    ;;
            esac
            get_transfer_placement
            ;;
        *)
            LEG_PATTERN="stockinette"
            LEG_RIBBING_SELECTED="no"
            ;;
    esac

    update_seam_requirement
}

get_cuff_pattern() {
    print_section "Cuff Pattern Choice"

    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        printf "Choose cuff ribbing pattern:\n"
        printf "1) 1x1 ribbing\n"
        printf "2) 2x2 ribbing\n"
        printf "Choice (1-2): "
        read -r cuff_rib_choice

        case "$cuff_rib_choice" in
            1)
                CUFF_PATTERN="1x1 ribbing"
                ;;
            2)
                CUFF_PATTERN="2x2 ribbing"
                ;;
            *)
                CUFF_PATTERN="1x1 ribbing"
                ;;
        esac
        CUFF_RIBBING_SELECTED="yes"
        CUFF_FINISH_STYLE="ribbing"
        get_transfer_placement
    else
        printf "Choose cuff finish:\n"
        printf "1) Folded hem\n"
        printf "2) 1x1 ribbing\n"
        printf "3) 2x2 ribbing\n"
        printf "Choice (1-3): "
        read -r cuff_finish_choice

        case "$cuff_finish_choice" in
            1)
                CUFF_PATTERN="folded hem"
                CUFF_RIBBING_SELECTED="no"
                CUFF_FINISH_STYLE="folded hem"
                ;;
            2)
                CUFF_PATTERN="1x1 ribbing"
                CUFF_RIBBING_SELECTED="yes"
                CUFF_FINISH_STYLE="ribbing"
                get_transfer_placement
                ;;
            3)
                CUFF_PATTERN="2x2 ribbing"
                CUFF_RIBBING_SELECTED="yes"
                CUFF_FINISH_STYLE="ribbing"
                get_transfer_placement
                ;;
            *)
                CUFF_PATTERN="folded hem"
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
    printf "1) All added stitches on one side (seam on side of leg)\n"
    printf "2) Split added stitches evenly across both sides (seam on back of leg)\n"
    printf "Choice (1-2): "
    read -r transfer_choice

    case "$transfer_choice" in
        1)
            TRANSFER_PLACEMENT_NOTES="Place all added stitches on one side of the main bed"
            ;;
        *)
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
    printf "2) Afterthought Heel (Rehung on bed and worked Reverse-Wedge in the round)\n"
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

calculate_circumference_stitches() {
    # Cast-on stitches based on foot circumference and gauge
    # Formula: (foot circumference * stitches per inch) / gauge width
    # Use awk to handle decimal gauge values

    CIRCUMFERENCE_STITCHES=$(printf "%s\n" "$FOOT_CIRCUMFERENCE" | awk -v gs="$GAUGE_SPI" -v gw="$GAUGE_WIDTH" '{printf "%.0f", ($1 * gs) / gw}')

    # Round to nearest even number for easier ribbing patterns
    if [ $((CIRCUMFERENCE_STITCHES % 2)) -eq 1 ]; then
        CIRCUMFERENCE_STITCHES=$((CIRCUMFERENCE_STITCHES - 1))
    fi

    HALF_CIRC_STITCHES=$((CIRCUMFERENCE_STITCHES / 2))

    ONE_THIRD_CIRC_STITCHES=$((CIRCUMFERENCE_STITCHES / 3))
    # ONE_THIRD_CIRC_STITCHES needs to be rounded to an even number for easier handling
    if [ $((ONE_THIRD_CIRC_STITCHES % 2)) -eq 1 ]; then
        ONE_THIRD_CIRC_STITCHES=$((ONE_THIRD_CIRC_STITCHES - 1))
    fi
    # Wedge toe increases add 4 stitches per increase round.
    # Adjust the one-third cast-on downward until the remaining stitches are divisible by 4.
    if [ "$TOE_TYPE" = "wedge" ]; then
        while [ $(((CIRCUMFERENCE_STITCHES - ONE_THIRD_CIRC_STITCHES) % 4)) -ne 0 ]; do
            ONE_THIRD_CIRC_STITCHES=$((ONE_THIRD_CIRC_STITCHES - 2))
        done
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


calculate_shortrow_stitches() {
    # Shared short-row center stitches used by both toe and heel shaping.
    # Approximate target is 1/3 of the half-sock stitch count.
    SHORT_ROW_CENTER_STITCHES=$((HALF_CIRC_STITCHES / 3))

    # Ensure even number for ease of calculations
    if [ $((SHORT_ROW_CENTER_STITCHES % 2)) -eq 1 ]; then
        SHORT_ROW_CENTER_STITCHES=$((SHORT_ROW_CENTER_STITCHES - 1))
    fi

    SR_HOLD_PER_SIDE=$(( (HALF_CIRC_STITCHES - SHORT_ROW_CENTER_STITCHES) / 2 ))
    SR_DEPTH=$((HALF_CIRC_STITCHES - SHORT_ROW_CENTER_STITCHES)) # Since one needle is worked each row we can use that as a row counter
    SR_FULL_RC=$((SR_DEPTH * 2))
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
        printf "  Shoe Size: US %s (%s)\n" "$SHOE_SIZE" "$SHOE_GENDER"
    fi
    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        if [ -n "$RAW_FOOT_LENGTH" ]; then
            printf "  Estimated foot length: %.1f cm\n" "$(inches_to_cm "$RAW_FOOT_LENGTH")"
            printf "  Target sock foot length (90%% ease): %.1f cm\n" "$(inches_to_cm "$TARGET_SOCK_LENGTH")"
        else
            printf "  Foot length input: %.1f cm\n" "$(inches_to_cm "$TARGET_SOCK_LENGTH")"
        fi
        printf "  Foot circumference: %.1f cm\n" "$(inches_to_cm "$FOOT_CIRCUMFERENCE")"
    else
        if [ -n "$RAW_FOOT_LENGTH" ]; then
            printf "  Estimated foot length: %.1f inches\n" "$RAW_FOOT_LENGTH"
            printf "  Target sock foot length (90%% ease): %.1f inches\n" "$TARGET_SOCK_LENGTH"
        else
            printf "  Foot length input: %.1f inches\n" "$TARGET_SOCK_LENGTH"
        fi
        printf "  Foot circumference: %.1f inches\n" "$FOOT_CIRCUMFERENCE"
    fi

    printf "\n%bGAUGE:%b\n" "$BOLD" "$RESET"
    printf "  Stitch gauge: %.1f stitches per inch\n" "$GAUGE_SPI"
    printf "  Row gauge: %.1f rows per inch\n" "$GAUGE_RPI"

    printf "\n%bPATTERN DETAILS:%b\n" "$BOLD" "$RESET"
    printf "  Leg pattern: %s\n" "$LEG_PATTERN"
    printf "  Cuff pattern: %s\n" "$CUFF_PATTERN"
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
    printf "  Cast-on: %d stitches\n" "$CIRCUMFERENCE_STITCHES"
    printf "  Leg rounds: %d\n" "$LEG_ROUNDS"
    printf "  Cuff rounds: %d\n" "$CUFF_ROUNDS"
    printf "  Heel stitches: %d\n" "$HALF_CIRC_STITCHES"

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
        printf "  Ribbing selection requires a flat section and a seam.\n"
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
            calculate_circumference_stitches
            calculate_shortrow_stitches
            ;;
        3)
            get_gauge
            calculate_circumference_stitches
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

generate_pattern() {
    PATTERN_TEXT=""

    if [ "$MEASUREMENT_UNITS" = "metric" ]; then
        raw_foot_len=$(inches_to_cm "$RAW_FOOT_LENGTH")
        foot_len=$(inches_to_cm "$TARGET_SOCK_LENGTH")
        foot_circ=$(inches_to_cm "$FOOT_CIRCUMFERENCE")
        leg_len=$(inches_to_cm "$LEG_LENGTH")
        cuff_len=$(inches_to_cm "$CUFF_LENGTH")
        unit_display="cm"
    else
        raw_foot_len=$(printf "%.1f" "$RAW_FOOT_LENGTH")
        foot_len=$(printf "%.1f" "$TARGET_SOCK_LENGTH")
        foot_circ=$(printf "%.1f" "$FOOT_CIRCUMFERENCE")
        leg_len=$(printf "%.1f" "$LEG_LENGTH")
        cuff_len=$(printf "%.1f" "$CUFF_LENGTH")
        unit_display="inches"
    fi

    ACTUAL_SPI=$(awk -v gs="$GAUGE_SPI" -v gw="$GAUGE_WIDTH" 'BEGIN {
        if (gw == 0) gw = 1
        printf "%.1f", gs / gw
    }')
    ACTUAL_RPI=$(awk -v gr="$GAUGE_RPI" -v gh="$GAUGE_HEIGHT" 'BEGIN {
        if (gh == 0) gh = 1
        printf "%.1f", gr / gh
    }')

    # WEDGE_INCREASES calculates how many increase rows are needed for a wedge toe
    # Cast on one third stitches of total circumference, divided evenly across both beds
    # Increase each end of each bed every other round until reaching full circumference stitch count
    # WEDGE_INCREASES=$(( (CIRCUMFERENCE_STITCHES - ONE_THIRD_CIRC_STITCHES) / 4 ))

    # Use one canonical depth model for foot-length budgeting
    TOE_FOOT_ROWS=$SR_DEPTH

    if [ "$TOE_TYPE" = "wedge" ]; then
        WEDGE_TOE_NEEDLES_PER_BED=$(( (ONE_THIRD_CIRC_STITCHES) / 2 ))
    fi

    if [ "$HEEL_TYPE" = "short row" ]; then
        HEEL_FOOT_ROWS=$SR_DEPTH
    else # [ "$HEEL_TYPE" = "afterthought" ]; then
        # Keep afterthought heel depth consistent with the short-row depth model
        HEEL_FOOT_ROWS=$SR_DEPTH
    fi

    WEDGE_TOE_RC=$(((WEDGE_TOE_NEEDLES_PER_BED * 2) + 2)) # Add 2 rounds for the zigzag row and final wedge shaping after toe rounds are done

    # Calculate total sock length in rows based on target foot length and row gauge
    SOCK_LENGTH_IN_ROWS=$(awk -v fl="$TARGET_SOCK_LENGTH" -v gr="$GAUGE_RPI" -v gh="$GAUGE_HEIGHT" 'BEGIN {
        if (gh == 0) gh = 1
        printf "%.0f", fl * gr / gh
    }')

    # Calculate foot-only length (in rows)
    FOOT_ONLY_ROUNDS=$((SOCK_LENGTH_IN_ROWS - TOE_FOOT_ROWS - HEEL_FOOT_ROWS))
    
    if [ "$FOOT_ONLY_ROUNDS" -lt 0 ]; then
        FOOT_ONLY_ROUNDS=0
    fi
    FOOT_ONLY_RC=$((FOOT_ONLY_ROUNDS * 2))

    # Calculate leg and cuff row counts based on lengths and gauge
    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        LEG_RC=$LEG_ROUNDS
    else # if working stockinette, double the row count to account for working in the round
        LEG_RC=$((LEG_ROUNDS * 2))
    fi

    if [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        cuff_rc_end=$CUFF_ROUNDS
    else # if [ "$CUFF_RIBBING_SELECTED" = "no" ], working stockinette in the round, so double row count to account for working in the round
        cuff_rc_end=$((CUFF_ROUNDS * 2))
    fi

    # Format RC values as three-digit numbers to match row counter displays
    SR_DEPTH=$(printf "%03d" "$SR_DEPTH")
    SR_FULL_RC=$(printf "%03d" "$SR_FULL_RC")
    WEDGE_TOE_RC=$(printf "%03d" "$WEDGE_TOE_RC")
    FOOT_ONLY_RC=$(printf "%03d" "$FOOT_ONLY_RC")
    LEG_RC=$(printf "%03d" "$LEG_RC")
    cuff_rc_end=$(printf "%03d" "$cuff_rc_end")

    PATTERN_TEXT="${PATTERN_TEXT}================================================================================
DOUBLE BED MACHINE SOCK PATTERN (TOE-UP)
Generated from Double Bed Sock Pattern Generator
================================================================================

BASIC ASSUMPTIONS
=================
- You are comfortable with your machine"

    if [ "$LEG_RIBBING_SELECTED" = "yes" ] || [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- You are comfortable moving stitches between beds"
    fi

    if [ "$TOE_TYPE" = "short row" ] || [ "$HEEL_TYPE" = "short row" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- You are comfortable short row shaping"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
- Your knitting machine has a ribber, and can knit in-the-round (main bed and ribber carriage can knit in one direction while slipping in the other)"

    if [ "$TOE_TYPE" = "short row" ] || [ "$HEEL_TYPE" = "short row" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Your machine can put stitches in hold and not knit them"
    fi

    if [ "$LEG_RIBBING_SELECTED" = "yes" ] || [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Your machine can be set to not knit stitches in working (B) position in either/both directions"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
- You can use only the main bed of your machine while the ribber is still attached and has stitches attached to it

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
===================="

    if [ -n "$SHOE_SIZE" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
Shoe size: US $SHOE_GENDER $SHOE_SIZE"
    fi

    if [ -n "$SHOE_SIZE" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
Estimated Foot Length: $raw_foot_len $unit_display
Target Sock Foot Length (90% ease): $foot_len $unit_display"
    else
        PATTERN_TEXT="${PATTERN_TEXT}
Foot Length Input: $foot_len $unit_display"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
Foot Circumference: $foot_circ $unit_display
Leg Length: $leg_len $unit_display
Cuff Length: $cuff_len $unit_display
Gauge: $ACTUAL_SPI stitches and $ACTUAL_RPI rows per inch"
    if [ "$gauge_method" = "2" ]; then
    PATTERN_TEXT="${PATTERN_TEXT}
($GAUGE_SPI stitches per 4 inches and $GAUGE_RPI rows per 4 inches)"
    fi
    if [ "$gauge_method" = "3" ]; then
    PATTERN_TEXT="${PATTERN_TEXT}
($GAUGE_SPI stitches per $GAUGE_WIDTH inches and $GAUGE_RPI rows per $GAUGE_HEIGHT inches)"
    fi
    if [ "$gauge_method" = "4" ]; then
    PATTERN_TEXT="${PATTERN_TEXT}
($GAUGE_SPI stitches per 10 cm and $GAUGE_RPI rows per 10 cm)"
    fi
    if [ "$gauge_method" = "5" ]; then
    PATTERN_TEXT="${PATTERN_TEXT}
($GAUGE_SPI stitches per $GAUGE_WIDTH_CM cm and $GAUGE_RPI rows per $GAUGE_HEIGHT_CM cm)"
    fi
    PATTERN_TEXT="${PATTERN_TEXT}

PATTERN CONSTRUCTION
===================="
    if [ "$TOE_TYPE" = "short row" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}

TOE SECTION (SHORT ROW TOE, MAIN BED ONLY)
-------------------------------------------
- Cast on $HALF_CIRC_STITCHES stitches on the main bed using waste yarn.
- Knit several rows of waste yarn (at least 2 inches recommended).
- Set row counter to 000.
- Work short rows on the main bed to shape toe.
- Set carriage to HOLD.
Short row shaping:
- Bring 1 needle furthest from the carriage from working position into hold position. 
- Knit 1 row.
- Wrap the needle just placed in hold by bringing the yarn under the needle.
- Repeat until $SR_HOLD_PER_SIDE stitches are in hold on each side and there are $SHORT_ROW_CENTER_STITCHES left in the middle (RC$SR_DEPTH).
Begin bringing needles back into work:
- Bring one HOLD needle (closest to 0) on the opposite side of the carraige back into forward working position (D). Knit 1 row.
- Repeat until all stitches are back in work ($HALF_CIRC_STITCHES stitches, RC$SR_FULL_RC)."
    else
        PATTERN_TEXT="${PATTERN_TEXT}

TOE SECTION (WEDGE TOE, IN THE ROUND)
-------------------------------------
- Set row counter to RC000.
- Bring $WEDGE_TOE_NEEDLES_PER_BED needles into work on each bed and knit a zig-zag row.
- Hang ribber comb and weights.
- Set carriages to knit in the round.
- Knit 1 round (2 passes of carriage).
Wedge shaping:
- Increase 1 stitch on each end of each bed and knit 1 round. (4 increases in total)
- Knit 1 round.
- Repeat the Wedge shaping $WEDGE_INCREASES times until $HALF_CIRC_STITCHES stitches are on each bed, $CIRCUMFERENCE_STITCHES in total (RC$WEDGE_TOE_RC).
"
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

FOOT SECTION (IN THE ROUND)
---------------------------"

    if [ "$TOE_TYPE" = "short row" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- If your ribber has racking capability, set ribber to full pitch.
- Rehang the live stitches from waste yarn onto the ribber bed ($HALF_CIRC_STITCHES stitches).
- Set your machine for in-the-round knitting (main bed and ribber each knit in one direction only, opposite each other).
- Ensure carriage directions pick up yarn from current yarn position, knitting on the ribber first."
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
- Reset row count to RC000.
- Knit in the round for $FOOT_ONLY_ROUNDS rounds (RC$FOOT_ONLY_RC)."

    if [ "$HEEL_TYPE" = "short row" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}

HEEL SECTION (SHORT ROW HEEL, MAIN BED ONLY)
---------------------------------------------"
        if [ "$TOE_TYPE" = "short row" ]; then
            PATTERN_TEXT="${PATTERN_TEXT}
- Work short row heel across $HALF_CIRC_STITCHES heel stitches exactly as for the toe (RC$SR_FULL_RC)."
        else
            PATTERN_TEXT="${PATTERN_TEXT}
- Work short rows across $HALF_CIRC_STITCHES heel stitches:
- Set row counter to 000.
- Drop ribber bed and set up for knitting on the main bed only.
- Set carriage to HOLD.
- Bring 1 needle (closest to center 0) on the side of the bed opposite the carriage into hold, knit 1 row.
- Wrap the needle that was just placed in hold by bringing the yarn under the needle.
- Bring 1 needle into hold on the side of the bed opposite the carriage, knit 1 row.
- Wrap the needle that was just placed in hold, making sure to bring the yarn over the other needles in hold.
- Repeat until $SR_HOLD_PER_SIDE stitches are in hold on each side and there are $SHORT_ROW_CENTER_STITCHES left in the middle (RC$SR_DEPTH).
- Begin bringing needles back into work:
    - Bring 1 needle back into work (closest to center 0) on the side of the bed opposite the carriage, knit 1 row.
- Repeat until all stitches are back in work ($HALF_CIRC_STITCHES stitches, RC$SR_FULL_RC)."
        fi
    else
        PATTERN_TEXT="${PATTERN_TEXT}

AFTERTHOUGHT HEEL PLACEMENT (AT END OF FOOT)
---------------------------------------------
Place waste yarn as a stitch holder/marker for heel placement on heel stitches, it may be easier to hand-manipulate these stitches, but if using the carriage:
  - Disengage knitting in the round, drop the ribber, and attach your main bed sinker plate
- Knit two rows of waste yarn at a looser tension on the main bed."
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

LEG SECTION - $LEG_PATTERN
-------------------------"

    if [ "$HEEL_TYPE" = "afterthought" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Keep the waste-yarn heel marker in place for later heel knitting.
- Bring ribber back up and set up for in-the-round knitting."
    fi

    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Disengage row counter and set main bed carriage so main bed stitches do not knit. (NOT HOLD - just set to not knit in either direction)
- Knit several rows of waste yarn on ribber only.
- Remove ribber stitches and let hang from main bed. Drop ribber.
- Set main carriage for normal knitting with stitches in HOLD.
- Place all stitches on main bed into HOLD.
- On opposite side from working yarn, cast on $HALF_CIRC_STITCHES stitches in waste yarn next to held stitches.
- Knit several rows of waste yarn over these stitches. (Make sure you do not knit the stitches in HOLD)
- Remove waste yarn from feeder and free-pass carriage back to working-yarn side.
- Rethread working yarn and bring up ribber.
- Set up for $LEG_PATTERN. Reengage row counter and reset to RC000.
- Remove carraige from hold and rib for $LEG_ROUNDS rows (RC$LEG_RC)."
    else
        PATTERN_TEXT="${PATTERN_TEXT}
- Bring ribber back up and set up for in-the-round knitting again, ensuring carriage directions pick up yarn from current yarn position on main bed and knit on the ribber bed first.
- Continue in-the-round stockinette for $LEG_ROUNDS rounds (RC$LEG_RC)."
    fi

    PATTERN_TEXT="${PATTERN_TEXT}

CUFF SECTION
------------
- Reset row counter to RC000."

    if [ "$CUFF_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Set up for $CUFF_PATTERN"

        if [ "$CUFF_PATTERN" = "1x1 ribbing" ] && [ "$LEG_PATTERN" = "2x2 ribbing" ]; then
            PATTERN_TEXT="${PATTERN_TEXT}
- It may be easier to transfer all stitches to the main bed and then set up for 1x1 ribbing.
- Knit $CUFF_ROUNDS rows (RC$cuff_rc_end)."
        elif [ "$CUFF_PATTERN" = "2x2 ribbing" ] && [ "$LEG_PATTERN" = "1x1 ribbing" ]; then
            PATTERN_TEXT="${PATTERN_TEXT}
- It may be easier to transfer all stitches to the main bed and then set up for 2x2 ribbing.
- Knit $CUFF_ROUNDS rows (RC$cuff_rc_end)."
        else
            if [ "$LEG_PATTERN" = "stockinette" ]; then
                if [ "$CUFF_PATTERN" = "2x2 ribbing" ] || [ "$CUFF_PATTERN" = "1x1 ribbing" ]; then
                    PATTERN_TEXT="${PATTERN_TEXT}
- For ribbing you can either: 
    - knit waste yarn and remove from the machine and hand knit the cuff ribbing, or 
    - transfer stitches to the main bed and knit cuff ribbing on the machine and graft the cuff to the leg section using Kithener stitch and have a small seam along the side to join the two halfs of the ribbing.
    If you want to transfer stitches to the main bed and knit cuff ribbing on the machine:
        - Disengage row counter and set main bed carriage so main bed stitches do not knit. (NOT HOLD - just set to not knit in either direction)
        - Knit several rows of waste yarn on ribber only.
        - Remove ribber stitches and let hang from main bed. Drop ribber.
        - Set main carriage for normal knitting with stitches in HOLD.
        - Place all stitches on main bed into HOLD.
        - On opposite side from working yarn, cast on $HALF_CIRC_STITCHES stitches in waste yarn next to held stitches.
        - Knit several rows of waste yarn over these stitches. (Make sure you do not knit the stitches in HOLD)
        - Remove waste yarn from feeder and free-pass carriage back to working-yarn side.
        - Rethread working yarn and bring up ribber.
        - Set up for $LEG_PATTERN. Reengage row counter and reset to RC000.
        - Remove carraige from hold and rib for $CUFF_ROUNDS rows (RC$cuff_rc_end)."
                else
                    PATTERN_TEXT="${PATTERN_TEXT}
- Knit $CUFF_ROUNDS rows (RC$cuff_rc_end)."
                fi
            else
                PATTERN_TEXT="${PATTERN_TEXT}
- Knit $CUFF_ROUNDS rows (RC$cuff_rc_end)."
            fi
        fi
    elif [ "$CUFF_FINISH_STYLE" = "folded hem" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Continue in stockinette for $CUFF_ROUNDS rows (RC$cuff_rc_end)."
    else
        PATTERN_TEXT="${PATTERN_TEXT}
- Knit cuff section for $CUFF_ROUNDS rows (RC$cuff_rc_end)."
    fi
    if [ "$CUFF_FINISH_STYLE" = "folded hem" ] && [ "$LEG_RIBBING_SELECTED" != "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Cut yarn, leaving long tail for sewing down the hem.
- Knit several rows of waste yarn and remove from machine.
- Fold cuff in half and sew down fold to create hem."
    else
        PATTERN_TEXT="${PATTERN_TEXT}
- Cast off with stretchy cast off, leaving a long tail for seam and Kitchener finishing."
    fi

    PATTERN_TEXT="${PATTERN_TEXT}
    
FINISHING INSTRUCTIONS
======================"

    if [ "$LEG_RIBBING_SELECTED" = "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Kitchener stitch the leg ribbing to the foot.
- Sew side seam using flat seam technique."
    fi
    if [ "$CUFF_PATTERN" != "folded hem" ] && [ "$LEG_RIBBING_SELECTED" != "yes" ]; then
        PATTERN_TEXT="${PATTERN_TEXT}
- Kitchener stitch the ribbed cuff to the leg.
- Sew side seam using flat seam technique."
    fi
    PATTERN_TEXT="${PATTERN_TEXT}
- Weave in ends.
- Block as appropriate for your yarn.

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
        printf "1) Current directory\n"
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
                case "$save_dir" in
                    ~)
                        save_dir=$HOME
                        ;;
                    ~/*)
                        save_dir="$HOME/${save_dir#~/}"
                        ;;
                esac

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
                calculate_circumference_stitches

                calculate_leg_rounds
                calculate_cuff_rounds
                calculate_shortrow_stitches
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
    calculate_leg_rounds
    calculate_cuff_rounds
    calculate_circumference_stitches
    calculate_shortrow_stitches

    # Review and allow changes
    while true; do
        display_summary
        if ! confirm_changes; then
            break
        fi
        while edit_selection; do
            calculate_circumference_stitches
            calculate_leg_rounds
            calculate_cuff_rounds
            calculate_shortrow_stitches
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
