module D_FF_tb ();
    reg clk, rst, D;
    wire Q;

    D_FF uut (.clk(clk), .rst(rst), .D(D), .Q(Q));

    localparam CLK_PERIOD = 10;
    always
        #(CLK_PERIOD / 2) clk = ~clk;

    integer i;
    initial begin
        clk = 1'b1;
        rst = 1'b1;
        D = 1'b1;
        #(CLK_PERIOD) rst = 1'b0;
        for (i = 0; i < 24; i = i + 1) 
            @(negedge clk) D = $random;
        $stop;
    end
endmodule