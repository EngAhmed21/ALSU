module D_FF #(parameter WIDTH = 1)(
    input clk, rst,
    input [WIDTH - 1 : 0] D,
    output reg [WIDTH - 1 : 0] Q
);
    always @(posedge clk, posedge rst) begin
        if (rst)
            Q <= 0;
        else
            Q <= D;
    end
endmodule