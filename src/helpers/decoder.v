module decoder(
    input  wire       rst,
    input  wire       clk,

    input  wire [15:0] in,
    input  wire       val,
    output wire       rdy,

    output reg  [9:0] cmd_data,
    output reg   [1:0] cmd_type,
    output reg        cmd_valid
);

assign rdy = 1'b1;

always @(posedge clk) begin
    cmd_valid <= 1'b0;
    if (rst) begin
        cmd_valid <= 1'b0;
        cmd_data <= 6'd0;
        cmd_type <= 2'b00;
    end
    else if (!rst && val) begin
        cmd_valid <= 1'b1;
        cmd_data <= in[9:0];
        cmd_type <= in[15:14];
    end
end

endmodule