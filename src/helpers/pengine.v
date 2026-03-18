`default_nettype none

module pengine (
    input  wire       rst,
    input  wire       clk,
    input  wire       cmd_valid,
    input  wire [1:0] cmd_type,
    input  wire [9:0] cmd_data,
    output reg  [9:0] x_ball,
    output reg  [9:0] y_ball
);

//localparam CMD_SET_X = 2'b00;
localparam CMD_SET_X = 2'b01;
localparam CMD_SET_Y = 2'b10;
//localparam CMD_SET_VY = 2'b11;

always @(posedge clk) begin
    if (rst) begin
        x_ball <= 10'd0;
        y_ball <= 10'd0;
    end else if (cmd_valid) begin
        case (cmd_type)
            CMD_SET_X: begin
                x_ball <= cmd_data;
            end
            CMD_SET_Y: begin
                y_ball <= cmd_data;
            end
            default: begin
                x_ball <= x_ball;
                y_ball <= y_ball;
            end

        endcase
    end
end

endmodule
