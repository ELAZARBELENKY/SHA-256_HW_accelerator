`timescale 1ns / 1ps
import sha256_pkg::standard_initial_state;

module sha256_main( input clk,
                    input resetn,
                    input s_axis_tlast,
                    input s_axis_tvalid,
                    input [31:0] s_axis_tdata,
                    input m_axis_tready,
                    output logic [31:0] m_axis_tdata,
                    output logic s_axis_tready = 0,
                    output logic m_axis_tvalid = 0,
                    output logic m_axis_tlast = 0);

  logic [31:0] word, expanded_word, w[15:0];
  logic [31:0] state[7:0];
  logic [31:0] new_state[7:0];
  logic [31:0] initial_state[7:0];
  logic [5:0]  round_index = '0;
  logic chunk_end = 0;
  logic [31:0] sha[7:0];
  logic [2:0] result_ptr = 0;
  enum logic [1:0] {RECEIVE_DATA, FINISH_CALC, SEND_RESULT} state_t = RECEIVE_DATA;
  
  //instantiations
  // Round calculation
  sha256_round round (
  .word(word),
  .state(state),
  .round_index(round_index),
  .new_state(new_state) );

  // Message schedule expansion
  sha256_expansion expand (
  .round_index(round_index[3:0]),
  .w(w),
  .expanded_word(expanded_word) );
  
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      state_t <= RECEIVE_DATA;
      result_ptr <= 0;
      s_axis_tready <= 0;
      m_axis_tvalid <= 0;
      m_axis_tlast <= 0;
      chunk_end <= 0;
      round_index <= '0;
      initial_state <= standard_initial_state;
      state <= standard_initial_state;
    end else begin
      case (state_t)
        RECEIVE_DATA: begin
          s_axis_tready <= round_index[5:4] == 2'b00 && round_index != 15;
          if (s_axis_tvalid && s_axis_tready || chunk_end || round_index[5:4] != 2'h0) begin
            if (chunk_end) begin
              foreach (state[i]) begin
                initial_state[i] <= initial_state[i] + state[i];
                state[i] <= initial_state[i] + state[i];
              end
              chunk_end <= 1'b0;
            end else begin
              w[round_index[3:0]] <= word;
              state <= new_state;
              round_index <= round_index + 6'b1;
              if (round_index[5:4] == 2'b00) begin
                if (s_axis_tlast) begin
                  state_t <= FINISH_CALC;
                  s_axis_tready <= 0;
                end
                chunk_end <= 1'b0;
              end else if (round_index == 6'd63) chunk_end <= 1'b1;
            end
          end
        end
        FINISH_CALC: begin
          if (round_index != 6'd0) begin
            w[round_index[3:0]] <= word;
            state <= new_state;
            round_index <= round_index + 6'b1;
          end else begin
            foreach (sha[i]) sha[i] <= initial_state[i] + state[i];
            m_axis_tdata <= initial_state[7] + state[7];
            m_axis_tvalid <= 1;
            state_t <= SEND_RESULT;
            result_ptr <= 7;            
            m_axis_tlast <= 0;
          end
        end
        SEND_RESULT: begin
          if (m_axis_tvalid && m_axis_tready) begin
            if (result_ptr == 3'd0) begin
              m_axis_tvalid <= 0;
              m_axis_tlast  <= 0;
              state_t <= RECEIVE_DATA;
            end else begin
              result_ptr <= result_ptr - 1;
              m_axis_tdata <= sha[result_ptr - 1];
              m_axis_tlast <= (result_ptr - 1 == 3'd0);
              initial_state <= standard_initial_state;
              state <= standard_initial_state;
            end
          end
        end
      endcase
    end
  end
  assign word = round_index[5:4]== 2'b00 ? s_axis_tdata : expanded_word;
endmodule
