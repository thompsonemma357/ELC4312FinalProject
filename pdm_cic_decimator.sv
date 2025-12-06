module pdm_cic_decimator(
    input  logic                  clk,
    input  logic                  rst,
    input  logic                  sample_en,
    input  logic                  sampled_bit,
    output logic signed [15:0]    pcm_sample,
    output logic                  pcm_valid
);

    // Map bit to +1/-1
    logic signed [1:0] x, n_x;

    // Widened integrators/comb state
    logic signed [31:0] integ0, integ1, n_integ0, n_integ1;
    logic        [5:0]  dec_cnt, n_dec_cnt;

    // Comb delays at decimated rate
    logic signed [31:0] comb_d0, comb_d1, n_comb_d0, n_comb_d1;

    // Decimated sample and valid
    logic signed [15:0] p_sample, n_p_sample;
    logic               p_valid,  n_p_valid;

    // Intermediate
    logic signed [31:0] y0, y1, y_norm;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            integ0   <= '0;
            integ1   <= '0;
            dec_cnt  <= '0;
            comb_d0  <= '0;
            comb_d1  <= '0;
            p_valid  <= 1'b0;
            p_sample <= '0;
            x        <= '0;
        end else begin
            integ0   <= n_integ0;
            integ1   <= n_integ1;
            dec_cnt  <= n_dec_cnt;
            comb_d0  <= n_comb_d0;
            comb_d1  <= n_comb_d1;
            p_valid  <= n_p_valid;
            p_sample <= n_p_sample;
            x        <= n_x;
        end
    end

    always_comb begin
        // default hold
        n_x        = sampled_bit ? 2'sd1 : -2'sd1;
        n_integ0   = integ0;
        n_integ1   = integ1;
        n_dec_cnt  = dec_cnt;
        n_comb_d0  = comb_d0;
        n_comb_d1  = comb_d1;
        n_p_sample = p_sample;
        n_p_valid  = 1'b0;

        if (sample_en) begin
            // integrate at PDM rate
            n_integ0 = integ0 + n_x;
            n_integ1 = integ1 + n_integ0;

            // decimate by R=64
            if (dec_cnt == 6'd63) begin
                n_dec_cnt = '0;

                // combs at decimated rate
                // y0 = x[n] - x[n-1]
                y0        = n_integ1 - comb_d0;
                n_comb_d0 = n_integ1;

                // y1 = y0[n] - y0[n-1]
                y1        = y0 - comb_d1;
                n_comb_d1 = y0;            // store previous y0 (FIX)

                // Normalize by CIC gain (R^N = 4096 ≡ 12 bits)
                // arithmetic shift to preserve sign
                y_norm = y1 >>> 12;

                // Saturate to 16-bit
                if (y_norm > 32'sd32767)      
                    n_p_sample = 16'sd32767;
                else if (y_norm < -32'sd32768) 
                    n_p_sample = -16'sd32768;
                else                            
                    n_p_sample = y_norm[15:0];

                n_p_valid = 1'b1;
            end else begin
                n_dec_cnt = dec_cnt + 6'd1;
            end
        end
    end

    assign pcm_sample = p_sample;
    assign pcm_valid  = p_valid;

endmodule
