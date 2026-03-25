# Basic-Sock-Pattern-Generator

A POSIX-compliant shell script that generates customized knitting patterns for basic socks. Users can specify foot measurements, gauge, pattern preferences, yarn details, and needle specifications to receive a complete knitting pattern with detailed instructions.

## Features

- **Flexible Input Methods**: Enter foot size via shoe size (US Women's/Men's) or custom dimensions
- **Gauge Options**: Input gauge as stitches/rows per inch or per custom measurement
- **Pattern Customization**:
  - Leg pattern: Stockinette or Ribbing (1x1 or 2x2)
  - Toe construction: Short Row or Wedge
  - Heel construction: Short Row or Afterthought
  - Custom leg and cuff lengths
- **Yarn & Needle Details**: Track brand, weight, color/dye lot, yardage, and needle specifications
- **Smart Calculations**: Automatically calculates cast-on stitches, stitch counts, and estimated yardage
- **Review & Edit**: Review all selections before generating pattern with ability to make changes
- **Flexible Output**: Display pattern on screen, save to file, or both
- **POSIX Compliant**: Runs on any POSIX-compliant shell (sh, bash, zsh, ksh, etc.)
- **Platform Independent**: Works on Linux, macOS, WSL, and other Unix-like systems
- **Backend-Ready**: Modular architecture designed for web application integration

## Requirements

- POSIX-compliant shell (`sh`, `bash`, `zsh`, `ksh`, etc.)
- `awk` command for arithmetic calculations (standard POSIX utility)
- Basic Unix utilities (`clear`, `read`, `printf`)

## Installation

```bash
# Clone or download the repository
cd /path/to/Basic-Sock-Pattern-Generator

# Make script executable
chmod +x sock_pattern_generator.sh
```

## Quick Start

```bash
./sock_pattern_generator.sh
```

Follow the interactive prompts to enter your sock specifications. The script will:
1. Gather measurements and preferences
2. Calculate stitch counts automatically
3. Display a summary for review
4. Let you make changes if needed
5. Generate a complete knitting pattern
6. Save the pattern as a text file or display it on screen

## Usage Guide

### Input Prompts

**Foot Size**
- Choose between US Women's shoe size, US Men's shoe size, or enter custom dimensions
- Script converts shoe size to foot length and circumference estimates

**Gauge Information**
- Enter as stitches/rows per inch (standard) or per custom measurement width
- This is critical for accurate stitch counts—use an actual swatch!

**Pattern Choices**
- Leg pattern: Stockinette (smooth) or Ribbing (1x1 or 2x2 patterns)
- Toe: Short Row (wrap-and-turn) or Wedge (decrease-based)
- Heel: Short Row (wrap-and-turn) or Afterthought (pick up later)

**Lengths**
- Leg length: From cuff to heel (typically 6-10 inches)
- Cuff length: Elastic band at top (typically 1-2 inches for ribbing)

**Yarn Details**
- Brand, weight (fingering, sport, DK, etc.), color/dye lot
- Total yardage available

**Needle Specifications**
- Size (US or mm), working method (DPNs, Magic Loop, or Short Circulars)

### Review Process

After entering all information:
1. Screen displays complete summary of all choices
2. Confirm to proceed or make changes
3. Can edit individual sections without re-entering everything
4. Once confirmed, pattern is generated

### Output Options

- **Display**: View pattern in terminal
- **Save**: Write to text file (you choose filename)
- **Both**: Display and save

## Pattern Output Contents

Generated patterns include:

- Project details (yarn info, needles used)
- Measurements and calculated gauge impact
- All stitch counts (cast-on, by section, totals)
- Step-by-step instructions for each section:
  - **Cuff**: Ribbing setup and rounds
  - **Leg**: Pattern instructions and round counts
  - **Heel**: Detailed wrap-and-turn instructions (short row) or setup (afterthought)
  - **Foot**: From heel to toe opening
  - **Toe**: Complete decoration instructions with Kitchener stitch finishing
