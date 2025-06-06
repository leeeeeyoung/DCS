module DT(
    // Input signals
	in_n0,
	in_n1,
	in_n2,
	in_n3,
    // Output signals
    out_n0,
    out_n1,
    out_n2,
    out_n3,
    out_n4,
	ack_n0,
	ack_n1,
	ack_n2,
	ack_n3
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [19:0] in_n0, in_n1, in_n2, in_n3;
output logic [17:0] out_n0, out_n1, out_n2, out_n3, out_n4;
output logic ack_n0, ack_n1, ack_n2, ack_n3;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic in_n0_valid, in_n1_valid, in_n2_valid, in_n3_valid;
logic [2:0] in_n0_destination, in_n1_destination, in_n2_destination, in_n3_destination;
logic [15:0] in_n0_data, in_n1_data, in_n2_data, in_n3_data;

logic [2:0] out_n0_connect, out_n1_connect, out_n2_connect, out_n3_connect, out_n4_connect;
logic [1:0] out_n0_condition, out_n1_condition, out_n2_condition, out_n3_condition, out_n4_condition;
logic [15:0] out_n0_data, out_n1_data, out_n2_data, out_n3_data, out_n4_data;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always_comb begin
	in_n0_valid = in_n0[19];
	in_n0_destination = in_n0[18:16];
	in_n0_data = in_n0[15:0];

	in_n1_valid = in_n1[19];
	in_n1_destination = in_n1[18:16];
	in_n1_data = in_n1[15:0];

	in_n2_valid = in_n2[19];
	in_n2_destination = in_n2[18:16];
	in_n2_data = in_n2[15:0];

	in_n3_valid = in_n3[19];
	in_n3_destination = in_n3[18:16];
	in_n3_data = in_n3[15:0];

	ack_n0 = 1'b0;
	ack_n1 = 1'b0;
	ack_n2 = 1'b0;
	ack_n3 = 1'b0;

	out_n0_connect = 3'b000;
	if(in_n0_valid && (in_n0_destination == 3'b000)) out_n0_connect++;
	if(in_n1_valid && (in_n1_destination == 3'b000)) out_n0_connect++;
	if(in_n2_valid && (in_n2_destination == 3'b000)) out_n0_connect++;
	if(in_n3_valid && (in_n3_destination == 3'b000)) out_n0_connect++;

	case (out_n0_connect)
		3'b000: out_n0_condition = 2'b00;
		3'b001: out_n0_condition = 2'b01;
		default: out_n0_condition = 2'b10;
	endcase

	if(in_n0_valid && (in_n0_destination == 3'b000)) begin
		out_n0_data = in_n0_data;
		ack_n0 = 1'b1;
	end
	else if(in_n1_valid && (in_n1_destination == 3'b000)) begin
		out_n0_data = in_n1_data;
		ack_n1 = 1'b1;
	end
	else if(in_n2_valid && (in_n2_destination == 3'b000)) begin 
		out_n0_data = in_n2_data;
		ack_n2 = 1'b1;
	end
	else if(in_n3_valid && (in_n3_destination == 3'b000)) begin
		out_n0_data = in_n3_data;
		ack_n3 = 1'b1;
	end
	else 
		out_n0_data = 16'b0000_0000_0000_0000;
	
	out_n1_connect = 3'b000;
	if(in_n0_valid && (in_n0_destination == 3'b001)) out_n1_connect++;
	if(in_n1_valid && (in_n1_destination == 3'b001)) out_n1_connect++;
	if(in_n2_valid && (in_n2_destination == 3'b001)) out_n1_connect++;
	if(in_n3_valid && (in_n3_destination == 3'b001)) out_n1_connect++;

	case (out_n1_connect)
		3'b000: out_n1_condition = 2'b00;
		3'b001: out_n1_condition = 2'b01;
		default: out_n1_condition = 2'b10;
	endcase
	
	if(in_n0_valid && (in_n0_destination == 3'b001)) begin
		out_n1_data = in_n0_data;
		ack_n0 = 1'b1;
	end
	else if(in_n1_valid && (in_n1_destination == 3'b001)) begin
		out_n1_data = in_n1_data;
		ack_n1 = 1'b1;
	end
	else if(in_n2_valid && (in_n2_destination == 3'b001)) begin
		out_n1_data = in_n2_data;
		ack_n2 = 1'b1;
	end
	else if(in_n3_valid && (in_n3_destination == 3'b001)) begin
		out_n1_data = in_n3_data;
		ack_n3 = 1'b1;
	end
	else
		out_n1_data = 16'b0000_0000_0000_0000;
	
	out_n2_connect = 3'b000;
	if(in_n0_valid && (in_n0_destination == 3'b010)) out_n2_connect++;
	if(in_n1_valid && (in_n1_destination == 3'b010)) out_n2_connect++;
	if(in_n2_valid && (in_n2_destination == 3'b010)) out_n2_connect++;
	if(in_n3_valid && (in_n3_destination == 3'b010)) out_n2_connect++;

	case (out_n2_connect)
		3'b000: out_n2_condition = 2'b00;
		3'b001: out_n2_condition = 2'b01;
		default: out_n2_condition = 2'b10;
	endcase

	if(in_n0_valid && (in_n0_destination == 3'b010)) begin
		out_n2_data = in_n0_data;
		ack_n0 = 1'b1;
	end
	else if(in_n1_valid && (in_n1_destination == 3'b010)) begin
		out_n2_data = in_n1_data;
		ack_n1 = 1'b1;
	end
	else if(in_n2_valid && (in_n2_destination == 3'b010)) begin
		out_n2_data = in_n2_data;
		ack_n2 = 1'b1;
	end
	else if(in_n3_valid && (in_n3_destination == 3'b010)) begin
		out_n2_data = in_n3_data;
		ack_n3 = 1'b1;
	end
	else
		out_n2_data = 16'b0000_0000_0000_0000;

	out_n3_connect = 3'b000;
	if(in_n0_valid && (in_n0_destination == 3'b011)) out_n3_connect++;
	if(in_n1_valid && (in_n1_destination == 3'b011)) out_n3_connect++;
	if(in_n2_valid && (in_n2_destination == 3'b011)) out_n3_connect++;
	if(in_n3_valid && (in_n3_destination == 3'b011)) out_n3_connect++;

	case (out_n3_connect)
		3'b000: out_n3_condition = 2'b00;
		3'b001: out_n3_condition = 2'b01;
		default: out_n3_condition = 2'b10;
	endcase

	if(in_n0_valid && (in_n0_destination == 3'b011)) begin
		out_n3_data = in_n0_data;
		ack_n0 = 1'b1;
	end
	else if(in_n1_valid && (in_n1_destination == 3'b011)) begin
		out_n3_data = in_n1_data;
		ack_n1 = 1'b1;
	end
	else if(in_n2_valid && (in_n2_destination == 3'b011)) begin
		out_n3_data = in_n2_data;
		ack_n2 = 1'b1;
	end
	else if(in_n3_valid && (in_n3_destination == 3'b011)) begin
		out_n3_data = in_n3_data;
		ack_n3 = 1'b1;
	end
	else
		out_n3_data = 16'b0000_0000_0000_0000;
	
	out_n4_connect = 3'b000;
	if(in_n0_valid && (in_n0_destination == 3'b100)) out_n4_connect++;
	if(in_n1_valid && (in_n1_destination == 3'b100)) out_n4_connect++;
	if(in_n2_valid && (in_n2_destination == 3'b100)) out_n4_connect++;
	if(in_n3_valid && (in_n3_destination == 3'b100)) out_n4_connect++;

	case (out_n4_connect)
		3'b000: out_n4_condition = 2'b00;
		3'b001: out_n4_condition = 2'b01;
		default: out_n4_condition = 2'b10;
	endcase
	
	if(in_n0_valid && (in_n0_destination == 3'b100)) begin
		out_n4_data = in_n0_data;
		ack_n0 = 1'b1;
	end
	else if(in_n1_valid && (in_n1_destination == 3'b100)) begin
		out_n4_data = in_n1_data;
		ack_n1 = 1'b1;
	end
	else if(in_n2_valid && (in_n2_destination == 3'b100)) begin
		out_n4_data = in_n2_data;
		ack_n2 = 1'b1;
	end
	else if(in_n3_valid && (in_n3_destination == 3'b100)) begin
		out_n4_data = in_n3_data;
		ack_n3 = 1'b1;
	end
	else
		out_n4_data = 16'b0000_0000_0000_0000;
	
	out_n0 = {out_n0_condition, out_n0_data};
	out_n1 = {out_n1_condition, out_n1_data};
	out_n2 = {out_n2_condition, out_n2_data};
	out_n3 = {out_n3_condition, out_n3_data};
	out_n4 = {out_n4_condition, out_n4_data};

end
endmodule
