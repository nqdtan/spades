
module store_mask(
  input [3:0]   mem_rw,
  input [1:0]   byte_addr,
  input [31:0]  mem_din,
  output [3:0]  smask_mem_we,
  output [31:0] smask_mem_din
);

  reg [3:0]  smask_mem_we_comb;
  reg [31:0] smask_mem_din_comb;

  assign smask_mem_we  = smask_mem_we_comb;
  assign smask_mem_din = smask_mem_din_comb;

  always @(*) begin
    smask_mem_we_comb  = 4'b0;
    smask_mem_din_comb = 32'b0;
    case (mem_rw)
      4'b1000: begin // SW
        smask_mem_we_comb  = 4'b1111;
        smask_mem_din_comb = mem_din;
      end
      4'b1001: begin // SH
        case (byte_addr)
          2'b00: begin
            smask_mem_we_comb  = 4'b0011;
            smask_mem_din_comb = {16'b0, mem_din[15:0]};
          end
          2'b01: begin
            smask_mem_we_comb  = 4'b0011;
            smask_mem_din_comb = {16'b0, mem_din[15:0]};
          end
          2'b10: begin
            smask_mem_we_comb  = 4'b1100;
            smask_mem_din_comb = {mem_din[15:0], 16'b0};
          end
          2'b11: begin
            smask_mem_we_comb  = 4'b1100;
            smask_mem_din_comb = {mem_din[15:0], 16'b0};
          end
        endcase
      end
      4'b1010: begin // SB
        case (byte_addr)
          2'b00: begin
            smask_mem_we_comb  = 4'b0001;
            smask_mem_din_comb = {24'b0, mem_din[7:0]};
          end
          2'b01: begin
            smask_mem_we_comb  = 4'b0010;
            smask_mem_din_comb = {16'b0, mem_din[7:0], 8'b0};
          end
          2'b10: begin
            smask_mem_we_comb  = 4'b0100;
            smask_mem_din_comb = {8'b0, mem_din[7:0], 16'b0};
          end
          2'b11: begin
            smask_mem_we_comb  = 4'b1000;
            smask_mem_din_comb = {mem_din[7:0], 24'b0};
          end
        endcase
      end
    endcase
  end

endmodule
