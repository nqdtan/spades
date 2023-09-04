import sys


def main(argv):
  lines = []
  removeIndices = []
  with open(argv[0], 'r') as f:
    lines = f.readlines()

  for i in range(len(lines)):
    if "\"DestId\": 0" in lines[i]:
      #print(lines[i])
      if "top_i/ulp/socket" not in lines[i - 1]:
        continue
      removeIndices.append(i)
      removeIndices.append(i + 1)
      removeIndices.append(i - 1)
      removeIndices.append(i - 2)
      removeIndices.append(i - 3)

  with open("tmp.ncr", 'w') as f:
    for i in range(len(lines)):
      if i in removeIndices:
        #print(lines[i])
        continue
      f.write(lines[i])
   
if __name__ == '__main__':
  main(sys.argv[1:])

