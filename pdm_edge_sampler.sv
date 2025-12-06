`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 05:41:48 PM
// Design Name: 
// Module Name: pdm_edge_sampler
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


module pdm_edge_sampler(
    input logic clk,
    input logic rst,
    input logic pdm_clk,
    input logic mic_data,
    input logic lrsel,
    output logic sample_en,
    output logic sampled_bit
    );
    
    logic p_pdm_clk;
    logic s_bit, n_s_bit;
    logic s_en, n_s_en;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            p_pdm_clk <= 1'b0;
            s_bit <= 0;
            s_en <= 0;
        end else begin      
            p_pdm_clk <= pdm_clk;
            s_bit <= n_s_bit;
            s_en <= n_s_en;
        end
    end

    logic rise =  pdm_clk & ~p_pdm_clk;
    logic fall = ~pdm_clk &  p_pdm_clk;

    always_comb begin
        if (lrsel == 1'b0)
            n_s_en = rise;
        else
            n_s_en = fall;
        if(n_s_en)
            n_s_bit = mic_data;
        else
            n_s_bit = s_bit;
    end
    assign sampled_bit = s_bit;
    assign sample_en = s_en;
    
endmodule
