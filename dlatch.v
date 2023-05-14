module dlatch(clk, en, d, q);

input clk, en, d;
output q;

reg q;

always @(posedge clk) begin
    if (en) begin
        q <= d;
    end
end

endmodule
