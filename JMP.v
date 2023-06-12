`define JAL_BITS    3'b010
`define JALR_BITS   3'b011

`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

module JMP(
    input wire clock,
    input wire new_jmp,         // Indica que hay algun salto (branch o JAL(R)) 
    input wire [2:0] jmp_type,  // jmp_type, codifican todos los tipos de saltos posibles (JAL/R y condicionales)
    input wire [5:0] jal_rs,   // source en caso de JALR
    input wire [31:0] busJ,     // bus para acceder al banco de registros
    input wire [4:0] rd,        // rd para los JAL(R)
    input wire bit_bus_C,       // Para evaluar si se salta o no
    input wire zero,            // Bit de zero de la ALU
    input wire [31:0] imm,      // Valor inmediato para calcular la nueva direccion
    input wire [31:0] pc,       // Valor de PC 
    input wire reset,           // Para restear los shift register de los saltos condicionales
    
    output reg [31:0] newPC,   // Nueva direccion del PC, si se realiza el salto
    output reg ctrlFetch,       // Decide si agarra el PC de un salto condicional o de un JAL/R o ninguno
    output reg reset_branch,
    output reg reset_jal,
    output reg halt
);

    reg reset_branch_en;        // Señal combinacional que se activa cuando hay que realizar algun salto
    reg reset_jal_en;

    reg [2:0]   jmp_type1;      // Primer registro del shift register
    reg [2:0]   jmp_type2;      // Segundo registro del shift register
    reg new_jmp1;               // Idem
    reg new_jmp2;
    reg [31:0]  pc1;            // Primer registro de Hipothetical PC 
    reg [31:0]  pc2;
    reg [31:0] newHipAdd;       // Hipothetical address para branch condicional, no para JAL/R      

    reg [31:0] nextPCJal;       // Idem newHipAdd pero para JAL
    reg ctrlJAL;

    
    reg [5:0] prev_rd[2];   // 2 registros de causalidad en caso de JAL(R)


    always @(*) begin
        halt = 0;
        
        // HALT por branches pendientes de evaluar
        if (ctrlJAL && (new_jmp1 || new_jmp2)) begin
            halt = 1;
        end
		
        // HALT por causalidad en rs (solo JALR)
        if (jal_rs != 0 && (jal_rs == prev_rd[0] || jal_rs == prev_rd[1])) begin
			halt = 1;
		end
    end

    always @(*)begin
        // branch
        if (new_jmp == 1 && (jmp_type != `JAL_BITS && jmp_type != `JALR_BITS)) begin
            newHipAdd = $signed(imm) + pc - 8;
        end
        else begin
            newHipAdd = 0;
        end
    end

    always @(*)begin
        // JAL/R
        ctrlJAL = 0;
        reset_jal_en = 0;
        if (new_jmp == 1 && (jmp_type == `JAL_BITS || jmp_type == `JALR_BITS)) begin
            nextPCJal = $signed(imm) + busJ;  // JAL rs = PC, JALR rs = rs1
            ctrlJAL = 1;
            reset_jal_en = 1;
        end
    end

    // Aca se selecciona el newPC. Si habia operaciones de branch, se priorizan, si no, se hace el JAL(R)
    always @(*) begin
        ctrlFetch = 0;
        if (ctrlJAL && !halt) begin    // Se hace JAL(R)
            newPC = nextPCJal;
            ctrlFetch = reset_jal_en;
        end
        else begin          // Se hace branch
            newPC = pc2;
            ctrlFetch = reset_branch_en;
        end
    end

    always @(posedge clock)begin
        if(reset)begin
				// branches
            jmp_type1 <= 0;
            jmp_type2 <= 0;
            pc1 <= 0;
            pc2 <= 0;
            new_jmp1 <= 0;
            new_jmp2 <= 0;
				
				// jumps
				prev_rd[1] <= 0;
				prev_rd[0] <= 0;
				
        end
        else begin
            jmp_type1 <= jmp_type;
            jmp_type2 <= jmp_type1;
            pc1 <= newHipAdd;
            pc2 <= pc1;
            new_jmp1 <= new_jmp;
            new_jmp2 <= new_jmp1;
				
				// jumps
				prev_rd[1] <= prev_rd[0];
				prev_rd[0] <= halt ? 6'b0 : rd;    // Es necesario resetear, por si rs=rd. Solo el mas nuevo. Puede haber espera de dos ciclos
        end
    end

    always @(negedge clock)begin
        reset_branch <= reset_branch_en;
        reset_jal <= reset_jal_en;
    end

    always @(*) begin
        reset_branch_en = 0;
        if(new_jmp2 == 1 && (jmp_type2 != `JAL_BITS && jmp_type2 != `JALR_BITS)) begin
            case(jmp_type2)
                `BEQ:begin
                    if(zero) begin
                        reset_branch_en = 1;
                    end
                end
                `BNE:begin
                    if(~zero) begin
                        reset_branch_en = 1;
                    end
                end
                `BLT:begin
                    if(bit_bus_C == 1) begin
                        reset_branch_en = 1;
                    end
                end
                `BGE:begin
                    if(bit_bus_C == 0) begin
                        reset_branch_en = 1;
                    end
                end
                `BLTU:begin
                    if(bit_bus_C == 1) begin
                        reset_branch_en = 1;
                    end
                end
                `BGEU:begin
                    if(bit_bus_C == 0) begin
                        reset_branch_en = 1;
                    end
                end
                default: begin
                end
            endcase
        end
    end
endmodule