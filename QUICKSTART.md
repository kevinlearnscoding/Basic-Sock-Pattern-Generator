# Quick Start Guide

## Installation & Setup

```bash
# Make the script executable
chmod +x sock_pattern_generator.sh

# Verify POSIX compliance
sh -n sock_pattern_generator.sh
```

## Running the Script

### Interactive Mode (Recommended)
```bash
./sock_pattern_generator.sh
```

You'll be guided through creating a custom sock pattern step-by-step with clear instructions and screen clearing between sections.

### Testing (Without Interactive Input)
```bash
./test_pattern_generator.sh
```

This runs automated tests demonstrating calculations for different sock sizes and yarn weights.

## File Descriptions

- **sock_pattern_generator.sh** - Main POSIX shell script (900+ lines)
- **test_pattern_generator.sh** - Automated test suite
- **README.md** - Full documentation and feature overview
- **API_REFERENCE.md** - Detailed function documentation for developers
- **BACKEND_INTEGRATION.md** - Guide for converting to web backend
- **QUICKSTART.md** - This file

## What You Need

- Any Unix-like system (Linux, macOS, WSL, etc.)
- A POSIX-compliant shell (`sh`, `bash`, `zsh`, etc.)
- Standard utilities (`awk`, `clear`, `printf`) - usually included

Note: No external tools like bc required!

## Basic Usage Example

1. Start the script
2. Choose your foot size (Women's size 8 → 9.5" length)
3. Enter gauge (7 stitches per inch is common for fingering weight)
4. Choose patterns (Stockinette leg, Wedge toe, Short row heel)
5. Enter leg length (8 inches) and cuff length (2 inches)
6. Enter yarn details (brand, weight, color)
7. Specify needles (US 1, Magic Loop)
8. Review your choices
9. Generate the pattern
10. Display, save, or both

## Output

The script generates a complete knitting pattern including:
- Stitch counts (automatically calculated from gauge)
- Step-by-step instructions for each section
- Specific techniques (short rows, wedge decreases)
- Finishing instructions
- Yarn care recommendations

Patterns can be displayed on screen or saved as `.txt` files.

## Example Scenarios

### Quick Test Pattern
```
Shoe Size: US Women's 8
Gauge: 7 stitches/inch (Fingering weight typical)
Pattern: Stockinette leg, 1x1 cuff
Heel: Short row | Toe: Wedge
Result: 56 stitch cast-on, ~75 yards estimated
```

### Larger Adult Socks
```
Shoe Size: US Men's 10
Gauge: 5 stitches/inch (DK weight)
Pattern: 2x2 ribbed leg
Heel: Afterthought | Toe: Short row
Result: ~44 stitches, ~100 yards estimated
```

### Child's Socks
```
Custom: 7.5" foot length, 6.5" circumference
Gauge: 8 stitches/inch over 2 inches (tight gauge)
Pattern: 1x1 ribbing
Result: ~26 stitches, ~50 yards estimated
```

## Tips for Accurate Patterns

1. **Make a Gauge Swatch**: Knit a 4"×4" swatch in the yarn you'll use
2. **Measure Correctly**: Count stitches and rows in the center of your swatch
3. **Try It On**: Always knit a test sample before committing to a full pattern
4. **Keep Notes**: Save what works - different yarns may need gauge adjustments

## Customization

The script can easily be modified for:
- Additional toe/heel techniques
- Different pattern stitches (add to pattern templates)
- Multi-size generation
- Output in different formats

See BACKEND_INTEGRATION.md for guidance on extending functionality.

## Troubleshooting

**Script won't run:**
```bash
chmod +x sock_pattern_generator.sh
sh sock_pattern_generator.sh  # Try with sh explicitly
```

**Calculations seem off:**
- Verify you measured gauge on a proper swatch
- Check that `awk` is available: `which awk`
- Review the pattern math in README.md

**Can't save files:**
- Check directory permissions: `ls -ld .`
- Verify disk space: `df -h`

## Next Steps

1. ✅ Try running the script interactively
2. ✅ Generate your first custom sock pattern
3. ✅ Save a pattern and knit from it
4. ✅ Share patterns with other knitters
5. 🔜 (Future) Contribute enhancements on GitHub

---

For detailed developer information, see BACKEND_INTEGRATION.md
