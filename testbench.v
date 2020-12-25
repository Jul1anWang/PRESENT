`timescale 1ns/100ps

module testBench;

    reg [63:0] plaintext;
    reg [79:0] mkey;
    wire [63:0] ciphertext;
    reg clk, rst;

    initial
        begin
            plaintext <= 64'h0000000000000000;
            mkey <= 80'h00000000000000000000;
            // cipher = 64'h5579C1387B228445
            clk <= 0;
            rst <= 0;
            #25 rst <= 1;
            #25 rst <= 0;
        end
    always #25  clk <= ~clk;

    PRESENT present(mkey, plaintext, ciphertext, clk, rst);


endmodule