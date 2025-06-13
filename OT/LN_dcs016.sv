module LN(
    //OUTPUT 
    clk,
    rst_n,
    in_valid,
    in_data,

    //INPUT
    out_valid,
	out_data
);

// INPUT
input clk;
input rst_n;
input in_valid;
input signed [7:0] in_data;

// OUTPUT
output logic out_valid;
output logic signed [7:0] out_data;

//================================================================
// DESIGN
//================================================================

logic stage1_valid;
logic [2:0] stage1_counter;
logic signed [0:7][10:0] stage1_data;

logic signed [0:7][10:0] stage2_data;

logic stage3_valid;
logic [2:0] stage3_counter;
logic signed [10:0] stage3_sum;

logic signed [10:0] stage4_mean;
logic signed [0:7][10:0] stage4_data;

logic stage5_valid;
logic [2:0] stage5_counter;
logic signed [10:0] stage5_sum;

logic signed [7:0] stage6_sig;
logic signed [10:0] stage6_mean;
logic signed [0:7][10:0] stage6_data;

logic stage7_valid;
logic [2:0] stage7_counter;
logic signed [0:7][10:0] stage7_data;

logic [2:0] stage8_counter;
logic signed [0:7][10:0] stage8_data;
logic signed [7:0] stage8_sig;

logic flag;
logic [5:0] counter;

logic o1_valid;
logic signed [10:0] out_1, out_2, out_3;
logic signed [7:0] sig;

always_ff @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_data <= 0;

        stage1_valid <= 0;
        stage1_counter <= 0;
        stage1_data <= 0;

        stage2_data <= 0;

        stage3_valid <= 0;
        stage3_counter <= 0;
        stage3_sum <= 0;

        stage4_mean <= 0;
        stage4_data <= 0;

        stage5_valid <= 0;
        stage5_counter <= 0;
        stage5_sum <= 0;

        stage6_sig <= 0;
        stage6_mean <= 0;

        stage7_valid <= 0;
        stage7_counter <= 0;
        stage7_data <= 0;

        stage8_counter <= 0;
        stage8_data <= 0;
        stage8_sig <= 0;

        flag <= 0;
        counter <= 0;

        out_1 <= 0;
        o1_valid <= 0;
        sig <= 0;
    end
    else begin
        if(flag == 1 && !in_valid) begin
            counter <= counter + 1;
        end
        if(in_valid) begin
            flag <= 1;
            if(stage1_counter == 7) begin
                for(int i=0; i<7; i++) begin
                    stage2_data[i] <= stage1_data[i];
                end
                stage2_data[7] <= in_data;
                stage1_valid <= 1;
                stage1_counter <= 0;
            end
            else begin
                stage1_data[stage1_counter] <= in_data;
                stage1_counter <= stage1_counter + 1;
            end
        end
        if(stage1_valid) begin
            if(stage3_counter == 7) begin
                stage3_valid <= 1;
                stage3_sum <= 0;
                stage4_data <= stage2_data;
                stage4_mean <= $signed((stage3_sum + stage2_data[stage3_counter])) / $signed(8);
                stage3_counter <= 0;
            end
            else begin
                stage3_sum <= stage3_sum + stage2_data[stage3_counter];
                stage3_counter <= stage3_counter + 1;
            end
        end
        if(stage3_valid) begin
            if(stage5_counter == 7) begin
                stage5_counter <= 0;
                if($signed(stage4_data[stage5_counter] - stage4_mean) < 0) begin
                    stage6_sig <= $signed(stage5_sum + (stage4_mean - stage4_data[stage5_counter]))  / $signed(8);
                end
                else begin
                    stage6_sig <= $signed(stage5_sum + (stage4_data[stage5_counter] - stage4_mean)) / $signed(8);
                end
                stage5_sum <= 0;
                stage6_mean <= stage4_mean;
                stage6_data <= stage4_data;
                stage5_valid <= 1;
            end
            else begin
                if($signed(stage4_data[stage5_counter] - stage4_mean) < 0) begin
                    stage5_sum <= $signed(stage5_sum + (stage4_mean - stage4_data[stage5_counter]));
                end
                else begin
                    stage5_sum <= $signed(stage5_sum + (stage4_data[stage5_counter] - stage4_mean));
                end
                stage5_counter <= stage5_counter + 1;
            end
        end
        if(stage5_valid) begin
            if(stage7_counter == 7) begin
                for(int i=0; i<7; i++) begin
                    stage8_data[i] <= stage7_data[i];
                    
                end
                stage8_data[7] <= $signed(stage6_data[7] - stage6_mean);
                stage8_sig <= stage6_sig;
                stage7_valid <= 1;
                stage7_counter <= 0;
            end
            else begin
                stage7_data[stage7_counter] <= $signed(stage6_data[stage7_counter] - stage6_mean);
                stage7_counter <= stage7_counter + 1;
            end
        end
        if(stage7_valid) begin
            out_1 <= $signed(stage8_data[stage8_counter]);
            o1_valid <= 1;
            sig <= stage8_sig;
            if(stage8_counter == 7) begin
                stage8_counter <= 0;
            end
            else begin
                stage8_counter <= stage8_counter + 1;
            end
        end
        if(o1_valid) begin
            out_valid <= 1;
            out_data <= out_3;
        end
        if(counter >= 33) begin
            out_valid <= 0;
            out_data <= 0;
        end
    end
end

always_comb begin
    out_2 = $signed(out_1);
    out_3 = 0;
    if($signed(out_2) >= 0) begin
        if(($signed(out_2) - $signed(sig)) >= 0) begin
            out_2 = $signed(out_2) - $signed(sig);
            out_3 = out_3 + 1;
        end
    end
    else begin
        if(($signed(out_2) + $signed(sig)) <= 0) begin
            out_2 = $signed(out_2) + $signed(sig);
            out_3 = out_3 - 1;
        end
    end
    if($signed(out_2) >= 0) begin
        if(($signed(out_2) - $signed(sig)) >= 0) begin
            out_2 = $signed(out_2) - $signed(sig);
            out_3 = out_3 + 1;
        end
    end
    else begin
        if(($signed(out_2) + $signed(sig)) <= 0) begin
            out_2 = $signed(out_2) + $signed(sig);
            out_3 = out_3 - 1;
        end
    end
    if($signed(out_2) >= 0) begin
        if(($signed(out_2) - $signed(sig)) >= 0) begin
            out_2 = $signed(out_2) - $signed(sig);
            out_3 = out_3 + 1;
        end
    end
    else begin
        if(($signed(out_2) + $signed(sig)) <= 0) begin
            out_2 = $signed(out_2) + $signed(sig);
            out_3 = out_3 - 1;
        end
    end
    if($signed(out_2) >= 0) begin
        if(($signed(out_2) - $signed(sig)) >= 0) begin
            out_2 = $signed(out_2) - $signed(sig);
            out_3 = out_3 + 1;
        end
    end
    else begin
        if(($signed(out_2) + $signed(sig)) <= 0) begin
            out_2 = $signed(out_2) + $signed(sig);
            out_3 = out_3 - 1;
        end
    end
end


endmodule
