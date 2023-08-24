module ALSU #(parameter INPUT_PRIORITY = "A", FULL_ADDER = "ON") (
    input clk, rst, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction,
    input [2 : 0] A, B, opcode,
    output reg [15 : 0] leds,
    output reg [5 : 0] out
);
    
    wire Q_cin, Q_serial_in, Q_red_op_A, Q_red_op_B, Q_bypass_A, Q_bypass_B, Q_direction;
    wire [2 : 0] Q_A, Q_B, Q_opcode;

    D_FF #(.WIDTH(1)) FF_cin (.clk(clk), .rst(rst), .D(cin), .Q(Q_cin));
    D_FF #(.WIDTH(1)) FF_serial_in (.clk(clk), .rst(rst), .D(serial_in), .Q(Q_serial_in));
    D_FF #(.WIDTH(1)) FF_red_op_A (.clk(clk), .rst(rst), .D(red_op_A), .Q(Q_red_op_A));
    D_FF #(.WIDTH(1)) FF_red_op_B (.clk(clk), .rst(rst), .D(red_op_B), .Q(Q_red_op_B));
    D_FF #(.WIDTH(1)) FF_bypass_A (.clk(clk), .rst(rst), .D(bypass_A), .Q(Q_bypass_A));
    D_FF #(.WIDTH(1)) FF_bypass_B (.clk(clk), .rst(rst), .D(bypass_B), .Q(Q_bypass_B));
    D_FF #(.WIDTH(1)) FF_direction (.clk(clk), .rst(rst), .D(direction), .Q(Q_direction));
    D_FF #(.WIDTH(3)) FF_A (.clk(clk), .rst(rst), .D(A), .Q(Q_A));
    D_FF #(.WIDTH(3)) FF_B (.clk(clk), .rst(rst), .D(B), .Q(Q_B));
    D_FF #(.WIDTH(3)) FF_opcode (.clk(clk), .rst(rst), .D(opcode), .Q(Q_opcode));

    reg [5 : 0] next;
    wire [15 : 0] leds_next;
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            leds <= 1'b0;
            out <= 0;
        end
        else begin
            leds <= leds_next;
            out <= next;
        end
    end
    
    always @(*) begin
        if (Q_bypass_A || Q_bypass_B) 
            if (Q_bypass_A && ((~Q_bypass_B) || (INPUT_PRIORITY == "A")))
                next = Q_A;
            else if (Q_bypass_B && ((~Q_bypass_A) || (INPUT_PRIORITY == "B")))
                next = Q_B;
            else
                next = out;
        else
            case (Q_opcode)
                3'b000:     begin
                    if (Q_red_op_A || Q_red_op_B)
                        if (Q_red_op_A && ((~Q_red_op_B) || (INPUT_PRIORITY == "A")))
                            next = &Q_A;
                        else if (Q_red_op_B && ((~Q_red_op_A) || (INPUT_PRIORITY == "B")))
                            next = &Q_B;
                        else
                            next = out;
                    else
                        next = Q_A & Q_B;
                end     
                3'b001:     begin
                    if (Q_red_op_A || Q_red_op_B)
                        if (Q_red_op_A && ((~Q_red_op_B) || (INPUT_PRIORITY == "A")))
                            next = ^Q_A;
                        else if (Q_red_op_B && ((~Q_red_op_A) || (INPUT_PRIORITY == "B")))
                            next = ^Q_B;
                        else
                            next = out;
                    else
                        next = Q_A ^ Q_B;
                end
                3'b010:     begin
                    if (Q_red_op_A || Q_red_op_B) 
                        next = 0; 
                    else if (FULL_ADDER == "ON")
                        next = Q_A + Q_B + Q_cin;
                    else if (FULL_ADDER == "OFF")
                        next = Q_A + Q_B;
                    else
                        next = out;
                end
                3'b011:     begin
                    if (Q_red_op_A || Q_red_op_B) 
                        next = 0; 
                    else
                        next = Q_A * Q_B;
                end
                3'b100:     begin
                    if (Q_red_op_A || Q_red_op_B) 
                        next = 0; 
                    else if (Q_direction)
                        next = {out [4 : 0], Q_serial_in};
                    else
                        next = {Q_serial_in, out [5 : 1]}; 
                end
                3'b101:     begin
                    if (Q_red_op_A || Q_red_op_B) 
                        next = 0; 
                    else if (Q_direction)
                        next = {out [4 : 0], out [5]};
                    else
                        next = {out [0], out [5 : 1]}; 
                end
                default:    
                    next = 0; 
            endcase
    end
    
   assign leds_next = (((Q_opcode > 3'b001) && ((Q_red_op_A) || (Q_red_op_B))) || (Q_opcode > 3'b101)) ? ~leds : 0;
endmodule