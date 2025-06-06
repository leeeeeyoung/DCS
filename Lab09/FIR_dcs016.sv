module FIR(
    // Input signals
    clk,
    rst_n,
    in_valid,
    weight_valid,
    x,
    b0,
    b1,
    b2,
    b3,
    // Output signals
    out_valid,
    y
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, weight_valid;
input [15:0] x, b0, b1, b2, b3;

output logic out_valid;
output logic [33:0] y;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [15:0] b0_reg, b1_reg, b2_reg, b3_reg;     
logic [15:0] x_reg0, x_reg1, x_reg2, x_reg;             
logic [33:0] mul0, mul1, mul2, mul3;             
logic [33:0] mul0_reg, mul1_reg, mul2_reg, mul3_reg; 
logic [33:0] sum0, sum1;                         
logic [33:0] sum0_reg, sum1_reg;          
logic [33:0] y_comb;
logic valid_reg1, valid_reg2, valid_reg3, valid_reg4, valid_reg5, valid_reg6;


//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
assign mul0 = b0_reg * x_reg;        
assign mul1 = b1_reg * x_reg0;   
assign mul2 = b2_reg * x_reg1;    
assign mul3 = b3_reg * x_reg2;   
assign sum0 = mul0_reg + mul1_reg; 
assign sum1 = mul2_reg + mul3_reg; 
assign y_comb = sum0_reg + sum1_reg;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x_reg <= 0;
        b0_reg <= 16'd0;
        b1_reg <= 16'd0;
        b2_reg <= 16'd0;
        b3_reg <= 16'd0;
        x_reg0 <= 16'd0;
        x_reg1 <= 16'd0;
        x_reg2 <= 16'd0;
        mul0_reg <= 32'd0;
        mul1_reg <= 32'd0;
        mul2_reg <= 32'd0;
        mul3_reg <= 32'd0;
        sum0_reg <= 33'd0;
        sum1_reg <= 33'd0;
        y <= 34'd0;
        valid_reg1 <= 1'b0;
        valid_reg2 <= 1'b0;
        valid_reg3 <= 1'b0;
        out_valid <= 1'b0;
    end else begin
        if (weight_valid) begin
            b0_reg <= b0;
            b1_reg <= b1;
            b2_reg <= b2;
            b3_reg <= b3;
        end
        if (in_valid) begin
            x_reg <= x;
            x_reg0 <= x_reg;
            x_reg1 <= x_reg0;
            x_reg2 <= x_reg1;
        end
        mul0_reg <= mul0;
        mul1_reg <= mul1;
        mul2_reg <= mul2;
        mul3_reg <= mul3;
        sum0_reg <= sum0;
        sum1_reg <= sum1;
        y <= y_comb;
        valid_reg1 <= in_valid;
        valid_reg2 <= valid_reg1;
        valid_reg3 <= valid_reg2;
        valid_reg4 <= valid_reg3;
        valid_reg5 <= valid_reg4;
        valid_reg6 <= valid_reg5;
        out_valid <= valid_reg6;
    end
end

endmodule