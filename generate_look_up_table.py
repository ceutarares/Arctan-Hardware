import math

BITS = 32
ROM_DEPTH = 1024

MAX_VAL_32 = 2 ** BITS - 1

SCALE_FACTOR = (2 ** (BITS - 1)) / math.pi

print(f"Generating {ROM_DEPTH} entries for {BITS}-bit ROM...")
print("-" * 20)
print("constant LUT_ROM : rom_type := (")

for i in range(ROM_DEPTH):
    x_val = i / (ROM_DEPTH - 1)
    angle_rad = math.atan(x_val)
    fixed_val = int(angle_rad * SCALE_FACTOR)
    hex_str = f'x"{fixed_val:08X}"'
    comma = "," if i < ROM_DEPTH - 1 else ""
    print(f"    {hex_str}{comma} -- i={i} (x={x_val:.2f}, ang={angle_rad:.4f})")

print(");")
