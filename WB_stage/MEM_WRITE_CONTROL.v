`include "Opcode.vh"

module MEM_WRITE_CONTROL(instruction,ALU_result,PC,din_raw,dmem_wea,imem_wea,dout);
    input [31:0] instruction;
    input [31:0] ALU_result;
    input [31:0] PC;
    input [31:0] din_raw;
    output reg [3:0] dmem_wea;
    output reg [3:0] imem_wea;
    output reg [31:0] dout;
    
    wire [31:0] addr = ALU_result;
    wire [6:0] opcode7 = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [3:0] DMEM_type = ALU_result[31:28];
    
    wire mem_type = DMEM_type == 4'b0011 || DMEM_type == 4'b0001 || DMEM_type == 4'b0010 || DMEM_type == 4'b1000;
    
        always @(*) begin
        if (mem_type) begin
            case (opcode7)
            `OPC_STORE: begin
                case (funct3)
                `FNC_SW: begin // handle store word
                    dmem_wea = (addr[28] == 1) ? 4'b1111 : 4'b0000;
                    imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b1111 : 4'b0000;
                    dout = din_raw;
                end
                `FNC_SH: begin // handle store half
                    case (addr[1:0])
                    2'b00: begin
                        dmem_wea = (addr[28] == 1) ? 4'b0011 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b0011 : 4'b0000;
                        dout = {{16{1'b0}}, din_raw[15:0]};
                    end
                    2'b01: begin
                        dmem_wea = (addr[28] == 1) ? 4'b0011 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b0011 : 4'b0000;
                        dout = {{16{1'b0}}, din_raw[15:0]};
                    end
                    2'b10: begin
                        dmem_wea = (addr[28] == 1) ? 4'b1100 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b1100 : 4'b0000;
                        dout = {din_raw[15:0], {16{1'b0}}};
                    end
                    2'b11: begin
                        dmem_wea = (addr[28] == 1) ? 4'b1100 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b1100 : 4'b0000;
                        dout = {din_raw[15:0], {16{1'b0}}};
                    end
                    default: begin
                        dmem_wea = 4'b0000;
                        imem_wea = 4'b0000;
                        dout = 32'b0;
                    end
                    endcase
                end
                `FNC_SB: begin // handle store byte
                    case (addr[1:0])
                    2'b00: begin
                        dmem_wea = (addr[28] == 1) ? 4'b0001 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b0001 : 4'b0000;
                        dout = {{24{1'b0}}, din_raw[7:0]};
                    end
                    2'b01: begin
                        dmem_wea = (addr[28] == 1) ? 4'b0010 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b0010 : 4'b0000;
                        dout = {{16{1'b0}}, din_raw[7:0], {8{1'b0}}};
                    end
                    2'b10: begin
                        dmem_wea = (addr[28] == 1) ? 4'b0100 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b0100 : 4'b0000;
                        dout = {{8{1'b0}}, din_raw[7:0], {16{1'b0}}};
                    end
                    2'b11: begin
                        dmem_wea = (addr[28] == 1) ? 4'b1000 : 4'b0000;
                        imem_wea = (addr[29] == 1 && PC[30] == 1) ? 4'b1000 : 4'b0000;
                        dout = {din_raw[7:0], {24{1'b0}}};
                    end
                    default: begin
                        dmem_wea = 4'b0000;
                        imem_wea = 4'b0000;
                        dout = 32'b0; 
                    end
                    endcase
                end
                default: begin
                    dmem_wea = 4'b0000;
                    imem_wea = 4'b0000;
                    dout = 32'b0;
                end
                endcase
            end
            default: begin
                dmem_wea = 4'b0000;
                imem_wea = 4'b0000;
                dout = 32'b0;
            end
            endcase
        end else begin
            dmem_wea = 4'b0000;
            imem_wea = 4'b0000;
            dout = 32'b0;
        end
    end
endmodule
