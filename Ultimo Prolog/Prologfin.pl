% --- Base de dados ---

% São Paulo
vôo(são_paulo, méxico, sp1, 8:25, (mesmo, 20:25), 0, gol, [dom, qua, sex]).
vôo(são_paulo, méxico, sp2, 19:25, (mesmo, 23:25), 0, azul, [sex, sab]).
vôo(são_paulo, méxico, sp3, 9:25, (mesmo, 19:00), 1, latam, [seg, ter, qui, sab]).
vôo(são_paulo, nova_york, sp4, 9:25, (mesmo, 19:00), 0, tam, [dom, qua, sex]).
vôo(são_paulo, lisboa, sp5, 10:25, (seguinte, 22:30), 1, latam, [seg, sex, sab]).
vôo(são_paulo, madrid, sp6, 00:13, (seguinte, 9:27), 0, gol, [dom, qua, sex]).
vôo(são_paulo, londres, sp7, 15:30, (mesmo, 23:00), 1, latam, [seg, qui, sex]).
vôo(são_paulo, paris, sp8, 1:25, (mesmo, 19:53), 0, gol, [dom, seg, ter, qua, sab]).

% México
vôo(méxico, nova_york, me1, 7:00, (mesmo, 20:00), 0, gol, [qui, sex, sab]).
vôo(méxico, madrid, me2, 8:00, (mesmo, 22:58), 1, latam, [seg, qua, sex]).

% Nova York
vôo(nova_york, londres, ny1, 23:00, (seguinte, 10:00), 1, latam, [ter, qua, qui, sex]).

% Londres
vôo(londres, lisboa, lo1, 17:10, (seguinte, 12:00), 0, latam, [seg, ter, qui]).
vôo(londres, paris, lo2, 18:20, (seguinte, 12:00), 0, latam, [qua, qui, sab]).
vôo(londres, estocolmo, lo3, 19:30, (seguinte, 12:00), 1, latam, [dom, ter, qua, qui]).

% Madrid
vôo(madrid, paris, ma1, 13:22, (mesmo, 17:23), 0, latam, [qui, sex, sab]).
vôo(madrid, roma, ma2, 00:00, (mesmo, 10:00), 0, latam, [ter, qua, qui]).
vôo(madrid, frankfurt, ma3, 21:00, (seguinte, 1:00), 1, latam, [seg, ter, qua, qui]).

% Frankfurt
vôo(frankfurt, estocolmo, fr1, 16:45, (mesmo, 17:23), 0, latam, [qui, sex, sab]).
vôo(frankfurt, roma, fr2, 14:35, (mesmo, 17:23), 0, latam, [qui, sex, sab]).

% --------- PREDICADOS ---------

% - Auxiliares gerais -

pertence(X,[X|Cauda]).
pertence(X,[Cabeça|Cauda]) :- pertence(X, Cauda).

min_para_hora(Min, H:M) :- divmod(Min, 60, H, M).
% divmod(Dividendo, divisor, quociente, resto).

% ----- EXIGIDAS ------

% 1. Verificar se existe vôo direto:
vôo_direto(Origem, Destino, Companhia, Dias, Horário) :-
    vôo(Origem, Destino, _, Horário, (_,_), Escalas, Companhia, Lista_Dias),
    pertence(Dias, Lista_Dias),
    Escalas =:= 0.

% 2. Filtrar vôo por dia:
filtra_voo_dia_semana(Origem, Destino, Dia_Semana, Horário_Saida, Horário_Chegada, Companhia) :-
    vôo(Origem, Destino, _, Horário_Saida, (_, Horário_Chegada), _, Companhia, Lista_Dias),
    pertence(Dia_Semana, Lista_Dias).

% 3. Roteiro de viagem:
roteiro(A, X, [Lista_Vôos]) :-
    vôo(A, X, Lista_Vôos,_,_,_,_,_), !. % Cut para impedir infinitas combinações
    roteiro(A, X, [Cod|T]) :- vôo(A, B, Cod,_,_,_,_,_), roteiro(B, X, T).

% 4. Menor tempo de viagem:

% --- Auxilares ---
menor_Viagem([Cabeça,Cauda],[Cabeça_V,Cauda_V], Menor, Cod_Menor) :-
    Cabeça < Cauda, Menor is Cabeça, Cod_Menor = Cabeça_V, !;
    Menor is Cauda, Cod_Menor = Cauda_V.
menor_Viagem([Cabeça|Cauda],[Cabeça_V|Cauda_V], Menor, Cod_Menor) :-
    menor_Viagem(Cauda, Cauda_V, Menor_2, Cod_Menor_2),
    (Cabeça < Menor_2, Menor is Cabeça, Cod_Menor = Cabeça_V, !;
    Menor is Menor_2, Cod_Menor = Cod_Menor_2).

duração_Vôo(Origem, Destino, Codigo, Duração) :-
    % Se
    vôo(Origem, Destino, Codigo, Hr_Saida:Min_Saida, (Dia_Chegada, Hr_Chegada:Min_Chegada),_,_,_),
    (Dia_Chegada = seguinte,
    Saida is Hr_Saida*60+Min_Saida,
    Chegada is (Hr_Chegada*60+Min_Chegada)+1440,
    Duração is Chegada - Saida);
    % Senão
    vôo(Origem, Destino,Codigo, Hr_Saida:Min_Saida, (Dia_Chegada, Hr_Chegada:Min_Chegada),_,_,_),
    (Dia_Chegada = mesmo,
    Saida is Hr_Saida*60+Min_Saida,
    Chegada is Hr_Chegada*60+Min_Chegada,
    Duração is Chegada - Saida).

% --- Principal ---
menorDuracao(Origem, Destino, Dia, Horário_Saida, Horário_Chegada, Companhia) :-
    findall(Tempo, duração_Vôo(Origem, Destino, Codigo, Tempo), Durações),
    findall(Vôo, vôo(Origem, Destino, Vôo, _, (_,_),_,_,Dias), Vôos),
    menor_Viagem(Durações, Vôos, Menor, Cod_Menor),
    vôo(_,_, Cod_Menor, Horário_Saida, (_, Horário_Chegada), _, Companhia, Dias),
    pertence(Dia, Dias).

% ------------------------------------------------------------------

% 5 ()
roteiro(Origem, Destino, DiaSaída, HorSaida, Duração):-
    roteiro(Origem,Destino,[X|Y]),
    calculatempo([X|Y],Dura),
    vôo(_,_,X,HorSaida,(_,_),_,_,DiaSaída),
    min_para_hora(Dura,Duração).

% ------------------------------
calculatempo([],0).
calculatempo([Codigo|Lista],Tempo):-
    duração_Vôo(_, _, Codigo, T1),
    calculatempo(Lista,T2),
    Tempo is T1 + T2.







