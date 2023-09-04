import sys

def main(argv):
  name = argv[0]
  num_sockets = int(argv[1])

  imem = ""
  s = ""
  for c in range(num_sockets):
    mif_file = "{0}{1}.mif".format(name, c)
    with open(mif_file, 'r') as f:
      lines = f.readlines()
      len_str = "{0}{1}_LEN".format(name.upper(), c)
      s += "#define {0} {1}\n".format(len_str, len(lines))
      for i in range(len(lines)):
        new_line = "0x" + lines[i][:-1] + ",\n"
        imem += new_line
  s += "uint32_t {0}[] = {{\n".format(name)
  s += imem
  s += "};\n"
  print(s)

if __name__ == '__main__':
  main(sys.argv[1:])

