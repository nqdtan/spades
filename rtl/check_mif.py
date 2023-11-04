import sys
from ctypes import *

def main(argv):
  lines1 = []
  lines2 = []

  word_width = 64
  data_width = 512
  scale = int(data_width / word_width)

  with open(argv[0], 'r') as f:
    lines1 = f.readlines()

  with open(argv[1], 'r') as f:
    lines2 = f.readlines()

  verify_len = min(int(argv[2]), len(lines2))
  test_float = argv[3] == "float"

  num_mismatches = 0
  for i in range(int(verify_len / scale)):
    # Python string: MSB -> LSB
    for j in range(scale):
      d1 = int(lines1[i][j*16:(j+1)*16], base=16)
      d2 = int(lines2[i * scale + scale - 1 - j], base=16)

      if test_float is True:
        tmp10 = d1 & 0xffffffff
        tmp20 = d2 & 0xffffffff
        tmp11 = (d1 >> 32) & 0xffffffff
        tmp21 = (d2 >> 32) & 0xffffffff
        tmp10_fp = cast(pointer(c_int(tmp10)), POINTER(c_float)).contents.value
        tmp20_fp = cast(pointer(c_int(tmp20)), POINTER(c_float)).contents.value
        tmp11_fp = cast(pointer(c_int(tmp11)), POINTER(c_float)).contents.value
        tmp21_fp = cast(pointer(c_int(tmp21)), POINTER(c_float)).contents.value

        EPS = 1e-3
        if abs(tmp10_fp - tmp20_fp) > EPS or abs(tmp11_fp - tmp21_fp) > EPS:
          num_mismatches += 1
          print("[{}] Mismatch: out={} ref={}".format(i * scale + scale - 1 - j, hex(d1), hex(d2)))
          print(tmp10_fp, "====", tmp20_fp, "=== diff", abs(tmp10_fp - tmp20_fp))
          print(tmp11_fp, "====", tmp21_fp, "=== diff", abs(tmp11_fp - tmp21_fp))
      else:
        if d1 != d2:
          num_mismatches += 1
          print("[{}] Mismatch: out={} ref={}".format(i * scale + scale - 1 - j, hex(d1), hex(d2)))

  if num_mismatches == 0:
    print("PASSED!")
  else:
    print("FAILED! Num. mismatches: {}".format(num_mismatches))

if __name__ == '__main__':
  main(sys.argv[1:])
