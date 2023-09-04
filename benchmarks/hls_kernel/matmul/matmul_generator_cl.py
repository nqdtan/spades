import sys

def main(argv):
  bha = int(argv[0])
  bwa = int(argv[1])
  bwb = int(argv[2])

  code = ""

  code += """
#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>

#define BHA {0}
#define BWA {1}
#define BWB {2}
""".format(bha, bwa, bwb)

  code += "void cl_matmul(\n"

  for i in range(int(bwa/2)):
    code += "  int64_t local_a{0}[BHA][2],\n".format(i)

  for i in range(int(bwa/2)):
    code += "  int64_t local_b{0}[2][BWB],\n".format(i)

  code += """
  int64_t local_c0[BHA][BWB/4],
  int64_t local_c1[BHA][BWB/4],
  int64_t local_c2[BHA][BWB/4],
  int64_t local_c3[BHA][BWB/4],
  int len, int pp) {
"""

  for i in range(int(bwa/2)):
    code += "#pragma HLS INTERFACE mode=ap_memory port=local_a{0} latency=3\n".format(i)

  for i in range(int(bwa/2)):
    code += "#pragma HLS INTERFACE mode=ap_memory port=local_b{0} latency=3\n".format(i)

  code += """
#pragma HLS INTERFACE mode=ap_memory port=local_c0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c3 latency=3

  int ii = 0;
  int jj = 0;
  for (int iijj = 0; iijj < BHA * BWB; iijj++) {
    #pragma HLS PIPELINE
    #pragma HLS DEPENDENCE variable=local_c0 inter false
    #pragma HLS DEPENDENCE variable=local_c1 inter false
    #pragma HLS DEPENDENCE variable=local_c2 inter false
    #pragma HLS DEPENDENCE variable=local_c3 inter false

    int ii = iijj / BWB;
    int jj = iijj % BWB;
    int64_t tmp = jj % 4 == 0 ? local_c0[ii][jj/4] :
                  jj % 4 == 1 ? local_c1[ii][jj/4] :
                  jj % 4 == 2 ? local_c2[ii][jj/4] :
                                local_c3[ii][jj/4];

    for (int t = 0; t < 2; t++) {
"""
  for i in range(int(bwa/2)):
    code += "      int64_t tmp_local_a{0} = local_a{0}[ii][t];\n".format(i)
  for i in range(int(bwa/2)):
    code += "      int64_t tmp_local_b{0} = local_b{0}[t][jj];\n".format(i)
  for i in range(int(bwa/2)):
    code += "      tmp += (len <= 2*{0}) ? 0 : tmp_local_a{0} * tmp_local_b{0};\n".format(i)
  code += """
    }
    if (jj % 4 == 0)
      local_c0[ii][jj/4] = tmp;
    else if (jj % 4 == 1)
      local_c1[ii][jj/4] = tmp;
    else if (jj % 4 == 2)
      local_c2[ii][jj/4] = tmp;
    else
      local_c3[ii][jj/4] = tmp;
  }
}
"""

  print(code)

if __name__ == '__main__':
    main(sys.argv[1:])
