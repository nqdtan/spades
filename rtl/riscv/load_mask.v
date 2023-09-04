
module load_mask (
  input  [3:0]  mem_rw,
  input  [1:0]  byte_addr,
  input  [31:0] mem_dout,
  output [31:0] lmask_mem_dout
);
  reg [31:0] lmask_mem_dout_comb;
  assign lmask_mem_dout = lmask_mem_dout_comb;

  always @(*) begin
    lmask_mem_dout_comb = 32'b0;
    case (mem_rw)
      4'b0000: begin // LW
        lmask_mem_dout_comb = mem_dout;
      end
      4'b0001: begin // LH
        case (byte_addr)
          2'b00: lmask_mem_dout_comb = {{16{mem_dout[15]}}, mem_dout[15:0]};
          2'b01: lmask_mem_dout_comb = {{16{mem_dout[15]}}, mem_dout[15:0]};
          2'b10: lmask_mem_dout_comb = {{16{mem_dout[31]}}, mem_dout[31:16]};
          2'b11: lmask_mem_dout_comb = {{16{mem_dout[31]}}, mem_dout[31:16]};
        endcase
      end
      4'b0010: begin // LB
        case (byte_addr)
          2'b00: lmask_mem_dout_comb = {{24{mem_dout[7]}},  mem_dout[7:0]};
          2'b01: lmask_mem_dout_comb = {{24{mem_dout[15]}}, mem_dout[15:8]};
          2'b10: lmask_mem_dout_comb = {{24{mem_dout[23]}}, mem_dout[23:16]};
          2'b11: lmask_mem_dout_comb = {{24{mem_dout[31]}}, mem_dout[31:24]};
        endcase
      end
      4'b0011: begin // LHU
        case (byte_addr)
          2'b00: lmask_mem_dout_comb = {16'b0, mem_dout[15:0]};
          2'b01: lmask_mem_dout_comb = {16'b0, mem_dout[15:0]};
          2'b10: lmask_mem_dout_comb = {16'b0, mem_dout[31:16]};
          2'b11: lmask_mem_dout_comb = {16'b0, mem_dout[31:16]};
        endcase
      end
      4'b0100: begin // LBU
        case (byte_addr)
          2'b00: lmask_mem_dout_comb = {24'b0, mem_dout[7:0]};
          2'b01: lmask_mem_dout_comb = {24'b0, mem_dout[15:8]};
          2'b10: lmask_mem_dout_comb = {24'b0, mem_dout[23:16]};
          2'b11: lmask_mem_dout_comb = {24'b0, mem_dout[31:24]};
        endcase
      end
    endcase
  end

endmodule

