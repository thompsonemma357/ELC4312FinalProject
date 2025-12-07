
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Simple MMIO core for mic gate 
// Address map (16-bit words):
//   0: STATUS (RO)  [bit0 = above_thresh, bit1 = new_lvl_flag]
//   1: LEVEL  (RO)  [16-bit peak level from detector]
//   2: THRESH (R/W) [16-bit threshold]
//   3: CTRL   (WO)  [bit0 = clear new_lvl_flag]
//////////////////////////////////////////////////////////////////////////////////

module mic_gate_mmio (
    input  logic        clk,
    input  logic        rst,

    // simple MMIO interface 
    input  logic        cs,         // chip select
    input  logic        wr_en,      // write strobe (1-cycle)
    input  logic        rd_en,      // read strobe  (1-cycle)
    input  logic [1:0]  address,    // 2-bit word address (0..3)
    input  logic [15:0] wr_data,    // 16-bit write data
    output logic [15:0] rd_data,    // 16-bit read data

    // hooks to level detector
    input  logic [15:0] level_in,          // latched peak value
    input  logic        above_thresh_in,   // comparator result
    input  logic        level_ready_in,    // 1-cycle pulse at window end
    output logic [15:0] threshold_out      // to detector
);

    // internal registers
    logic [15:0] threshold_reg;
    logic        new_lvl_flag;

    // ===== Sequential: register write + flag latch/clear =====
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            threshold_reg <= 16'd1200;     // default starting threshold
            new_lvl_flag  <= 1'b0;
        end else begin
            // latch end-of-window flag
            if (level_ready_in)
                new_lvl_flag <= 1'b1;

            // writes
            if (cs && wr_en) begin
                unique case (address)
                    2'd2: threshold_reg <= wr_data;                // THRESH
                    2'd3: if (wr_data[0]) new_lvl_flag <= 1'b0;    // CTRL: bit0=clear flag
                    default:;
                endcase
            end
        end
    end

    // ===== Combinational: reads =====
    always_comb begin
        rd_data = 16'h0000;
        if (cs && rd_en) begin
            unique case (address)
                2'd0: rd_data = {14'b0, new_lvl_flag, above_thresh_in}; // STATUS
                2'd1: rd_data = level_in;                               // LEVEL
                2'd2: rd_data = threshold_reg;                          // THRESH (R/W)
                2'd3: rd_data = 16'h0000;                               // CTRL (WO)
                default: rd_data = 16'h0000;
            endcase
        end
    end

    // to detector
    assign threshold_out = threshold_reg;

endmodule
