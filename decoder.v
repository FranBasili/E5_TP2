`define R_ADD_Type      7'b0110011  // ADD, SUB, instructions para abajo
`define B_Type          7'b1100011  
`define S_Type          7'b0100011
`define U_LUI_Type      7'b0110111
`define U_AUIPC_Type    7'b0010111   
`define J_Type          7'b1101111
`define I_JALR_Type     7'b1100111  // JALR
`define I_LOAD_Type     7'b0000011  // LOAD and STORE instructions
`define IMM_Type        7'b0010011	// Incluye I-type y shifts IMM

`define JAL_BITS    3'b010
`define JALR_BITS   3'b011

`define STORE_INST  1'b1
`define LOAD_INST   1'b0
`define LAM_NEW     1'b1

`define OPCODE_ALU_RESTA    	10'b0100000000
`define OPCODE_ALU_SUMA_IMM	    10'b0000000000
`define OPCODE_ALU_SLT          10'b0000000010
`define OPCODE_ALU_SLTU         10'b0000000011

`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111


module decoder(
	input[31:0] instruction,

	output wire [9:0] aluCtrl,   // {funct7, funct3}
	output wire [31:0] imm,
	output wire [5:0] selA,      // Este tiene 6 porque incluye al PC
	output wire [4:0] selB,
	output wire [5:0] selOut,
    output wire imm_en,           // para la ALU (?)
    output wire [2:0] jmp_type,   // On new jump detected (JMP control unit)
    output wire new_jmp,
    output wire [8:0] lam_control, // LAM unit signals control
    output wire lam_new,
    output wire demux_alu        // for routing alu output signals  
);

	reg [9:0] curr_aluCtrl;   
	reg [5:0] curr_selA;      
	reg [4:0] curr_selB;
	reg [5:0] curr_selOut;
    reg curr_imm_en;
	reg [31:0] curr_imm;
    reg [2:0] curr_jmp_type;
    reg curr_new_jmp;
    reg [8:0] curr_lam_control;
    reg curr_lam_new;
    reg curr_demux_alu;


	always @(instruction) begin
        curr_selA = 0;
        curr_selB = 0;
        curr_selOut = 0;
        curr_imm_en = 0;
        curr_imm = 0;
        curr_aluCtrl = 0;
        curr_jmp_type = 0;
        curr_new_jmp = 0;
        curr_lam_control = 0;
        curr_lam_new = 0;
        curr_demux_alu = 0;    // en 0 escribo sobre el banco de reg

		  
        case (instruction[6:0])
            // busA = rs1, busB = rs2, selOut = rd, alctr = funct7 U funct3 
            `R_ADD_Type: begin
                curr_selA = instruction[19:15]; curr_selB = instruction[24:20]; curr_selOut = instruction[11:7]; 
                curr_aluCtrl = { instruction[31:25], instruction[14:12] }; 
                curr_imm_en = 0;
            end
            
            
            `B_Type: begin
                curr_selA = instruction[19:15]; curr_selB = instruction[24:20];
                curr_selOut = 0; // escribo en rd0
                curr_imm[31:12] = {20{instruction[31]}};
                curr_imm[11:0] = { instruction[7], instruction[30:25], instruction [11:8], 1'b0};
                // TODO: Ver como hacerlo
                    // Una forma: Hacer siempre la resta y pasarle el fun3 al JMP Control y que se fije
                if (instruction[14:12] == `BEQ || instruction[14:12] == `BNE)
                    curr_aluCtrl = `OPCODE_ALU_RESTA;  // 10 bits de SUB funct (?)
                else if (instruction[14:12] == `BLT || instruction[14:12] == `BGE)
                    curr_aluCtrl = `OPCODE_ALU_SLT;
                else if (instruction[14:12] == `BLTU || instruction[14:12] == `BGEU)
                    curr_aluCtrl = `OPCODE_ALU_SLTU;
                curr_jmp_type = instruction[14:12];
                curr_new_jmp = 1;
                curr_demux_alu = 0;
            end

            `S_Type: begin
                curr_selA = instruction[19:15]; curr_selB = instruction[24:20]; // ESTO VA A MEMORIA, HAY QUE AVISAR DE ALGUNA FORMA 
                curr_imm = { {21{instruction[31]}}, instruction[30:25], instruction[11:8], instruction[7] }; 
                curr_aluCtrl = `OPCODE_ALU_SUMA_IMM;
                curr_imm_en = 1;
                curr_lam_control = {`STORE_INST, instruction[14:12], instruction[24:20]};
                curr_demux_alu = 1;
            end
          
            `U_LUI_Type: begin
                curr_imm = {instruction[31:12], {12{1'b0}}}; 
                curr_selOut = instruction[11:7];
                curr_aluCtrl = `OPCODE_ALU_SUMA_IMM;
                curr_selA = 0;
                curr_imm_en = 1;
            end

            `U_AUIPC_Type: begin
                curr_imm = {instruction[31:12], {12{1'b0}}}; 
                curr_selOut = instruction[11:7];
                curr_aluCtrl = `OPCODE_ALU_SUMA_IMM;
                curr_selA = 32; // PC index
                curr_imm_en = 1;
            end

			`J_Type: begin
                curr_imm = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                curr_selOut = instruction[11:7];
                curr_new_jmp = 1;
                curr_jmp_type = `JAL_BITS;
            end

            `I_JALR_Type: begin
                curr_imm = { {21{instruction[31]}}, instruction[30:20]};
                curr_selOut = instruction[11:7];
                curr_new_jmp = 1;
                curr_jmp_type = `JALR_BITS;
            end

            `I_LOAD_Type: begin
                curr_imm = { {21{instruction[31]}}, instruction[30:20]};
                curr_lam_new = 1;
                curr_lam_control = {`LOAD_INST, instruction[14:12], instruction[11:7]};
                curr_imm_en = 1;
                curr_aluCtrl = `OPCODE_ALU_SUMA_IMM;
                curr_demux_alu = 1;
            end

            `IMM_Type: begin
                curr_selA = instruction[19:15];
                curr_selOut = instruction[11:7];
                // Extension de signo para valores inmediatos
                curr_imm = {{21{instruction[31]}}, instruction[30:20]};
                // Para facilitar la logica, siempre ponemos todo el inmediato y el aluCtrl, despues la ALU se encarga
                curr_aluCtrl = { instruction[31:25], instruction[14:12] };
                curr_imm_en = 1;
            end

             default:
                 curr_selOut = 0;
        endcase
	end

    assign  selA= curr_selA;
    assign  selB= curr_selB;
    assign  selOut= curr_selOut;
    assign  imm_en= curr_imm_en;
    assign  imm= curr_imm;
    assign  aluCtrl= curr_aluCtrl;
    assign  jmp_type = curr_jmp_type;
    assign  new_jmp = curr_new_jmp;
    assign  lam_control = curr_lam_control;
    assign  lam_new = curr_lam_new;
    assign  demux_alu = curr_demux_alu;

endmodule