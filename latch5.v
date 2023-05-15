module latch5(
input wire clk, 
input wire en, 
input wire [4:0]in, 
output reg [4:0]out
);



always @(posedge clk) begin
    if (en) begin
        out <= in;
    end
end

endmodule
