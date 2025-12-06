`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 07:27:01 PM
// Design Name: 
// Module Name: level_detector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module level_detector(
    input logic clk,
    input logic rst,
    input logic signed[15:0] sample_in,
    input logic sample_valid,
    input logic [15:0] threshold,
    output logic [15:0] level,
    output logic above_thresh,
    output logic level_ready
    );
    
   logic [15:0] abs_sample, peak, n_peak;
   logic [8:0]  cnt, n_cnt;
   logic [15:0] temp_level, n_temp_level;
   logic l_ready, n_l_ready;
   logic a_thresh, n_a_thresh;
   
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt         <= '0;
            peak        <= '0;
            temp_level       <= '0;
            l_ready <= 0;
            a_thresh <= 0;
        end else begin
            cnt <= n_cnt;
            peak <= n_peak;
            temp_level <= n_temp_level;
            l_ready <= n_l_ready;
            a_thresh <= n_a_thresh;
        end
    end
    
    always_comb begin
        n_l_ready = 0;
        n_a_thresh = (level >= threshold);
        abs_sample = sample_in[15] ? (~sample_in + 1'b1) : sample_in;
        n_cnt = cnt;
        n_peak = peak;
        n_temp_level = temp_level;
        if (sample_valid) begin
            n_cnt = cnt + 1'b1;
            if (abs_sample > peak) 
                n_peak = abs_sample;
            if (&cnt) begin
                n_temp_level = peak;
                n_l_ready = 1'b1;
                n_peak = '0;
           end
       end
   end
   
   assign level = temp_level;
   assign above_thresh = a_thresh;
   assign level_ready = l_ready;
    
endmodule
