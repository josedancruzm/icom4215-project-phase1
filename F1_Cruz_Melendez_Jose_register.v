//iverilog -o test tb_rf_rh.v F1_Cruz_Melendez_Jose_register.v
//vvp test
// Register File Components
// --built using binary decoders, multiplexers, and registers

//we build our register, which will be 32 of them
module reg32 (
    input  wire        clk, //our clock line
    input  wire        ld,  //our load enable
    input  wire [31:0] d,   //our 32-bit data input from the PW bus
    output reg  [31:0] q    //our 32-bit stored value, which is the value that goes to the mux's
);
    always @(posedge clk) begin
        if (ld)
            q <= d;
    end
endmodule

module dec5to32 (
    input  wire [4:0] a,
    input  wire       en,
    output reg  [31:0] y
);
    always @(*) begin
        if (!en)
            y = 32'b0;
        else begin
            y = 32'b0;
            y[a] = 1'b1;
        end
    end
endmodule


module mux32_1_32 (
    input  wire [31:0] d0,  input wire [31:0] d1,
    input  wire [31:0] d2,  input wire [31:0] d3,
    input  wire [31:0] d4,  input wire [31:0] d5,
    input  wire [31:0] d6,  input wire [31:0] d7,
    input  wire [31:0] d8,  input wire [31:0] d9,
    input  wire [31:0] d10, input wire [31:0] d11,
    input  wire [31:0] d12, input wire [31:0] d13,
    input  wire [31:0] d14, input wire [31:0] d15,
    input  wire [31:0] d16, input wire [31:0] d17,
    input  wire [31:0] d18, input wire [31:0] d19,
    input  wire [31:0] d20, input wire [31:0] d21,
    input  wire [31:0] d22, input wire [31:0] d23,
    input  wire [31:0] d24, input wire [31:0] d25,
    input  wire [31:0] d26, input wire [31:0] d27,
    input  wire [31:0] d28, input wire [31:0] d29,
    input  wire [31:0] d30, input wire [31:0] d31,
    input  wire [4:0]  sel,
    output reg  [31:0] y
);
    always @(*) begin
        case (sel)
            5'd0:  y = d0;
            5'd1:  y = d1;
            5'd2:  y = d2;
            5'd3:  y = d3;
            5'd4:  y = d4;
            5'd5:  y = d5;
            5'd6:  y = d6;
            5'd7:  y = d7;
            5'd8:  y = d8;
            5'd9:  y = d9;
            5'd10: y = d10;
            5'd11: y = d11;
            5'd12: y = d12;
            5'd13: y = d13;
            5'd14: y = d14;
            5'd15: y = d15;
            5'd16: y = d16;
            5'd17: y = d17;
            5'd18: y = d18;
            5'd19: y = d19;
            5'd20: y = d20;
            5'd21: y = d21;
            5'd22: y = d22;
            5'd23: y = d23;
            5'd24: y = d24;
            5'd25: y = d25;
            5'd26: y = d26;
            5'd27: y = d27;
            5'd28: y = d28;
            5'd29: y = d29;
            5'd30: y = d30;
            5'd31: y = d31;
            default: y = 32'hxxxx_xxxx;
        endcase
    end
endmodule

module reg_file (
    input  wire        clk,
    input  wire        LE,
    input  wire [4:0]  RW,
    input  wire [31:0] PW,

    input  wire [4:0]  RNA,
    input  wire [4:0]  RNB,
    input  wire [4:0]  RNS,

    output wire [31:0] PA,
    output wire [31:0] PB,
    output wire [31:0] PS
);
    wire [31:0] ld;
    wire [31:0] q [31:0];

    dec5to32 dec_write (
        .a (RW),
        .en(LE),
        .y (ld)
    );

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : RF_REGS
            reg32 r (
                .clk(clk),
                .ld (ld[i]),
                .d  (PW),
                .q  (q[i])
            );
        end
    endgenerate

    mux32_1_32 muxA (
        q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7],
        q[8], q[9], q[10], q[11], q[12], q[13], q[14], q[15],
        q[16], q[17], q[18], q[19], q[20], q[21], q[22], q[23],
        q[24], q[25], q[26], q[27], q[28], q[29], q[30], q[31],
        RNA, PA
    );

    mux32_1_32 muxB (
        q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7],
        q[8], q[9], q[10], q[11], q[12], q[13], q[14], q[15],
        q[16], q[17], q[18], q[19], q[20], q[21], q[22], q[23],
        q[24], q[25], q[26], q[27], q[28], q[29], q[30], q[31],
        RNB, PB
    );

    mux32_1_32 muxS (
        q[0], q[1], q[2], q[3], q[4], q[5], q[6], q[7],
        q[8], q[9], q[10], q[11], q[12], q[13], q[14], q[15],
        q[16], q[17], q[18], q[19], q[20], q[21], q[22], q[23],
        q[24], q[25], q[26], q[27], q[28], q[29], q[30], q[31],
        RNS, PS
    );

endmodule

module reg_handler (
    input  wire [31:0] I,
    input  wire        RSO1,
    input  wire        RTD,

    output wire [4:0]  RNA,
    output wire [4:0]  RNB,
    output wire [4:0]  RNS,
    output wire [4:0]  RD
);
    wire [4:0] field_RA     = I[15:11];
    wire [4:0] field_RB     = I[20:16];
    wire [4:0] field_RT_RS  = I[10:6];

    assign RNB = field_RB;
    assign RNS = field_RT_RS;

    assign RNA = (RSO1) ? field_RT_RS : field_RA;
    assign RD  = (RTD)  ? field_RT_RS : field_RA;

endmodule