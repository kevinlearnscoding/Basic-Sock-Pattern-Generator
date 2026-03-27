# 🚀 Quick Start Guide

> Get up and running in 5 minutes! Create your first custom sock pattern now.

---

## ⚡ Less-Than-A-Minute Setup

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
## 🚀 Your First Pattern in 3 Steps

### Step 1: Start the script (details below if you are unfamiliar)
```bash
./sock_pattern_generator.sh
```

### Step 2: Answer the prompts
(Takes ~2-3 minutes, just follow along!)

### Step 3: Review & save
Preview your pattern, make any edits, then save it

**Done!** 🎉 You now have a custom knitting pattern ready to go
---


## 🎯 Running the Script

```bash
./sock_pattern_generator.sh
```

You'll be guided through a friendly, step-by-step process with clear prompts and automatic screen clearing between sections. Total time: ~2-3 minutes to generate a complete pattern!


This invokes the friendly, step-by-step process. Total time: ~2-3 minutes to generate a complete pattern!

---

## 📋 What You Need

| Requirement | Details |
|------------|---------|
| 🖥️ **System** | Any Unix-like system (Linux, macOS, WSL) |
| 🐚 **Shell** | POSIX-compliant (`sh`, `bash`, `zsh`, etc.) |
| 🛠️ **Tools** | `awk`, `clear`, `printf` (usually pre-installed) |
| 📦 **Dependencies** | **None!** |

---

## 🎬 Interactive Session Walkthrough

Here's what happens when you run the script:

```
1. 🦶 Foot Size
   Choose shoe size or enter custom dimensions

2. 📊 Gauge Swatch
   Enter stitches/rows per inch, stitches/rows per given number of centimeters, or enter customer measurments

3. 🎨 Pattern Choices
   Pick leg style, cuff ribbing, toe type, heel construction

4. 📏 Measurements
   Leg length, cuff length

5. 🧶 Yarn Details (Optional)
   Brand, line/weight, color (all fields can be left blank)

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
| **README.md** | 📖 Full documentation & features |
| **API_REFERENCE.md** | 📚 For developers & technical details |
| **BACKEND_INTEGRATION.md** | 🌐 Web backend conversion guide |
| **QUICKSTART.md** | 🚀 This file! |

---

## 💡 Pro Tips for Success

### 📏 **Gauge is Everything**
✓ **Always** make a in-the-round swatch in your actual yarn
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
Install if needed: available from most package managers as "gawk"

### ❌ Calculations seem way off
1. Double-check your gauge measurement
2. Double-check you've selected the correct measurment units (Imperial inches vs metric centimeters)
3. Measure in the center, not edges
4. Try knitting a fresh swatch if unsure

### ❌ Can't save pattern file
Check permissions:
```bash
ls -ld .
```

---

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
