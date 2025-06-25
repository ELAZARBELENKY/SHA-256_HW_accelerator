`timescale 1ns / 1ps
import sha256_pkg::right_rotate;

module sha256_expansion ( input [3:0] round_index,
                          input [31:0] w[15:0],
                          output logic [31:0] expanded_word);

  logic [32-1:0] s0,s1;
  
  assign s0 = right_rotate(w[(round_index-15)%16], 5'd7) ^
              right_rotate(w[(round_index-15)%16], 5'd18) ^
              (w[(round_index-15)%16] >> 2'h3);

  assign s1 = right_rotate(w[(round_index-2)%16], 5'd17) ^
              right_rotate(w[(round_index-2)%16], 5'd19) ^
              (w[(round_index-2)%16] >> 4'ha);

  assign expanded_word = (w[round_index] + s0 + w[(round_index-7)%16] + s1);
endmodule