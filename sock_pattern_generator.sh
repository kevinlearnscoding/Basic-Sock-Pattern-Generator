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

# ============================================================================
# INPUT FUNCTIONS
# ============================================================================

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
            printf "\nFoot length in inches: "
            read -r FOOT_LENGTH
            printf "Foot circumference in inches: "
            read -r FOOT_CIRCUMFERENCE
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
            printf "\nHow many stitches over how many inches? "
            read -r GAUGE_SPI
            printf "Enter width in inches: "
            read -r GAUGE_WIDTH
            printf "How many rows over how many inches? "
            read -r GAUGE_RPI
            printf "Enter height in inches: "
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
    printf "1) Stockinette (smooth, V-pattern)\n"
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

    printf "Choose toe construction:\n"
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
}

get_heel_type() {
    print_section "Heel Type Selection"

    printf "Choose heel construction:\n"
    printf "1) Short Row Heel (wrapped stitches)\n"
    printf "2) Afterthought Heel (knit toe first, pick up after)\n"
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

    printf "Leg length (from cuff to heel, in inches): "
    read -r LEG_LENGTH

    printf "Cuff length (in inches): "
    read -r CUFF_LENGTH
}

get_yarn_info() {
    print_section "Yarn Information"

    printf "Yarn brand: "
    read -r YARN_BRAND

    printf "Yarn weight (e.g., Fingering, Sport, DK): "
    read -r YARN_WEIGHT

    printf "Yarn color and/or dye lot: "
    read -r YARN_COLOR

    printf "Yardage available (yards): "
    read -r YARN_YARDAGE
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
    # Using shell arithmetic with integer math

    # Convert to integers (multiply by 10 to preserve one decimal place)
    local fc_int=$(printf "%.0f" "$(echo "$FOOT_CIRCUMFERENCE * 10" | awk '{printf "%.0f", $1*10}')")
    local gs_int=$((GAUGE_SPI * 10))

    # Calculate: fc_int * gs_int / (gw * 10 * 10)
    CAST_ON=$(( (fc_int * GAUGE_SPI) / (GAUGE_WIDTH * 10) ))

    # If result seems wrong (might happen with pure shell), use fallback
    if [ "$CAST_ON" -lt 20 ]; then
        CAST_ON=$(printf "%.0f" "$FOOT_CIRCUMFERENCE" | awk -v gs="$GAUGE_SPI" -v gw="$GAUGE_WIDTH" '{printf "%.0f", ($1 * gs) / gw}')
    fi

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
    # For wedge toe: calculate rounds needed
    # For short row toe: calculate number of rows
    TOE_ROUNDS=$((CAST_ON / 4))
}

calculate_heel_stitches() {
    # Heel flap stitches are typically half of cast-on
    HEEL_STITCHES=$((CAST_ON / 2))
}

calculate_yardage_needed() {
    # Rough estimate: multiply cast-on by total rounds
    local total_rounds=$((CAST_ON * (LEG_ROUNDS + CUFF_ROUNDS + TOE_ROUNDS)))
    # Estimate: each stitch round uses approximately (cast-on stitches / 600) yards
    ESTIMATED_YARDAGE=$(( total_rounds / 600 ))

    # If too small, use alternative calculation
    if [ "$ESTIMATED_YARDAGE" -lt 30 ]; then
        ESTIMATED_YARDAGE=$(( (CAST_ON * (LEG_ROUNDS + CUFF_ROUNDS)) / 500 ))
    fi
}

# ============================================================================
# REVIEW AND CONFIRM FUNCTIONS
# ============================================================================

