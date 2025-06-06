module INF(
	// input signal
	clk,
	rst_n,
	in_valid,
	in_mode,
	in_addr,
	in_data,
	// input axi 
	ar_ready,
	r_data,
	r_valid,
	aw_ready,
	w_ready,
	// output signals
	out_valid,
	out_data,
	// output axi
	ar_addr,
	ar_valid,
	r_ready,
	aw_addr,
	aw_valid,
	w_data,
	w_valid
);
//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
input clk, rst_n, in_valid, in_mode;
input [3:0] in_addr;
input [7:0] in_data, r_data; 
input ar_ready, r_valid, aw_ready, w_ready;
output logic out_valid;
output logic [7:0] out_data, w_data;
output logic [3:0] ar_addr, aw_addr;
output logic ar_valid, r_ready, aw_valid, w_valid;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

parameter S_IDLE = 3'd0, S_AR = 3'd1, S_R = 3'd2, S_AW = 3'd3, S_W = 3'd4, S_OUTPUT = 3'd5;

logic [2:0] state, next_state;
logic [3:0] counter, next_counter;
logic [3:0] addr_reg, next_addr_reg;
logic mode, next_mode;

logic [7:0] data_reg [0:3];
logic [7:0] next_data_reg [0:3];

logic next_out_valid;
logic [7:0] next_out_data;
logic [3:0] next_ar_addr;
logic next_ar_valid;
logic next_r_ready;
logic [3:0] next_aw_addr;
logic next_aw_valid;
logic [7:0] next_w_data;
logic next_w_valid;

//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------

always_ff @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= 0;
		counter <= 0;
		addr_reg <= 0;
		mode <= 0;

		data_reg[0] <= 0;
		data_reg[1] <= 0;
		data_reg[2] <= 0;
		data_reg[3] <= 0;

		out_valid <= 0;
		out_data <= 0;
		ar_addr <= 0;
		ar_valid <= 0;
		r_ready <= 0;
		aw_addr <= 0;
		aw_valid <= 0;
		w_data <= 0;
		w_valid <= 0;
	end
	else begin
		state <= next_state;
		counter <= next_counter;
		addr_reg <= next_addr_reg;
		mode <= next_mode;

		data_reg[0] <= next_data_reg[0];
		data_reg[1] <= next_data_reg[1];
		data_reg[2] <= next_data_reg[2];
		data_reg[3] <= next_data_reg[3];

		out_valid <= next_out_valid;
		out_data <= next_out_data;
		ar_addr <= next_ar_addr;
		ar_valid <= next_ar_valid;
		r_ready <= next_r_ready;
		aw_addr <= next_aw_addr;
		aw_valid <= next_aw_valid;
		w_data <= next_w_data;
		w_valid <= next_w_valid;
	end
end

always_comb begin
	next_state = state;
	next_counter = counter;
	next_addr_reg = addr_reg;
	next_mode = mode;

	next_data_reg[0] = data_reg[0];
	next_data_reg[1] = data_reg[1];
	next_data_reg[2] = data_reg[2];
	next_data_reg[3] = data_reg[3];

	next_out_valid = out_valid;
	next_out_data = out_data;
	next_ar_addr = ar_addr;
	next_ar_valid = ar_valid;
	next_r_ready = r_ready;
	next_aw_addr = aw_addr;
	next_aw_valid = aw_valid;
	next_w_data = w_data;
	next_w_valid = w_valid;

	case(state)
		S_IDLE: begin
			if(in_valid) begin
				next_addr_reg = in_addr;
				if(in_mode == 1) begin
					next_data_reg[counter] = in_data;
				end
				next_counter = counter + 1;
				next_mode = in_mode;
				if(counter == 3) begin
					next_counter = 0;
					if(in_mode == 0) begin
						next_ar_addr = addr_reg;
						next_ar_valid = 1;
						next_state = S_AR;
					end
					else begin
						next_aw_addr = addr_reg;
						next_aw_valid = 1;
						next_state = S_AW;
					end
				end
			end
		end
		S_AR: begin
			if(ar_ready) begin
				next_ar_addr = 0;
				next_ar_valid = 0;
				next_r_ready = 1;
				next_state = S_R;
			end
		end
		S_R: begin
			if(r_valid) begin
				next_data_reg[counter] = r_data;
				next_counter = counter + 1;
				if(counter == 3) begin
					next_r_ready = 0;
					next_counter = 0;
					next_state = S_OUTPUT;
				end
			end
		end
		S_AW: begin
			if(aw_ready) begin
				next_aw_addr = 0;
				next_aw_valid = 0;
				next_w_valid  = 1;
				next_w_data = data_reg[0];
				next_counter = 1;
				next_state = S_W;
			end
		end
		S_W: begin
			if(w_ready) begin
				next_w_data = data_reg[counter];
				next_counter = counter + 1;
				if(counter == 4) begin
					next_w_data = 0;
					next_w_valid = 0;
					next_counter = 0;
					next_state = S_OUTPUT;
				end
			end
		end
		S_OUTPUT: begin
			next_out_valid = 1;
			if(mode == 0) begin
				next_out_data = data_reg[counter];
			end
			next_counter = counter + 1;
			if(counter == 4) begin
				next_out_data = 0;
				next_out_valid = 0;
				next_counter = 0;
				next_state = S_IDLE;
			end
		end
	endcase
end

endmodule