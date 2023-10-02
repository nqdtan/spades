import sys


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
  num_mismatches = 0
  for i in range(int(verify_len / scale)):
    # Python string: MSB -> LSB
    for j in range(scale):
      #print("result", lines1[i][j*16:(j+1)*16])
      #print("gold  ", lines2[i * scale + scale - 1 - j])
      d1 = hex(int(lines1[i][j*16:(j+1)*16], base=16))
      d2 = hex(int(lines2[i * scale + scale - 1 - j], base=16))
      if d1 != d2:
        num_mismatches += 1
        print("[{}] Mismatch: out={} ref={}".format(i * scale + scale - 1 - j, d1, d2))

  if num_mismatches == 0:
    print("PASSED!")
  else:
    print("FAILED! Num. mismatches: {}".format(num_mismatches))

if __name__ == '__main__':
  main(sys.argv[1:])