display_summary() {
    print_header
    print_section "Pattern Summary - Review Your Selections"

    printf "\n%bFOOT MEASUREMENTS:%b\n" "$BOLD" "$RESET"
    printf "  Foot length: %.1f inches\n" "$FOOT_LENGTH"
    printf "  Foot circumference: %.1f inches\n" "$FOOT_CIRCUMFERENCE"

    printf "\n%bGAUGE:%b\n" "$BOLD" "$RESET"
    printf "  Stitch gauge: %.1f stitches per inch\n" "$GAUGE_SPI"
    printf "  Row gauge: %.1f rows per inch\n" "$GAUGE_RPI"

    printf "\n%bPATTERN DETAILS:%b\n" "$BOLD" "$RESET"
    printf "  Leg pattern: %s\n" "$LEG_PATTERN"
    printf "  Toe type: %s\n" "$TOE_TYPE"
    printf "  Heel type: %s\n" "$HEEL_TYPE"

    printf "\n%bLENGTHS:%b\n" "$BOLD" "$RESET"
    printf "  Leg length: %.1f inches\n" "$LEG_LENGTH"
    printf "  Cuff length: %.1f inches\n" "$CUFF_LENGTH"

    printf "\n%bCALCULATED STITCH COUNTS:%b\n" "$BOLD" "$RESET"
    printf "  Cast-on: %d stitches\n" "$CAST_ON"
    printf "  Leg rounds: %d\n" "$LEG_ROUNDS"
    printf "  Cuff rounds: %d\n" "$CUFF_ROUNDS"
    printf "  Heel stitches: %d\n" "$HEEL_STITCHES"

    printf "\n%bYARN:%b\n" "$BOLD" "$RESET"
    printf "  Brand: %s\n" "$YARN_BRAND"
    printf "  Weight: %s\n" "$YARN_WEIGHT"
    printf "  Color/Dye lot: %s\n" "$YARN_COLOR"
    printf "  Yardage available: %d yards\n" "$YARN_YARDAGE"
    printf "  Estimated yardage needed: %d yards\n" "$ESTIMATED_YARDAGE"

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
    printf "1) Foot size\n"
    printf "2) Gauge\n"
    printf "3) Leg pattern\n"
    printf "4) Toe type\n"
    printf "5) Heel type\n"
    printf "6) Lengths (leg and cuff)\n"
    printf "7) Yarn information\n"
    printf "8) Needle information\n"
    printf "9) Return to summary\n"
    printf "\nChoice (1-9): "
    read -r edit_choice

    case "$edit_choice" in
        1)
            get_foot_size
            calculate_cast_on
            calculate_toe_stitches
            calculate_heel_stitches
            ;;
        2)
            get_gauge
            calculate_cast_on
            calculate_leg_rounds
            calculate_cuff_rounds
            ;;
        3)
            get_leg_pattern
            ;;
        4)
            get_toe_type
            ;;
        5)
            get_heel_type
            ;;
        6)
            get_lengths
            calculate_leg_rounds
            calculate_cuff_rounds
            calculate_yardage_needed
            ;;
        7)
            get_yarn_info
            ;;
        8)
            get_needle_info
            ;;
        9)
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

    PATTERN_TEXT="${PATTERN_TEXT}================================================================================
CUSTOM SOCK KNITTING PATTERN
Generated from Basic Sock Pattern Generator
================================================================================

PROJECT DETAILS
===============
Yarn: $YARN_BRAND, $YARN_WEIGHT, Color: $YARN_COLOR
Yardage available: $YARN_YARDAGE yards
Estimated yardage needed: $ESTIMATED_YARDAGE yards

Needle Size: $NEEDLE_SIZE
Needle Method: $NEEDLE_METHOD

MEASUREMENTS & GAUGE
====================
Foot Length: $(printf "%.1f" "$FOOT_LENGTH") inches
Foot Circumference: $(printf "%.1f" "$FOOT_CIRCUMFERENCE") inches
Leg Length: $(printf "%.1f" "$LEG_LENGTH") inches
Cuff Length: $(printf "%.1f" "$CUFF_LENGTH") inches

Gauge: $(printf "%.1f" "$GAUGE_SPI") stitches and $(printf "%.1f" "$GAUGE_RPI") rows per inch

STITCH COUNTS
==============
Cast on: $CAST_ON stitches
Divide evenly onto needle method of choice.

Cuff rounds: $CUFF_ROUNDS
Leg rounds: $LEG_ROUNDS
Heel stitches: $HEEL_STITCHES
Toe rounds: $TOE_ROUNDS

PATTERN CONSTRUCTION
====================

CUFF SECTION ($CUFF_LENGTH inches / $CUFF_ROUNDS rounds)
-------
Ribbing pattern: $LEG_PATTERN_NOTES

Instructions:
- Cast on $CAST_ON stitches loosely using long-tail cast-on
- Join in the round, being careful not to twist
- Work $CUFF_ROUNDS rounds of $LEG_PATTERN
- Tip: Keep first few stitches lose to avoid tight cuff

LEG SECTION ($LEG_LENGTH inches / $LEG_ROUNDS rounds)
-------
Pattern: $LEG_PATTERN

Instructions:
- $LEG_PATTERN_NOTES
- Continue for $LEG_ROUNDS rounds
- Leg should measure approximately $LEG_LENGTH inches from cuff

"

    case "$HEEL_TYPE" in
        "short row")
            PATTERN_TEXT="${PATTERN_TEXT}HEEL FLAP (SHORT ROW METHOD)
--------
Heel flap is worked back and forth on $HEEL_STITCHES stitches (half of cast-on).

Setup:
- Knit $((CAST_ON / 2)) stitches, turn (leaving remaining stitches to be picked up later)

