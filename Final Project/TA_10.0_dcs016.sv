module TA(
    clk, 
	rst_n, 
	// input 
	i_valid, 
	i_length,
	m_ready,
	// virtual memory
	m_data,
	m_read,
	m_addr,
	// output 
	o_valid, 
	o_data 
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n; 
// input
input i_valid; 
input [1:0] i_length;
input m_ready;
// virtual memory
input [0:7][3:0] m_data; 
output logic m_read;
output logic  [5:0] m_addr; 
// output 
output logic o_valid; 
output logic [40:0] o_data; 

parameter IDLE = 0, INIT = 1, LOAD_I = 2, CART = 3, FETCH = 4, MUL = 5, OUT = 6;

logic [2:0] state, next_state;
logic [1:0] op_type, next_op_type;

logic [0:7][3:0] m_data_store, next_m_data_store;

logic next_m_read;
logic [5:0] next_m_addr;
logic next_o_valid;
logic [40:0] next_o_data;

logic [0:31][0:7][3:0] I, next_I;
logic [0:31][0:7][9:0] Q, next_Q;
logic [0:31][0:7][10:0] K, next_K;
logic [0:31][21:0] S, next_S;
logic [0:31][21:0] O, next_O;

logic [5:0] length, next_length;
logic [2:0] len, next_len;
logic [4:0] row, next_row;
logic [4:0] col, next_col;

logic [26:0] sum;
logic [21:0] avg;
logic [0:31][21:0] matrix_a;
logic [0:31][10:0] matrix_b;
logic [0:31][33:0] M;

always_ff @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
		op_type <= 0;

		m_data_store <= 0;

		m_read <= 0;
		m_addr <= 0;
		o_valid <= 0;
		o_data <= 0;

		I <= 0;
		Q <= 0;
		K <= 0;
		S <= 0;
		O <= 0;

		length <= 0;
		len <= 0;
		row <= 0;
		col <= 0;
	end
	else begin
		state <= next_state;
		op_type <= next_op_type;

		m_data_store <= next_m_data_store;

		m_read <= next_m_read;
		m_addr <= next_m_addr;
		o_valid <= next_o_valid;
		o_data <= next_o_data;

		I <= next_I;
		Q <= next_Q;
		K <= next_K;
		S <= next_S;
		O <= next_O;

		length <= next_length;
		len <= next_len;
		row <= next_row;
		col <= next_col;
	end
end

always_comb begin
	next_state = state;
	next_op_type = op_type;

	next_m_data_store = m_data_store;

	next_m_read = m_read;
	next_m_addr = m_addr;
	next_o_valid = 0;
	next_o_data = 0;

	next_I = I;
	next_Q = Q;
	next_K = K;
	next_S = S;
	next_O = O;

	next_length = length;
	next_len = len;
	next_row = row;
	next_col = col; 

	case(state)
		IDLE: begin
			next_op_type = 0;
			next_S = 0;
			next_O = 0;
			if(i_valid) begin
				next_length = i_length;
			end
			if(m_ready) begin
				next_state = INIT;
			end
		end
		INIT: begin
			next_state = LOAD_I;

			next_m_read = 1;
			next_m_addr = 0;

			sum = length + 2;
			next_len = sum;
			next_length = 1 << sum;
		end
		LOAD_I: begin
			for(int i=0; i<8; i++) begin
				next_I[m_addr][i] = m_data[i];
			end

			if(m_addr == (length - 1)) begin
				next_state = CART;
				next_m_read = 0;
				next_m_addr = 0;
			end
			else begin
				next_m_addr = m_addr + 1;
			end
		end
		CART: begin
			M = 0;
			if(op_type == 0) begin
				for(int i=0; i<8; i++) begin
					M[i] = I[m_addr][i];
				end
			end
			else begin
				for(int i=0; i<32; i++) begin
					M[i] = S[i];
				end
			end

			sum = 0;
			for(int i=0; i<32; i++) begin
				sum += M[i];
			end

			if(op_type == 0) begin
				avg = sum >> 3;
				for(int j=0; j<8; j++) begin
					if(I[m_addr][j] < avg) begin
						next_I[m_addr][j] = 0;
					end
				end

				if(m_addr == (length - 1)) begin
					next_state = FETCH;
					next_m_read = 1;
				end

				next_m_addr = m_addr + 1;
			end
			else begin
				avg = sum >> len;
				if(S[length - 1] < avg) begin
					next_O[col] = 0;
				end
				else begin
					next_O[col] = S[length - 1];
				end
				next_state = MUL;
				if(col == (length - 1)) begin
					next_col = 0;
					next_op_type = 0;

					if(length == 4) begin
						next_m_read = 1;
					end
					else begin
						next_m_read = 0;
					end
				end
				else begin
					next_col = col + 1;
				end
			end
		end
		FETCH: begin
			next_m_data_store = m_data;
			next_m_addr = m_addr + 1;
			next_state = MUL;

			if(length != 4) begin
				next_m_read = 0;
			end
		end
		MUL: begin
			if(op_type == 0) begin
				for(int i=0; i<4; i++) begin
					for(int j=0; j<8; j++) begin
						matrix_a[i * 8 + j] = I[row + i][j];
						matrix_b[i * 8 + j] = m_data_store[j];
					end
				end
			end
			else if(op_type == 1) begin
				for(int i=0; i<4; i++) begin
					for(int j=0; j<8; j++) begin
						matrix_a[i * 8 + j] = Q[row + i][j];
						matrix_b[i * 8 + j] = K[col][j];
					end
				end
			end
			else begin
				for(int i=0; i<32; i++) begin
					matrix_a[i] = O[i];
					matrix_b[i] = K[i][col];
				end
			end

			for(int i=0; i<4; i++) begin
				M[i] = 0;
				for(int j=0; j<8; j++) begin
					M[i] += matrix_a[i * 8 + j] * matrix_b[i * 8 + j];
				end
			end

			if(op_type == 0) begin
				if(m_addr < (length + 9)) begin
					for(int k=0; k<4; k++) begin
						next_Q[row + k][col] = M[k];
					end
				end
				else begin
					for(int k=0; k<4; k++) begin
                        next_K[row + k][col] = M[k];
                    end
				end
				
				if(length == 4 || row == (length - 8)) begin
					next_m_read = 1;
				end
				else begin
					next_m_read = 0;
				end

				if(row == (length - 4)) begin
					next_row = 0;
					next_m_addr = m_addr + 1;
					next_m_data_store = m_data;

					if(col == 7) begin
                        next_col = 0;
                    end
                    else begin
                        next_col = col + 1;
                    end

					if(m_addr == (length + 16)) begin
						next_op_type = 1;
						next_m_read = 0;
					end
					else if(m_addr == (length + 23)) begin
						next_m_read = 0;
					end
					else if(m_addr == (length + 24)) begin
						next_op_type = 2;
						next_m_read = 0;
						next_m_addr = 0;
						next_col = 0;
					end
				end
				else begin
					if(m_addr == (length + 24)) begin
						next_m_read = 0;
					end
					next_row = row + 4;
				end
			end
			else if(op_type == 1) begin
				for(int k=0; k<4; k++) begin
                    next_S[row + k] = M[k];
                end

                if(row == (length - 4)) begin
                    next_row = 0;
					next_state = CART;
                end
                else begin
                    next_row = row + 4;
                end
			end
			else begin
				next_o_valid = 1;
				next_o_data = M[0] + M[1] + M[2] + M[3];

				if(col == 7) begin
					next_state = IDLE;
					next_col = 0;
				end
				else begin
					next_col = col + 1;
				end
			end
		end
	endcase
end

endmodule
