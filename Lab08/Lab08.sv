module axi_master (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    input  logic        in_mode,
    input  logic [3:0]  in_addr,
    input  logic [7:0]  in_data,
    output logic        out_valid,
    output logic [7:0]  out_data,

    output logic [3:0]  ar_addr,
    output logic        ar_valid,
    input  logic        ar_ready,
    input  logic [7:0]  r_data,
    input  logic        r_valid,
    output logic        r_ready,

    output logic [3:0]  aw_addr,
    output logic        aw_valid,
    input  logic        aw_ready,
    output logic [7:0]  w_data,
    output logic        w_valid,
    input  logic        w_ready
);
	
    parameter S_IDLE = 3'd0, S_AR = 3'd1, S_R = 3'd2, S_AW = 3'd3, S_W = 3'd4, S_OUTPUT = 3'd5;

    logic [2:0] state, next_state;
    logic [3:0] counter, next_counter;
    logic [3:0] addr_reg, next_addr_reg;

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

    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= 0;
            counter <= 0;
            addr_reg <= 0;

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
                    next_data_reg[counter] = in_data;
                    next_counter = counter + 1;
                    if(counter == 3) begin
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
                    next_counter = 0;
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
                    next_counter = 0;
                    next_w_data = data_reg[0];
                end
            end
            S_W: begin
                if(w_ready) begin
                    next_w_data = data[counter];
                    next_counter = counter + 1;
                    if(counter == 3) begin
                        next_w_data = 0;
                        next_w_valid = 0;
                        next_state = S_OUTPUT;
                    end
                end
            end
            S_OUTPUT: begin
                next_out_valid = 1;
                next_out_data = data_reg[counter];
                next_counter = counter + 1;
                if(counter == 3) begin
                    next_out_valid = 0;
                    next_coutner = 0;
                    next_state = S_IDLE;
                end
            end
        endcase
    end
    
endmodule