Heel flap:
- Work back and forth on $HEEL_STITCHES stitches using slip stitch selvedge
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat rows 1-2 for approximately $((HEEL_STITCHES * 2 / 3)) rows
- Heel flap should be roughly square

Short Row Turning:
- Work $((HEEL_STITCHES - 1)) stitches, W&T (wrap and turn)
- Work down to 1 stitch before the gap, W&T
- Continue until you have worked the wrapped stitches
- Pick up wraps and work them together with their stitches

Re-shaping the Sock:
- Pick up stitches along the side of the heel flap
- Continue around the foot to the other side
- Pick up stitches on the other side of heel flap
- You should be back to $CAST_ON stitches

FOOT SECTION
--------
- Continue in stockinette stitch (or pattern of choice) until sock measures
  approximately $FOOT_LENGTH inches from back of heel

TOE (SHORT ROW METHOD)
------
- Work short rows, decreasing around the foot
- Round 1: Work to last 2 stitches of first side, K2tog
- Round 2: Work to last 2 stitches of other side, K2tog
- Continue until approximately 20-24 stitches remain
- Graft remaining stitches using Kitchener stitch

"
            ;;
        "afterthought")
            PATTERN_TEXT="${PATTERN_TEXT}HEEL SETUP (AFTERTHOUGHT METHOD)
--------
For afterthought heel, you'll knit the leg and foot, then come back to pick up stitches for heel.

To mark heel placement:
- After completing leg, knit across half the stitches ($((CAST_ON / 2)))
- Replace the stitches you just knit with scrap yarn or waste yarn
- Continue with remaining $((CAST_ON / 2)) stitches

FOOT SECTION (WITHOUT HEEL)
--------
- Continue in stockinette from the waste yarn marker
- Knit around with remaining $((CAST_ON / 2)) stitches
- Continue for approximately $FOOT_LENGTH inches

TOE SECTION
--------
- When foot length is reached, work toe of choice
- Many knitters use wedge toe for afterthought heels

Heel pickup (after foot complete):
- Remove waste yarn from heel marker
- Pick up $HEEL_STITCHES stitches from below and above waste yarn
- You now have approximately $HEEL_STITCHES stitches for heel flap
- Work short row heel as described below:

SHORT ROW HEEL (for afterthought):
- Work back and forth on heel stitches
- Row 1 (RS): Sl1, knit to end
- Row 2 (WS): Sl1, purl to end
- Repeat for approximately $((HEEL_STITCHES * 2 / 3)) rows
- Work short row turns at center of heel
- Graft stitches or bind off when complete

"
            ;;
    esac

    case "$TOE_TYPE" in
        "short row")
            PATTERN_TEXT="${PATTERN_TEXT}TOE (SHORT ROW METHOD)
--------
Short row toe creates a rounded point and is useful for wider feet.

Setup:
- Knit to middle of sole with $CAST_ON stitches
- Begin short rows at center of foot

Toe decreases:
- Turn work and work back across
- Each row, work to 1-2 stitches before the gap
- Wrap stitch and turn
- Continue until limited stitches remain

Finishing:
- Graft remaining 16-20 stitches using Kitchener stitch
- Or bind off if stitches cannot be grafted

"
            ;;
        "wedge")
            PATTERN_TEXT="${PATTERN_TEXT}TOE (WEDGE METHOD)
--------
Wedge toe uses strategic decreases to create a tapered toe.

Setup:
- Work in stockinette until you need to begin toe decreases
- Mark center stitches for decrease points

Decrease rounds:
- Round 1: K1, ssk, knit to last 3 stitches, K2tog, K1 (on each side)
- Round 2: Knit all stitches
- Alternate decrease rounds and knit rounds

Continue until approximately 8-12 stitches remain, then:
- Cut yarn leaving 6-inch tail
- Thread through remaining stitches
- Pull tight and weave in ends

"
            ;;
    esac

    PATTERN_TEXT="${PATTERN_TEXT}
FINISHING INSTRUCTIONS
======================
1. Weave in all ends using yarn needle
2. Wet block if desired for better fit
3. Let dry flat or on sock blocker
4. Try on with shoes you plan to wear

CARE INSTRUCTIONS
=================
- Hand wash in cool water with gentle soap
- Rinse thoroughly
- Gently squeeze out excess water (do not wring)
- Lay flat to dry
- Store in cool, dry place with cedar or moth balls

================================================================================
Pattern generated by Basic Sock Pattern Generator
For updates and more patterns, visit: https://github.com/anthropics/Basic-Sock-Pattern-Generator
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
    # Gather all input
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
    calculate_yardage_needed

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
            calculate_yardage_needed
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

# Run main function if script is executed directly
if [ "${0##*/}" = "sock_pattern_generator.sh" ]; then
    main "$@"
fi
