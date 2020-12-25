module PRESENT(
    input [79:0] mkey,
    input [63:0] plaintext,
    output [63:0] ciphertext,

    input clk,
    input rst
);

    reg [4:0] rnd;
    reg [63:0] state;
    wire [63:0] nextstate;
    reg [79:0] key;
    wire [79:0] nextkey;
    wire [63:0] rkey;

    reg done;

    assign ciphertext = done ? state^rkey : ciphertext;


    always @(posedge clk or posedge rst)begin
        if (rst) rnd <= 1;
        else if (~done) rnd <= rnd + 1;
        else rnd <= rnd;
    end

    always @(posedge clk or posedge rst)begin
        if (rst) state <= plaintext;
        else if (~done)state <= nextstate;
        else state <= state;
    end

    always @(posedge clk or posedge rst)begin
        if (rst) key <= mkey;
        else if (~done) key <= nextkey;
        else key <= key;
    end

    assign rkey = key[79:16];

    keyschedule  ks(.key(key), .round(rnd), .nextkey(nextkey));

    roundenc     renc(.state(state), .rkey(rkey), .nextstate(nextstate));


    always @(posedge clk or posedge rst)begin
        if (rst) done <= 0;
        else if (&rnd)done <= 1;
        else done <= done;
    end

endmodule


module keyschedule(
    input [79:0] key,
    input [4:0] round,
    output [79:0] nextkey
);
    assign nextkey = {sbox(key[18:15]), key[14:0], key[79:39], key[38:34]^round, key[33:19]};

    function [3:0] sbox;
        input [3:0] x;
        case (x)
            4'h0:sbox = 4'hc;  4'h1:sbox = 4'h5;   4'h2:sbox = 4'h6;   4'h3:sbox = 4'hb;
            4'h4:sbox = 4'h9;  4'h5:sbox = 4'h0;   4'h6:sbox = 4'ha;   4'h7:sbox = 4'hd;
            4'h8:sbox = 4'h3;  4'h9:sbox = 4'he;   4'ha:sbox = 4'hf;   4'hb:sbox = 4'h8;
            4'hc:sbox = 4'h4;  4'hd:sbox = 4'h7;   4'he:sbox = 4'h1;   4'hf:sbox = 4'h2;
        endcase
    endfunction

endmodule

module roundenc(
    input [63:0] state,
    input [63:0] rkey,
    output [63:0] nextstate
);
    wire [63:0] out_add, out_S;
    assign out_add = state ^ rkey;
    assign out_S = {sbox(out_add[63:60]), sbox(out_add[59:56]), sbox(out_add[55:52]), sbox(out_add[51:48]), sbox(out_add[47:44]), sbox(out_add[43:40]), sbox(out_add[39:36]), sbox(out_add[35:32]), 
                    sbox(out_add[31:28]), sbox(out_add[27:24]), sbox(out_add[23:20]), sbox(out_add[19:16]), sbox(out_add[15:12]), sbox(out_add[11:8]), sbox(out_add[7:4]), sbox(out_add[3:0])};
    assign nextstate = {out_S[63], out_S[59], out_S[55], out_S[51], out_S[47], out_S[43], out_S[39], out_S[35],
                        out_S[31], out_S[27], out_S[23], out_S[19], out_S[15], out_S[11], out_S[7],  out_S[3],
                        out_S[62], out_S[58], out_S[54], out_S[50], out_S[46], out_S[42], out_S[38], out_S[34],
                        out_S[30], out_S[26], out_S[22], out_S[18], out_S[14], out_S[10], out_S[6],  out_S[2],
                        out_S[61], out_S[57], out_S[53], out_S[49], out_S[45], out_S[41], out_S[37], out_S[33],
                        out_S[29], out_S[25], out_S[21], out_S[17], out_S[13], out_S[9],  out_S[5],  out_S[1],
                        out_S[60], out_S[56], out_S[52], out_S[48], out_S[44], out_S[40], out_S[36], out_S[32], 
                        out_S[28], out_S[24], out_S[20], out_S[16], out_S[12], out_S[8],  out_S[4],  out_S[0]
                        };

    function [3:0] sbox;
        input [3:0] x;
        case (x)
            4'h0:sbox = 4'hc;  4'h1:sbox = 4'h5;   4'h2:sbox = 4'h6;   4'h3:sbox = 4'hb;
            4'h4:sbox = 4'h9;  4'h5:sbox = 4'h0;   4'h6:sbox = 4'ha;   4'h7:sbox = 4'hd;
            4'h8:sbox = 4'h3;  4'h9:sbox = 4'he;   4'ha:sbox = 4'hf;   4'hb:sbox = 4'h8;
            4'hc:sbox = 4'h4;  4'hd:sbox = 4'h7;   4'he:sbox = 4'h1;   4'hf:sbox = 4'h2;
        endcase
    endfunction
endmodule