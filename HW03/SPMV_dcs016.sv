module SPMV(
    clk, 
	rst_n, 
	// input 
	in_valid, 
	weight_valid, 
	in_row, 
	in_col, 
	in_data, 
	// output
	out_valid, 
	out_row, 
	out_data, 
	out_finish
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n; 
// input
input in_valid, weight_valid; 
input [4:0] in_row, in_col; 
input [7:0] in_data; 
// output 
output logic out_valid; 
output logic [4:0] out_row; 
output logic [17:0] out_data; 
output logic out_finish; 

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic next_out_valid;
logic [4:0] next_out_row;
logic [17:0] next_out_data;
logic next_out_finish;

logic [7:0] in_vector [31:0];
logic [7:0] next_in_vector [31:0];
logic [17:0] out_vector [31:0];
logic [17:0] next_out_vector [31:0];
logic [4:0] out_vector_position [31:0];
logic [4:0] next_out_vector_position [31:0];

logic [4:0] last_row;
logic [4:0] out_counter, next_out_counter;
logic [4:0] out_count, next_out_count;

logic flag, next_flag;
logic flag2, next_flag2;

integer i, j, k, l;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

always_ff @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		out_row <= 0;
		out_data <= 0;
		out_finish <= 0;
		out_counter <= 0;
		out_count <= 0;
		flag <= 0;
		flag2 <= 0;
		for(i=0; i<32; i++) begin
			in_vector[i] <= 0;
			out_vector[i] <= 0;
		end
		
	end
	else begin
		out_valid <= next_out_valid;
		out_row <= next_out_row;
		out_data <= next_out_data;
		out_finish <= next_out_finish;
		out_counter <= next_out_counter;
		out_count <= next_out_count;
		flag <= next_flag;
		flag2 <= next_flag2;
		last_row <= in_row;
		for(j=0; j<32; j++) begin
			in_vector[j] <= next_in_vector[j];
			out_vector[j] <= next_out_vector[j];
			out_vector_position[j] <= next_out_vector_position[j];
		end
	end
end

always_comb begin
	next_out_valid = 0;
	next_out_row = 0;
	next_out_data = 0;
	next_out_finish = 0;
    next_out_counter = out_counter;
    next_out_count = out_count;
	next_flag = flag;
	next_flag2 = flag2;
    for(k=0; k<32; k++) begin
        next_in_vector[k] = in_vector[k];
        next_out_vector[k] = out_vector[k];
        next_out_vector_position[k] = out_vector_position[k];
    end

	if(in_valid) begin
		next_in_vector[in_row] = in_data;
	end
	else if(weight_valid) begin
		next_flag = 1'b1;
		next_out_vector[in_row] = out_vector[in_row] + (in_data * in_vector[in_col]);
		if(in_row != last_row && out_vector[last_row] != 18'd0) begin
			next_out_vector_position[out_counter] = last_row;
			next_out_counter = out_counter + 5'd1;
		end
		next_out_count = 0;
	end
	else if(flag) begin
		if(!flag2 && (out_vector[5'd31] != 18'd0 || out_counter == 5'd0)) begin
			next_out_vector_position[out_counter] = last_row;
			next_out_counter = out_counter + 5'd1;
			next_flag2 = 1'b1;
		end
		next_out_valid = 1'b1;
		next_out_row = next_out_vector_position[out_count];
		next_out_data = out_vector[next_out_row];
		next_out_count = out_count + 5'd1;
		if(next_out_counter == next_out_count) begin
			next_out_finish = 1'b1;
			next_out_counter = 0;
			next_flag = 0;
			next_flag2 = 0;
			for(l=0; l<32; l++) begin
				next_in_vector[l] = 0;
				next_out_vector[l] = 0;
			end
		end
	end
end

endmodule
