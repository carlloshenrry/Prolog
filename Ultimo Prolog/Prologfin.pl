% --- Base de dados ---

% S�o Paulo
v�o(s�o_paulo, m�xico, sp1, 8:25, (mesmo, 20:25), 0, gol, [dom, qua, sex]).
v�o(s�o_paulo, m�xico, sp2, 19:25, (mesmo, 23:25), 0, azul, [sex, sab]).
v�o(s�o_paulo, m�xico, sp3, 9:25, (mesmo, 19:00), 1, latam, [seg, ter, qui, sab]).
v�o(s�o_paulo, nova_york, sp4, 9:25, (mesmo, 19:00), 0, tam, [dom, qua, sex]).
v�o(s�o_paulo, lisboa, sp5, 10:25, (seguinte, 22:30), 1, latam, [seg, sex, sab]).
v�o(s�o_paulo, madrid, sp6, 00:13, (seguinte, 9:27), 0, gol, [dom, qua, sex]).
v�o(s�o_paulo, londres, sp7, 15:30, (mesmo, 23:00), 1, latam, [seg, qui, sex]).
v�o(s�o_paulo, paris, sp8, 1:25, (mesmo, 19:53), 0, gol, [dom, seg, ter, qua, sab]).

% M�xico
v�o(m�xico, nova_york, me1, 7:00, (mesmo, 20:00), 0, gol, [qui, sex, sab]).
v�o(m�xico, madrid, me2, 8:00, (mesmo, 22:58), 1, latam, [seg, qua, sex]).

% Nova York
v�o(nova_york, londres, ny1, 23:00, (seguinte, 10:00), 1, latam, [ter, qua, qui, sex]).

% Londres
v�o(londres, lisboa, lo1, 17:10, (seguinte, 12:00), 0, latam, [seg, ter, qui]).
v�o(londres, paris, lo2, 18:20, (seguinte, 12:00), 0, latam, [qua, qui, sab]).
v�o(londres, estocolmo, lo3, 19:30, (seguinte, 12:00), 1, latam, [dom, ter, qua, qui]).

% Madrid
v�o(madrid, paris, ma1, 13:22, (mesmo, 17:23), 0, latam, [qui, sex, sab]).
v�o(madrid, roma, ma2, 00:00, (mesmo, 10:00), 0, latam, [ter, qua, qui]).
v�o(madrid, frankfurt, ma3, 21:00, (seguinte, 1:00), 1, latam, [seg, ter, qua, qui]).

% Frankfurt
v�o(frankfurt, estocolmo, fr1, 16:45, (mesmo, 17:23), 0, latam, [qui, sex, sab]).
v�o(frankfurt, roma, fr2, 14:35, (mesmo, 17:23), 0, latam, [qui, sex, sab]).

% --------- PREDICADOS ---------

% - Auxiliares gerais -

pertence(X,[X|Cauda]).
pertence(X,[Cabe�a|Cauda]) :- pertence(X, Cauda).

min_para_hora(Min, H:M) :- divmod(Min, 60, H, M).
% divmod(Dividendo, divisor, quociente, resto).

% ----- EXIGIDAS ------

% 1. Verificar se existe v�o direto:
v�o_direto(Origem, Destino, Companhia, Dias, Hor�rio) :-
    v�o(Origem, Destino, _, Hor�rio, (_,_), Escalas, Companhia, Lista_Dias),
    pertence(Dias, Lista_Dias),
    Escalas =:= 0.

% 2. Filtrar v�o por dia:
filtra_voo_dia_semana(Origem, Destino, Dia_Semana, Hor�rio_Saida, Hor�rio_Chegada, Companhia) :-
    v�o(Origem, Destino, _, Hor�rio_Saida, (_, Hor�rio_Chegada), _, Companhia, Lista_Dias),
    pertence(Dia_Semana, Lista_Dias).

% 3. Roteiro de viagem:
roteiro(A, X, [Lista_V�os]) :-
    v�o(A, X, Lista_V�os,_,_,_,_,_), !. % Cut para impedir infinitas combina��es
    roteiro(A, X, [Cod|T]) :- v�o(A, B, Cod,_,_,_,_,_), roteiro(B, X, T).

% 4. Menor tempo de viagem:

% --- Auxilares ---
menor_Viagem([Cabe�a,Cauda],[Cabe�a_V,Cauda_V], Menor, Cod_Menor) :-
    Cabe�a < Cauda, Menor is Cabe�a, Cod_Menor = Cabe�a_V, !;
    Menor is Cauda, Cod_Menor = Cauda_V.
menor_Viagem([Cabe�a|Cauda],[Cabe�a_V|Cauda_V], Menor, Cod_Menor) :-
    menor_Viagem(Cauda, Cauda_V, Menor_2, Cod_Menor_2),
    (Cabe�a < Menor_2, Menor is Cabe�a, Cod_Menor = Cabe�a_V, !;
    Menor is Menor_2, Cod_Menor = Cod_Menor_2).

dura��o_V�o(Origem, Destino, Codigo, Dura��o) :-
    % Se
    v�o(Origem, Destino, Codigo, Hr_Saida:Min_Saida, (Dia_Chegada, Hr_Chegada:Min_Chegada),_,_,_),
    (Dia_Chegada = seguinte,
    Saida is Hr_Saida*60+Min_Saida,
    Chegada is (Hr_Chegada*60+Min_Chegada)+1440,
    Dura��o is Chegada - Saida);
    % Sen�o
    v�o(Origem, Destino,Codigo, Hr_Saida:Min_Saida, (Dia_Chegada, Hr_Chegada:Min_Chegada),_,_,_),
    (Dia_Chegada = mesmo,
    Saida is Hr_Saida*60+Min_Saida,
    Chegada is Hr_Chegada*60+Min_Chegada,
    Dura��o is Chegada - Saida).

% --- Principal ---
menorDuracao(Origem, Destino, Dia, Hor�rio_Saida, Hor�rio_Chegada, Companhia) :-
    findall(Tempo, dura��o_V�o(Origem, Destino, Codigo, Tempo), Dura��es),
    findall(V�o, v�o(Origem, Destino, V�o, _, (_,_),_,_,Dias), V�os),
    menor_Viagem(Dura��es, V�os, Menor, Cod_Menor),
    v�o(_,_, Cod_Menor, Hor�rio_Saida, (_, Hor�rio_Chegada), _, Companhia, Dias),
    pertence(Dia, Dias).

% ------------------------------------------------------------------

% 5 ()
roteiro(Origem, Destino, DiaSa�da, HorSaida, Dura��o):-
    roteiro(Origem,Destino,[X|Y]),
    calculatempo([X|Y],Dura),
    v�o(_,_,X,HorSaida,(_,_),_,_,DiaSa�da),
    min_para_hora(Dura,Dura��o).

% ------------------------------
calculatempo([],0).
calculatempo([Codigo|Lista],Tempo):-
    dura��o_V�o(_, _, Codigo, T1),
    calculatempo(Lista,T2),
    Tempo is T1 + T2.







