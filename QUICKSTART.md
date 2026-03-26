# 🚀 Quick Start Guide

> Get up and running in 5 minutes! Create your first custom sock pattern now.

---

## ⚡ 5-Minute Setup

### Step 1️⃣: Make It Executable

```bash
chmod +x sock_pattern_generator.sh
```

### Step 2️⃣: Verify It Works (Optional)

```bash
sh -n sock_pattern_generator.sh
```

If you see no errors, you're good to go! ✅

---

## 🎯 Running the Script

### 🎨 Interactive Mode (Recommended) ⭐

```bash
./sock_pattern_generator.sh
```

You'll be guided through a friendly, step-by-step process with clear prompts and automatic screen clearing between sections. Total time: ~2-3 minutes to generate a complete pattern!

### 🧪 Test Drive Mode

Want to see it in action without filling out forms?

```bash
./test_pattern_generator.sh
```

This runs automated tests showing calculations for different sock sizes and yarn weights. Great for understanding how it works!

---

## 📋 What You Need

| Requirement | Details |
|------------|---------|
| 🖥️ **System** | Any Unix-like system (Linux, macOS, WSL) |
| 🐚 **Shell** | POSIX-compliant (`sh`, `bash`, `zsh`, etc.) |
| 🛠️ **Tools** | `awk`, `clear`, `printf` (usually pre-installed) |
| 📦 **Dependencies** | **None!** No `bc`, no npm, no pip needed 🎉 |

---

## 🎬 Interactive Session Walkthrough

Here's what happens when you run the script:

```
1. 🦶 Foot Size
   Choose shoe size or enter custom dimensions

2. 📊 Gauge Swatch
   Enter stitches/rows per inch

3. 🎨 Pattern Choices
   Pick leg style, toe type, heel construction

4. 📏 Measurements
   Leg length, cuff length

5. 🧶 Yarn Details
   Brand, weight, color, yardage

6. 🪡 Needles
   Size and working method (DPNs, Magic Loop, Circulars)

7. 👀 Review
   Check everything looks good

8. ✏️ Edit (Optional)
   Change anything without re-entering everything

9. 📖 Generate
   Pattern created instantly!

10. 💾 Output
    Display on screen, save to file, or both
```

---

## 📦 Project Files Explained

| File | Purpose |
|------|---------|
| **sock_pattern_generator.sh** | 🎯 Main script - Run this to generate patterns |
| **test_pattern_generator.sh** | 🧪 Test suite - See it in action |
| **README.md** | 📖 Full documentation & features |
| **API_REFERENCE.md** | 📚 For developers & technical details |
| **BACKEND_INTEGRATION.md** | 🌐 Web backend conversion guide |
| **QUICKSTART.md** | 🚀 This file! |

---

## 📖 Real-World Examples

### 👩 Adult Women's Pattern
```
Shoe Size: US Women's 8
Gauge: 7 stitches/inch (Fingering weight)
Pattern: Stockinette leg, 1x1 ribbed cuff
Toe: Wedge | Heel: Short row
Result: ➜ 56 stitch cast-on, ~75 yards needed
```

✨ Perfect for most fingering-weight yarns!

### 👨 Adult Men's Pattern
```
Shoe Size: US Men's 10
Gauge: 5 stitches/inch (DK weight)
Pattern: 2x2 ribbed leg (more stretch!)
Toe: Short row | Heel: Afterthought
Result: ➜ ~44 stitches, ~100 yards needed
```

✨ Great for DK/sport weight comfort socks!

### 👧 Child's Pattern
```
Custom: 7.5" length, 6.5" circumference
Gauge: 8 stitches/inch over 2 inches
Pattern: 1x1 ribbing (snug and fun!)
Result: ➜ ~26 stitches, ~50 yards needed
```

✨ Perfect for using up yarn scraps!

---

## 💡 Pro Tips for Success

### 📏 **Gauge is Everything**
✓ **Always** make a 4"×4" swatch in your actual yarn
✓ Measure in the center (edges are unreliable)
✓ Different yarns = different gauges (even same weight!)
✓ Spend 5 minutes here to save hours of frustration later

### 🧪 **Test First**
✓ Knit a small swatch of each section (cuff, leg, toe)
✓ Try on as you go
✓ Better to adjust early than unravel a whole sock!

### 📝 **Keep Notes**
✓ Save your favorite gauge for each yarn
✓ Note what worked and what didn't
✓ Build your own pattern library over time
✓ Share with knitting buddies!

---

## 🐛 Quick Troubleshooting

### ❌ "Permission denied" when running script
```bash
chmod +x sock_pattern_generator.sh
```

### ❌ Script won't start
Try running with `sh` explicitly:
```bash
sh sock_pattern_generator.sh
```

### ❌ "awk: command not found"
Check if awk is available:
```bash
which awk
```
Install if needed: `sudo apt install gawk` (Linux) or `brew install gawk` (macOS)

### ❌ Calculations seem way off
1. Double-check your gauge measurement
2. Use a proper 4"×4" swatch
3. Measure in the center, not edges
4. Try knitting a fresh swatch if unsure

### ❌ Can't save pattern file
Check permissions:
```bash
ls -ld .
```

---

## 🚀 Your First Pattern in 3 Steps

### Step 1: Start the script
```bash
./sock_pattern_generator.sh
```

### Step 2: Answer the prompts
(Takes ~2-3 minutes, just follow along!)

### Step 3: Review & save
Preview your pattern, make any edits, then save it

**Done!** 🎉 You now have a custom knitting pattern ready to go

---

## 📚 What's Next?

### 🎯 Ready to knit?
- Print or view your pattern file
- Cast on those stitches!
- Enjoy hand-knit custom socks 🧦

### 👥 Want to share?
- Email patterns to knitting friends
- Post on social media
- Create a collection for your circle

### 🔍 Need more details?
- 📖 **Full docs** → See [README.md](README.md)
- 🏗️ **Technical** → Check [API_REFERENCE.md](API_REFERENCE.md)
- 🌐 **Backend?** → Read [BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md)

### 🛠️ Want to customize?
See BACKEND_INTEGRATION.md for guidance on:
- Adding new heel/toe techniques
- Creating lace pattern options
- Building a web interface
- Contributing enhancements

---

## 🎓 Learning Resources

### About Sock Construction
- **Short Row Heel**: Creates a heel using wrap-and-turn stitches
- **Afterthought Heel**: Knit the foot first, come back to pick up heel stitches later
- **Wedge Toe**: Use strategic decreases to create a tapered toe
- **Short Row Toe**: Similar to heel, creates a rounded point

All techniques are fully explained in your generated pattern! ✨

### About Gauge
- **SPI** (Stitches Per Inch): Count stitches in 1 inch of your swatch
- **RPI** (Rows Per Inch): Count rows in 1 inch of your swatch
- **Why it matters**: Gauge determines how many stitches you need to cast on
- **Rule**: More stitches per inch = smaller socks, fewer stitches = larger socks

---

<div align="center">

## 🧦 Ready to Knit?

### Your journey starts with one command:

```bash
./sock_pattern_generator.sh
```

---

**Have fun creating beautiful custom socks!** 🧶✨

Questions? Read the [full README](README.md)

</div>
