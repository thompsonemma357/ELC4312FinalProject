`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 05:16:32 PM
// Design Name: 
// Module Name: pdm_clk_gen
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


module pdm_clk_gen(
    input logic clk,
    input logic rst,
    output logic pdm_clk
    );
    

    logic [3:0] cnt; //3.125 MHz
    logic [3:0] n_cnt;
    logic pdm_value;
    logic n_pdm_value;
    
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt     <= 0;
            pdm_value <= 1'b0;
        end else begin
            cnt <= n_cnt;
            pdm_value <= n_pdm_value;
        end
    end
    
    always_comb begin
        if (cnt >= 15) begin
                n_cnt = 0;
                n_pdm_value = ~pdm_value;
            end else begin
                n_cnt = cnt + 1'b1;
                n_pdm_value = pdm_value;
            end
    end

    assign pdm_clk = pdm_value;
endmodule
