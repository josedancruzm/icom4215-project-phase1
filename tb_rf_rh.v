module tb_rf_rh;

reg         clk;
reg         LE;
reg  [4:0]  RW;
reg  [31:0] PW;

reg  [31:0] I;
reg         RSO1;
reg         RTD;

wire [31:0] PA, PB, PS;
wire [4:0]  RD;

reg_handler RH (
    .I(I),
    .RSO1(RSO1),
    .RTD(RTD),
    .RNA(),   // we don’t need to name these wires
    .RNB(),
    .RNS(),
    .RD(RD)
);

reg_file RF (
    .clk(clk),
    .LE(LE),
    .RW(RW),
    .PW(PW),
    .RNA(RH.RNA),
    .RNB(RH.RNB),
    .RNS(RH.RNS),
    .PA(PA),
    .PB(PB),
    .PS(PS)
);

initial clk = 0;
always #2 clk = ~clk;

initial begin
    // Step 1: initialize
    LE   = 1;
    PW   = 30;
    RW   = 0;
    I    = 32'b0;
    RSO1 = 0;
    RTD  = 1;

    // Print header
    $display("time | RW | RA | RB | RS | PW | PA | PB | PS | RD");
    // Monitor changes
    $monitor("%4t | %2d | %2d | %2d | %2d | %2d | %2d | %2d | %2d | %2d", 
            $time, RW, I[15:11], I[20:16], I[10:6], PW, PA, PB, PS, RD);
    // Step 2: write values into registers
    repeat (32) begin
        #4;
        PW = PW + 1;
        RW = RW + 1;
        I[15:11] = I[15:11] + 1;
        I[20:16] = I[20:16] + 1;
        I[10:6]  = I[10:6]  + 1;
    end

    // Step 3: switch to read mode
    LE   = 0;
    PW   = 55;
    RW   = 0;
    I    = 32'b0;
    RSO1 = 1;
    RTD  = 0;

    repeat (5) begin
        #4;
        I[15:11] = I[15:11] + 1;
        I[20:16] = I[20:16] + 1;
        I[10:6]  = I[10:6]  + 1;
    end

    #10 $finish;
end
endmodule
