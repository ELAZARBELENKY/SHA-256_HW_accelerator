`timescale 1ns / 1ps
import sha256_pkg::right_rotate;
import sha256_pkg::k;

module sha256_round(input [31:0] word,
                    input [31:0] state [7:0],
                    input [5:0] round_index,
                    output logic [31:0] new_state [7:0]);

  logic [32-1:0] temp1 ,temp2, choice, majority, sum0, sum1;
  
 /*  state[7]=a   state[6]=b   state[5]=c   state[4]=d
     state[3]=e   state[2]=f   state[1]=g   state[0]=h  */  

  assign choice = (state[3] & state[2]) ^ (~state[3] & state[1]);
  assign majority = (state[7] & state[6]) ^ (state[7] & state[5]) ^
                    (state[6] & state[5]);
  assign sum0 = right_rotate(state[7], 5'd2) ^ right_rotate(state[7], 5'd13) ^
                right_rotate(state[7], 5'd22);
  assign sum1 = right_rotate(state[3], 5'd6) ^ right_rotate(state[3], 5'd11) ^
                right_rotate(state[3], 5'd25);
  assign temp1 = state[0] + sum1 + choice + k[round_index] + word;
  assign temp2 = sum0 + majority;
  
  assign new_state[6:4] = state[7:5]; //assigning b,c,d (to be previous-state's a,b,c)
  assign new_state[2:0] = state[3:1]; //assigning f,g,h (to be previous-state's e,f,g)
  assign new_state[7] = temp1 + temp2;
  assign new_state[3] = temp1 + state[4];

endmodule