- Finishing techniques (weaving in ends, blocking, care)
- Estimated yardage requirements
- Care instructions for finished socks

## Technical Details

### Calculation Formulas

```
Cast-on stitches = (foot circumference × SPI) / gauge width
Leg rounds = (leg length × RPI) / gauge height
Cuff rounds = (cuff length × RPI) / gauge height
```

Where SPI = stitches per inch, RPI = rows per inch

### Shoe Size Conversion

- **US Women's**: Foot length = 8.125 + (size × 0.3125) inches
- **US Men's**: Foot length = 8.375 + (size × 0.3125) inches

### Script Architecture

Organized into functional sections:

- **Utility Functions**: Screen management, headers, pauses
- **Input Functions**: `get_foot_size()`, `get_gauge()`, etc.
- **Calculation Functions**: `calculate_cast_on()`, etc.
- **Review Functions**: Summary display and edit flow
- **Generation Functions**: Pattern creation and output
- **Main Flow**: Orchestration of entire process

## Examples

### Women's Size 8 with DK Yarn

```
Size: US Women's 8 (9.5" length, 8" circumference)
Gauge: 5 SPI, 6.5 RPI (typical for DK weight)
Pattern: Stockinette leg, 1x1 ribbed cuff
Toe: Wedge | Heel: Short Row
Needle: US 4 (3.5mm) Magic Loop
Leg: 8 inches | Cuff: 2 inches
```

Result: ~180-200 stitches cast-on, approximately 900-1000 yards needed for pair

### Child's Sock with Colorwork Yarn

```
Size: US Women's 5 (8" length, 6.5" circumference)
Gauge: 7 SPI, 9 RPI (Fingering weight)
Pattern: 2x2 ribbed leg, stockinette elsewhere
Toe: Short Row | Heel: Afterthought
Needle: US 2 (2.75mm) DPNs
Leg: 6 inches | Cuff: 1.5 inches
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Script won't run | `chmod +x sock_pattern_generator.sh` |
| Calculations incorrect | Verify `awk` is available: `which awk` |
| Incorrect calculations | Verify gauge swatch (4"×4" minimum), re-measure carefully |
| Can't save files | Check directory permissions and available disk space |
| Color codes appear in saved file | This is normal; if using purely for backend, colors can be disabled |

## POSIX Compliance

This script uses only POSIX-compliant features:
- Standard shell built-ins only
- No bash-specific features (arrays, extended globs, etc.)
- Compatible with `sh`, `bash`, `zsh`, `ksh`, `dash`

Verify with: `sh -n sock_pattern_generator.sh`

## Backend Integration for Web Version

The script is designed with backend integration in mind. Key modular components:

- **Input Validation**: Functions can be extracted for API endpoints
- **Calculations**: Pure functions with no side effects—easily wrapped for REST/GraphQL
- **Pattern Generation**: Template-based—can be adapted for PDF, HTML, or other formats
- **Output**: Flexible—can generate JSON, plain text, or formatted HTML

See included documentation for web framework integration details.

## File Structure

```
Basic-Sock-Pattern-Generator/
├── sock_pattern_generator.sh   # Main script
├── README.md                    # This file
├── LICENSE                      # MIT License
├── Generator/                   # Sample output patterns (created when you save)
└── [generated patterns].txt     # Your created patterns
```

## Limitations & Future Enhancements

### Current Limitations
- Basic sock construction (no lace, colorwork, or complex stitches yet)
- Single pair per pattern generation
- Approximate yardage estimates
- No calf shaping or advanced shaping options

### Planned Features
- Lace pattern options with charts
- Colorwork/stranded knitting support
- Bulk knitting calculator (multiple pairs/sizes)
- Python REST API backend
- HTML/React frontend
- PDF pattern export with diagrams
- Pattern library management
- German short rows and additional heel/toe variations

## Contributing

Bug reports, feature requests, and contributions welcome!

## License

MIT License - See LICENSE file for full terms
