`define JAL_BITS    3'b010
`define JALR_BITS   3'b011

`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

module JMP(
    input wire new_jmp,
    input wire [2:0] jmp_type,
    input wire bit_bus_C,
    input wire zero,
    input wire [31:0] imm,
    input wire [31:0] pc,
    input wire clock,
    input wire reset,
    
    output wire [31:0] newPC,
    output reg ctrlFetch,
    output reg global_reset
);

    reg global_reset_en;

    reg [2:0]   jmp_type1;
    reg [2:0]   jmp_type2;
    reg new_jmp1;
    reg new_jmp2;
    reg [31:0]  pc1;
    reg [31:0]  pc2;
    reg [31:0] newHipAdd;
	 
	 assign newPC = pc2;

    always @(*)begin
        if (new_jmp == 1 && (jmp_type != `JAL_BITS && jmp_type != `JALR_BITS)) begin
            newHipAdd = $signed(imm) + pc - 8;
        end
        else begin
            newHipAdd = 0;
        end
    end

    always @(posedge clock)begin
        if(reset == 1)begin
            jmp_type1 <= 0;
            jmp_type2 <= 0;
            pc1 <= 0;
            pc2 <= 0;
            new_jmp1 <= 0;
            new_jmp2 <= 0;
        end
        else begin
            jmp_type1 <= jmp_type;
            jmp_type2 <= jmp_type1;
            pc1 <= newHipAdd;
            pc2 <= pc1;
            new_jmp1 <= new_jmp;
            new_jmp2 <= new_jmp1;
        end
    end

    always @(negedge clock)begin
        global_reset <= global_reset_en;
    end

    always @(*) begin
        global_reset_en = 0;
        ctrlFetch = 0;
        if(new_jmp2 == 1 && (jmp_type2 != `JAL_BITS && jmp_type2 != `JALR_BITS)) begin
            case(jmp_type2)
                `BEQ:begin
                    if(zero) begin
                        global_reset_en = 1;
                        ctrlFetch = 1;
                    end
                end
                `BNE:begin
                    if(~zero) begin
                        global_reset_en = 1;
                        ctrlFetch = 1;
                    end
                end
                `BLT:begin
                    if(bit_bus_C == 1) begin
                        global_reset_en = 1;
                        ctrlFetch = 1;
                    end
                end
                `BGE:begin
                    if(bit_bus_C == 0) begin
                        global_reset_en = 1;
                        ctrlFetch = 1;
                    end
                end
                `BLTU:begin
                    if(bit_bus_C == 1) begin
                        global_reset_en = 1;
                        ctrlFetch = 1;
                    end
                end
                `BGEU:begin
                    if(bit_bus_C == 0) begin
                        global_reset_en = 1;
                        ctrlFetch = 1;
                    end
                end
                default: begin
                end
            endcase
        end
    end
endmodule