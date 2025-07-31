from PIL import Image
import argparse
import math

# Default CC: Tweaked palette (https://tweaked.cc/module/colors.html)
DEFAULT_PALETTE = [
    (0xF0, 0xF0, 0xF0),  # 0: white
    (0xF2, 0xB2, 0x33),  # 1: orange
    (0xE5, 0x7F, 0xD8),  # 2: magenta
    (0x99, 0xB2, 0xF2),  # 3: light blue
    (0xDE, 0xDE, 0x6C),  # 4: yellow
    (0x7F, 0xCC, 0x19),  # 5: lime
    (0xF2, 0xB2, 0xCC),  # 6: pink
    (0x4C, 0x4C, 0x4C),  # 7: gray
    (0x99, 0x99, 0x99),  # 8: light gray
    (0x4C, 0x99, 0xB2),  # 9: cyan
    (0xB2, 0x66, 0xE5),  # A: purple
    (0x33, 0x66, 0xCC),  # B: blue
    (0x7F, 0x66, 0x4C),  # C: brown
    (0x57, 0xA6, 0x4E),  # D: green
    (0xCC, 0x4C, 0x4C),  # E: red
    (0x19, 0x19, 0x19)   # F: black
]

def load_palette(filename):
    palette = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split(',')
            if len(parts) < 3:
                continue
            try:
                r = int(parts[0])
                g = int(parts[1])
                b = int(parts[2])
                palette.append((r, g, b))
            except ValueError:
                continue
    return palette

def color_distance(c1, c2):
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(c1, c2)))

def find_closest_color(pixel, palette):
    min_distance = float('inf')
    best_index = 0
    for i, color in enumerate(palette):
        dist = color_distance(pixel, color)
        if dist < min_distance:
            min_distance = dist
            best_index = i
    return best_index

def convert_to_nfp(input_path, output_path, palette_file=None):
    # Load palette
    palette = DEFAULT_PALETTE
    if palette_file:
        custom_palette = load_palette(palette_file)
        if len(custom_palette) >= 16:
            palette = custom_palette[:16]
        else:
            print(f"Warning: Palette file contains only {len(custom_palette)} colors, using default")
    
    # Load image and convert to RGBA
    img = Image.open(input_path).convert('RGBA')
    width, height = img.size
    pixels = img.load()
    
    # Convert image to NFP
    nfp_lines = []
    for y in range(height):
        line = []
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a < 50:  # Transparent pixel
                line.append(' ')
            else:
                index = find_closest_color((r, g, b), palette)
                hex_char = format(index, 'X')  # Convert to hex digit (0-9, A-F)
                line.append(hex_char)
        nfp_lines.append(''.join(line))
    
    # Write to output file
    with open(output_path, 'w') as f:
        f.write('\n'.join(nfp_lines))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert images to NFP format')
    parser.add_argument('input', help='Input image file path')
    parser.add_argument('output', help='Output NFP file path')
    parser.add_argument('--palette', help='Optional palette file path')
    args = parser.parse_args()
    
    convert_to_nfp(args.input, args.output, args.palette)
    print(f"Conversion complete! Saved to {args.output}")