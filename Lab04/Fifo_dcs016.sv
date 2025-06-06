module Fifo(
    // Input signals
	clk, 
	rst_n, 
	write_valid, 
	write_data, 
	read_valid, 
    // Output signals
	write_full, 
	write_success, 
	read_empty, 	
	read_success, 
	read_data
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n;
input write_valid, read_valid; 
input [7:0] write_data;
output logic write_full, write_success, read_empty, read_success;
output logic [7:0] read_data;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

logic [7:0] fifo [0:9];
logic [3:0] count;

//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
		fifo[0] <= 0;
		fifo[1] <= 0;
		fifo[2] <= 0;
		fifo[3] <= 0;
		fifo[4] <= 0;
		fifo[5] <= 0;
		fifo[6] <= 0;
		fifo[7] <= 0;
		fifo[8] <= 0;
		fifo[9] <= 0;
		write_full <= 0;
		write_success <= 0;
		read_empty <= 0;
		read_success <= 0;
		read_data <= 0;
	end 
	else begin
		if(read_valid && write_valid) begin
			if(count == 0) begin
				read_data <= 0;
				read_empty <= 1'b1;
				read_success <= 0;
				fifo[count] <= write_data;
				write_full <= 0;
				write_success <= 1'b1;
				count <= count + 4'd1;
			end
			else begin
				read_data <= fifo[0];
				fifo[0] <= fifo[1];
				fifo[1] <= fifo[2];
				fifo[2] <= fifo[3];
				fifo[3] <= fifo[4];
				fifo[4] <= fifo[5];
				fifo[5] <= fifo[6];
				fifo[6] <= fifo[7];
				fifo[7] <= fifo[8];
				fifo[8] <= fifo[9];
				fifo[9] <= 0;
				read_empty <= 0;
				read_success <= 1'b1;
				fifo[count-4'd1] <= write_data;
				write_full <= 0;
				write_success <= 1'b1;
			end
		end
		else if(read_valid) begin
			write_full <= 0;
			write_success <= 0;
			if(count == 0) begin
				read_data <= 0;
				read_empty <= 1'b1;
				read_success <= 0;
			end
			else begin
				read_data <= fifo[0];
				fifo[0] <= fifo[1];
				fifo[1] <= fifo[2];
				fifo[2] <= fifo[3];
				fifo[3] <= fifo[4];
				fifo[4] <= fifo[5];
				fifo[5] <= fifo[6];
				fifo[6] <= fifo[7];
				fifo[7] <= fifo[8];
				fifo[8] <= fifo[9];
				fifo[9] <= 0;
				read_empty <= 0;
				read_success <= 1'b1;
				count <= count - 4'd1;
			end
		end
		else if(write_valid) begin
			read_data <= 0;
			read_empty <= 0;
			read_success <= 0;
			if(count == 4'd10) begin
				write_full <= 1'b1;
				write_success <= 0;
			end
			else begin
				fifo[count] <= write_data;
				write_full <= 0;
				write_success <= 1'b1;
				count <= count + 4'd1;
			end
		end
		else begin
			write_full <= 0;
			write_success <= 0;
			read_empty <= 0;
			read_success <= 0;
			read_data <= 0;
		end
	end
end

endmodule