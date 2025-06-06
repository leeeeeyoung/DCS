
`include "Handshake_syn.v"

module CDC(
	// Input signals
	clk_1,
	clk_2,
	rst_n,
	in_valid,
	in_data,
	// Output signals
	out_valid,
	out_data
);

input clk_1; 
input clk_2;			
input rst_n;
input in_valid;
input[3:0]in_data;

output logic out_valid;
output logic [4:0]out_data; 			

// ---------------------------------------------------------------------
// logic declaration                 
// ---------------------------------------------------------------------	
parameter S_wait_input1 = 0, S_wait_input2 = 1, S_send_data = 2, S_send_data1 = 3, S_send_data2 = 4;
parameter S_idle = 0, S_get_dout = 1, S_out = 2, S_temp = 3, S_IDLE = 4;

logic [2:0] state1, next_state1;
logic [2:0] state2, next_state2;

logic sready, next_sready;
logic [3:0] din, next_din;
logic dbusy;

logic sidle;
logic dvalid;
logic [3:0] dout;

logic [3:0] data1, next_data1;
logic [3:0] data2, next_data2;
logic [4:0] next_out_data;
logic next_out_valid;
logic sending_first, next_sending_first;


// ---------------------------------------------------------------------
// design              
// ---------------------------------------------------------------------


Handshake_syn sync(
					.sclk(clk_1), 
					.dclk(clk_2), 
					.rst_n(rst_n),
					.sready(sready), 
					.din(din), 
					.sidle(sidle),
					.dbusy(dbusy),
					.dvalid(dvalid),
					.dout(dout)
);

always_ff @ (posedge clk_1 or negedge rst_n) begin
	if(!rst_n) begin
		state1 <= S_wait_input1;
		data1 <= 0;
		data2 <= 0;
		sready <= 0;
		din <= 0;
		sending_first <= 1;
	end
	else begin
		state1 <= next_state1;
		data1 <= next_data1;
		data2 <= next_data2;
		sready <= next_sready;
		din <= next_din;
		sending_first <= next_sending_first;
	end
end

always_comb begin
	next_state1 = state1;
	next_data1 = data1;
	next_data2 = data2;
	next_sready = 0;
	next_din = din;
	next_sending_first = sending_first;

	case(state1)
		S_wait_input1: begin
			if(in_valid) begin
				next_data1 = in_data;
				next_state1 = S_wait_input2;
			end
		end
		S_wait_input2: begin
			if(in_valid) begin
				next_data2 = in_data;
				next_state1 = S_send_data;
			end
		end
		S_send_data: begin
			if(sidle && sending_first) begin
				next_din = data1;
				next_sready = 1;
				next_sending_first = 0;
				next_state1 = S_send_data1;
			end
		end
		S_send_data1: begin
			if(!sidle) begin
				next_state1 = S_send_data2;
			end
		end
		S_send_data2: begin
			if(sidle && !sending_first) begin
				next_din = data2;
				next_sready = 1;
				next_sending_first = 1;
				next_state1 = S_wait_input1;
			end
		end
	endcase
end

always_ff @ (posedge clk_2 or negedge rst_n) begin
	if(!rst_n) begin
		state2 <= S_idle;
		out_data <= 0;
		out_valid <= 0;
	end
	else begin
		state2 <= next_state2;
		out_data <= next_out_data;
		out_valid <= next_out_valid;
	end
end

always_comb begin
	next_state2 = state2;
	next_out_data = out_data;
	next_out_valid = 0;

	case(state2)
		S_idle: begin
			if(!dvalid) begin
				next_state2 = S_IDLE;
			end
		end
		S_IDLE: begin
			if(dvalid) begin
				next_out_data = dout;
				next_state2 = S_temp;
			end
		end
		S_temp: begin
			if(!dvalid) begin
				next_state2 = S_get_dout;
			end
		end
		S_get_dout: begin
			if(dvalid) begin
				next_out_data = out_data + dout;
				next_state2 = S_out;
			end
		end
		S_out: begin
			next_out_valid = 1;
			next_state2 = S_idle;
		end
	endcase
end

assign dbusy = 0;

endmodule