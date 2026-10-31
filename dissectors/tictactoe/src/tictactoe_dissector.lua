-- SPDX-License-Identifier: GPL-3.0-only
-- Importé de https://github.com/emmonks/TicTacToe_dissector (tictactoe_dissector.lua),
-- commit ad48368be5cc303962eb046d75ab3c2aa022038c du 12/02/2022.
-- Licence amont : GPLv3 (LICENSE, sans clause « or later ») — voir README.md.

-- Dissector simples para o jogo TicTacToe
-- Feito por Eduardo Maronas Monks em 2021

-- Cabecalho padrao com o nome do protocolo
-- E campos do protocolo
tictactoe_protocol = Proto("tictactoe",  "TicTacToe Protocol")

position = ProtoField.int8("tictactoe.position", "position", base.DEC)

tictactoe_protocol.fields = { position }

function tictactoe_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  -- Para descobrir qual porta do servidor
  -- Aplicacao tem um bug que tenta fazer duas conexoes TCP
  -- No 7o frame descobre a porta do servidor (Porta origem) e do cliente (Porta destino)
  if (pinfo.number == 7) then 
      server_port = pinfo.src_port
	  client_port = pinfo.dst_port
  
  end
  if length == 0 then return end
  

  pinfo.cols.protocol = tictactoe_protocol.name
-- Adiciona uma arvore para ser mostrada no painel de pacotes 
  local subtree = tree:add(tictactoe_protocol, buffer(), "TicTacToe Protocol Data")

  subtree:add(position, buffer(0,1))
-- A funcao buffer pega na posicao 0, o primeiro byte da carga util do pacote
  local position = buffer(0,1):uint()
 
 -- Chama a funcao get_position_name para realizar a traducao do valor do byte para um codigo do protocolo
 -- No caso do jogo-da-velha seria a posicao jogada no tabuleiro
 
  local position_name = get_position_name(position,pinfo.src_port)
  -- Monta no painel de pacotes os valores dos campos
  board_name = position_name
  subtree:add("Board  :", board_name)
  
  subtree:add("IP  :", tostring(pinfo.src))
  subtree:add("Port:", pinfo.src_port)
  subtree:add("Frame:", pinfo.number) 
  subtree:add("Server Port  :", tostring(server_port))
  
 -- Testa a porta de origem para identificar qual o jogador
 -- O Player1 sera quem ficou como servidor no jogo
 -- Em caso de mudanca na porta do servidor devera ser alterado 
  if (pinfo.src_port == 2000) then
    subtree:add("Player: Player1")
  else
    subtree:add("Player: Player2")
  end
   
end
-- Esta funcao para a relacao do valor do primeiro byte e 
-- traduz para a posicao do tabuleiro
-- O codigo 00 e o encerramento do jogo (bugado)

function get_position_name(position,port)
  local position_name = "Unknown"
 
    if position ==    01 then 
	   position_name = "Line1_Column1"
  elseif position ==    02 then 
       position_name = "Line1_Column2"
  elseif position ==    03 then 
       position_name = "Line1_Column3"
  elseif position ==    04 then 
       position_name = "Line2_Column1"
  elseif position ==    05 then 
       position_name = "Line2_Column2"
  elseif position ==    06 then 
       position_name = "Line2_Column3"
  elseif position ==    07 then 
       position_name = "Line3_Column1"
  elseif position ==    08 then 
       position_name = "Line3_Column2"
  elseif position ==    09 then 
       position_name = "Line3_Column3"
  elseif position ==    00 then position_name = "End_Game" 
end


  return position_name
end

-- Define o protocolo TCP e a porta usada no dissector
-- Em caso de mudanca da porta do servidor deverá ser alterado
local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(2000, tictactoe_protocol)
