module ALSU_tb_2 ();    // INPUT_PRIORITY = "A", FULL_ADDER = "OFF"
    localparam INPUT_PRIORITY = "A";
    localparam FULL_ADDER = "OFF";
    reg clk, rst, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction;
    reg [2 : 0] A, B, opcode;
    wire [15 : 0] leds;
    wire [5 : 0] out;

    ALSU #(.INPUT_PRIORITY(INPUT_PRIORITY), .FULL_ADDER(FULL_ADDER)) uut 
    (.clk(clk), .rst(rst), .cin(cin), .serial_in(serial_in), .red_op_A(red_op_A),
    .red_op_B(red_op_B), .bypass_A(bypass_A), .bypass_B(bypass_B), .direction(direction),
    .A(A), .B(B), .opcode(opcode), .leds(leds), .out(out));

    localparam CLK_PERIOD = 10;
    always
        #(CLK_PERIOD / 2) clk = ~clk;

    integer i;
    initial begin
        clk = 1'b1;             rst = 1'b1;
        cin = 1'b1;             serial_in = 1'b1;
        red_op_A = 1'b0;        red_op_B = 1'b0;
        bypass_A = 1'b0;        bypass_B = 1'b0;
        direction = 1'b1;       A = 5;
        B = 1;                  opcode = 3'b010;
        #(CLK_PERIOD) rst = 1'b0;

        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk);
            {A, B, direction} = $random;
            opcode = $urandom_range(0, 5);
        end

        @(negedge clk) opcode = 3'b010;

        for (i = 0; i < 15; i = i + 1) 
            @(negedge clk)  {A, B, cin} = $random;
        $stop;
    end
endmodule