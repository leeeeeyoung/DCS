module Seq(
	// Input signals
	clk,
	rst_n,
	in_valid,
	card,
	// Output signals
	win,
	lose,
	sum
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [3:0] card;
output logic win, lose;
output logic [4:0] sum;

//---------------------------------------------------------------------
//   REG AND WIRE DECLARATION                         
//---------------------------------------------------------------------

logic done;
logic [4:0] next_sum;
logic next_win, next_lose;

//---------------------------------------------------------------------
//   YOUR DESIGN                        
//---------------------------------------------------------------------

always_comb begin
	next_sum = sum;
	next_win = win;
	next_lose = lose;

	if (in_valid) begin
		if (!done) begin
			if(card > 4'd10) begin
				next_sum = sum + 4'd10;
			end
			else begin
				next_sum = sum + card;
			end
			if (next_sum > 5'd16) begin
				if (next_sum <= 5'd21) begin
					next_win = 1'b1;
					next_lose = 1'b0;
				end else begin
					next_win = 1'b0;
					next_lose = 1'b1;
				end
			end else begin
				next_win = 1'b0;
				next_lose = 1'b0;
			end
		end else begin
			if(card > 4'd10) begin
				next_sum = 4'd10;
			end
			else begin
				next_sum = card;
			end
			next_win = 1'b0;
			next_lose = 1'b0;
		end
	end else begin
		next_win = 1'b0;
		next_lose = 1'b0;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		sum <= 5'b0;      
		done <= 1'b0;     
		win <= 1'b0;      
		lose <= 1'b0;     
	end else begin
		if (in_valid) begin
			if (!done) begin
				sum <= next_sum;
				win <= next_win;
				lose <= next_lose;
				if (next_sum > 5'd16)
					done <= 1'b1;
			end else begin
				sum <= 0;
				done <= 1'b0;
				win <= 1'b0;
				lose <= 1'b0;
			end
		end else begin
			win <= 1'b0;
			lose <= 1'b0;
		end
	end
end

endmodule