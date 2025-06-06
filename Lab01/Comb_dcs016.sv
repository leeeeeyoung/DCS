module Comb(
  // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
  // Output signals
	out_num0,
	out_num1
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [6:0] in_num0, in_num1, in_num2, in_num3;
output logic [7:0] out_num0, out_num1;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [6:0] xnor1, or1, and1, xor1;
logic [6:0] comparator1_large, comparator1_small, comparator2_large, comparator2_small;
logic [7:0] adder1, adder2;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
assign xnor1 = ~(in_num0 ^ in_num1);
assign or1 = in_num1 | in_num3;
assign and1 = in_num0 & in_num2;
assign xor1 = in_num2 ^ in_num3;

assign {comparator1_large, comparator1_small} = (xnor1 > or1) ? {xnor1, or1} : {or1, xnor1};
assign {comparator2_large, comparator2_small} = (and1 > xor1) ? {and1, xor1} : {xor1, and1};

assign adder1 = comparator1_large + comparator2_large;
assign adder2 = comparator1_small + comparator2_small;

assign out_num0 = adder1;
assign out_num1 = {adder2[7], adder2[7:1] ^ adder2[6:0]};

endmodule
