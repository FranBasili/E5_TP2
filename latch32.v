module latch32(
input wire clk, 
input wire en, 
input wire [31:0]in, 
output reg [31:0]out
);



always @(posedge clk) begin
    if (en) begin
        out <= in;
    end
end

endmodule
