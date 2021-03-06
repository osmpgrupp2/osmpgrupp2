%% @author david
%% @doc @todo Add description to receive.
%% erl -sname e_node -setcookie hojjsa


-module(kon).

-import(random).
-import(timer).
-import(grid.erl).


%% ====================================================================
%% API functions
%% ====================================================================

%%-export([start/0,res/0,rand/0]).
-compile(export_all).


%% ====================================================================
%% Internal functions
%% ====================================================================

%% meddelanden ska skickas på detta format: {move/add/delete, ship/meteor/shot, left/right eller pid eller {pid,pos}}

% {pid,pos} används när vi ska skapa ett objekt.


res(Checker, ShotCreator) ->
    io:format("tjena2~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    
    receive
	{left,X,Y} ->
	    io:format("left~n",[]),
	    Checker ! {ship,{X,Y},left},     
	    res(Checker, ShotCreator);

	{right,X,Y} ->
	    io:format("right~n",[]),
	    Checker ! {ship,{X,Y},right},	    
	    res(Checker, ShotCreator);

	{space,X,_Y} ->
	    io:format("space ~p ~n",[X]),
	    
	    ShotCreator ! {new,{X}},
		res(Checker, ShotCreator)		
    end.


start() ->
    io:format("tjena1~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    L = [],
    {boxarn,hoppsansa@ubuntu} ! {self(),1100,650},
    GameOver = spawn_link(kon,gameOver,[L]),
    CheckerStart = spawn_link(kon,checkerStart,[51,GameOver]),%10
    Counter = spawn_link(kon,counter,[CheckerStart]),
    CounterShot = spawn_link(kon,counterShot,[CheckerStart]),
    ShotCreator = spawn_link(kon,shotCreator,[CheckerStart]), 
    MeteorCreator = spawn_link(kon,meteorCreator,[CheckerStart,0]), %Detta ska vara en hårdkodad siffra!
    GameOver ! {Counter,ShotCreator,MeteorCreator},
    res(CheckerStart, ShotCreator).


checkerStart(N,GameOver) ->
    Matrix = grid:matrix(N),
    L = [],
    NewMatrix = grid:change_elem(3,51,26,Matrix), %3,10,5
    checker(NewMatrix,L,GameOver).
    
    


checker(Matrix,L,GameOver) ->
    receive
	{ship,{X,_Y},left} ->
	    io:format("Flytta skepp vänster ~n"),
	    {Bool, Type} = grid:check_elem(51,X,Matrix),
	    if Bool == true ->
		    NewMatrix = grid:move_elem_l(3,51,X+1,Matrix),
		    {boxarn,hoppsansa@ubuntu} ! {move,ship,left},
		    checker(NewMatrix,L,GameOver);
	       true ->
		    case Type of
			1 ->
			    io:format("krock med ett skott");
			2 ->
			    io:format("krock med ett meteor~n"),
			    {boxarn,hoppsansa@ubuntu} ! {gameover},
			    GameOver ! {self(),L},
			    exit(self(),normal);
			    %checker(Matrix,L,GameOver);
			3 -> 
			    io:format("krock med ett skepp~n");
			boundry ->
			    io:format("Utanför griden, vänster!"),
			    checker(Matrix,L,GameOver)

		    end
	    end;

	{ship,{X,_Y},right} ->
	    io:format("Flytta skepp höger"),
	    {Bool, Type} = grid:check_elem(51,X,Matrix),
	    if Bool == true ->
		    NewMatrix = grid:move_elem_r(3,51,X-1,Matrix),
		    {boxarn,hoppsansa@ubuntu} ! {move,ship,right},
		    checker(NewMatrix,L,GameOver);
	       true ->
		    case Type of
			1 ->
			    io:format("krock med ett skott");
			2 ->
			    io:format("krock med ett meteor~n"), 
			    {boxarn,hoppsansa@ubuntu} ! {gameover},
			    GameOver ! {self(),L},
			    exit(self(),normal);
			    %checker(Matrix,L,GameOver);
			3 -> 
			    io:format("krock med ett skepp~n");
			boundry ->
			    io:format("Utanför griden,höger!"),
			    checker(Matrix,L,GameOver)
			    
		    end
	    end;

	{meteor,{X,Y},MPID} ->
	    io:format("Flytta Meteor~n"),
	    {Bool, Type} = grid:check_elem((Y+1),X,Matrix),
	    if Bool == true ->
		    P = (lists:keymember(MPID,2,L)),
		    if  P == true ->
			    NewMatrix = grid:move_elem_down(2,Y,X,Matrix),
			    U = lists:keyreplace(MPID,2,L,{2,MPID,{X,(Y+1)}}),
			    io:format("~p",[U]),
			    {boxarn,hoppsansa@ubuntu} ! {move,meteor,MPID},
			    checker(NewMatrix,U,GameOver);	  
				true ->
					  checker(Matrix,L,GameOver)
			    
		       end;
	       true ->
		    case Type of 
			1 ->
			    io:format("Gammal meteor, krock med ett skott"),
			    {_T, SPID,{NewX,NewY}} = lists:keyfind({X,Y+1},3,L),
			       exit(MPID,normal),
			       exit(SPID,normal),

			    NMatrix = grid:change_elem(0,Y,X,Matrix),     %Tar bort meteoren ur matrixen
			    NewMatrix = grid:change_elem(0,NewY,NewX,NMatrix),   %Tar bort skottet ur matrixen
			    O = lists:keydelete(MPID,2,L),                %Tar bort meteoren ur listan
 			    
			    U = lists:keydelete(SPID,2,O),                %Tar bort skottet ur listan
			    
			    {boxarn,hoppsansa@ubuntu} ! {remove,meteor,MPID},
			    {boxarn,hoppsansa@ubuntu} ! {remove,shot,SPID},
			    {boxarn,hoppsansa@ubuntu} ! {score,hej,10},
			    
			    checker(NewMatrix,U,GameOver);
			    
			2 ->
			    io:format("Gammal meteor, krock med en meteor~n"),
			    checker(Matrix,L,GameOver);
			3 -> 
			    io:format("Gammal meteor, krock med ett skepp~n"),
			    {boxarn,hoppsansa@ubuntu} ! {gameover},
			    GameOver ! {self(),L},
			    exit(self(),normal);
			    %checker(Matrix,L,GameOver);
			boundry ->
			    U = lists:keydelete(MPID,2,L),
			    NewMatrix = grid:change_elem(0,Y,X,Matrix),
			    {boxarn,hoppsansa@ubuntu} ! {remove,meteor,MPID},
			    
			    exit(MPID,normal),
			    checker(NewMatrix,U,GameOver)
			    
		       end
	    end;
	    
	{shot,{X,Y},SPID} ->
	    io:format("Flytta skott~n"),
	    {Bool, Type} = grid:check_elem(Y-1,X,Matrix),
	    if Bool == true ->
		    P = (lists:keymember(SPID,2,L)),
		    if  P == true ->
			    NewMatrix = grid:move_elem_up(1,Y,X,Matrix),
			    U = lists:keyreplace(SPID,2,L,{1,SPID,{X,(Y-1)}}),
			    io:format("~p",[U]),
			    {boxarn,hoppsansa@ubuntu} ! {move,shot,SPID},
			    checker(NewMatrix,U,GameOver);
			true ->
			    checker(Matrix,L,GameOver)
			end;
	       true -> case Type of
			   1 ->
			       io:format("Gamalt skott,krock med ett skott"),
			       			    
			    checker(Matrix,L,GameOver);

			   2 ->
			       io:format("Gamalt skott,krock med en meteor~n"), 
			       {_T, MPID,{NewX,NewY}} = lists:keyfind({X,Y-1},3,L),
			       exit(MPID,normal),
			       exit(SPID,normal),

			       NMatrix = grid:change_elem(0,Y,X,Matrix),     %Tar bort skottet ur matrixen
			       
			       NewMatrix = grid:change_elem(0,NewY,NewX,NMatrix),   %Tar bort meteoren ur matrixen
			       O = lists:keydelete(MPID,2,L),                %Tar bort meteoren ur listan
			       
			       U = lists:keydelete(SPID,2,O),                %Tar bort skottet ur listan
			       
			       {boxarn,hoppsansa@ubuntu} ! {remove,meteor,MPID},  % meddelar java
			       {boxarn,hoppsansa@ubuntu} ! {remove,shot,SPID},
			       {boxarn,hoppsansa@ubuntu} ! {score,hej,10},
			       
			       
			       checker(NewMatrix, U,GameOver);
			   3 -> 
			       io:format("Gamalt skott,krock med ett skepp~n");

			   boundry ->
			       U = lists:keydelete(SPID,2,L),
			       NewMatrix = grid:change_elem(0,Y,X,Matrix),
			       {boxarn,hoppsansa@ubuntu} ! {remove,shot,SPID},
			       exit(SPID,normal),
			       checker(NewMatrix,U,GameOver)

			      
			  end
	    end;
	
	{meteor,{X,Y},MPID,1} ->
	    io:format("Ny meteor"),
	    {Bool,Type} = grid:check_elem (1,X,Matrix),
	    if Bool == true ->
		    NewMatrix = grid:change_elem(2,1,X,Matrix),
		    U = lists:append(L,[{2,MPID,{X,Y}}]),
		    Pos = X * 20, %*100
		    {boxarn,hoppsansa@ubuntu} ! {add,meteor,{MPID,Pos}},
		    checker(NewMatrix,U,GameOver);
	       true -> case Type of
			   1 ->
			       io:format("Ny meteor, krock med ett skott"),
			       {_T, SPID,{X,Y}} = lists:keyfind({X,1},3,L),
			       U = lists:keydelete(SPID,2,L),
			       NewMatrix = grid:change_elem(0,Y,X,Matrix),
			       {boxarn,hoppsansa@ubuntu} ! {remove,shot,SPID},
			       {boxarn,hoppsansa@ubuntu} ! {score,hej,10},
			       exit(MPID,normal),
			       exit(SPID,normal),
			       checker(NewMatrix,U,GameOver);
			   2 ->
			       io:format("Ny meteor, krock med en meteor~n"),
			       exit(MPID,normal),
			       checker(Matrix,L,GameOver);
			   3 -> 
			       io:format("Ny meteor, krock med ett skepp~n")
		       end
	    end;
	
	{shot,{X,Y},SPID,1} ->
	    io:format("Nytt skott, Checker processen: ~p SPID : ~p  ",[self(), SPID]),
	    {Bool,Type} = grid:check_elem(50,X,Matrix),
	    if Bool == true ->
		    NewMatrix = grid:change_elem(1,50,X,Matrix), %9
		    U = lists:append(L,[{1,SPID,{X,Y}}]),
		    Pos = X * 20, % 100
		    {boxarn,hoppsansa@ubuntu} ! {add,shot,{SPID,Pos}},
		    checker(NewMatrix,U,GameOver);
	       true -> case Type of
			   1 ->
			       io:format("Nytt skott, krock med ett skott"),
			       exit(SPID,normal),
			       checker(Matrix,L,GameOver);
			   2 ->
			       io:format("Nytt skott, krock med en meteor~n"),
			       {_T, MPID,{X,Y}} = lists:keyfind({X,50},3,L), %9
			       NewMatrix = grid:change_elem(0,Y,X,Matrix),   %Tar bort meteoren ur matrixen
			       U = lists:keydelete(MPID,2,L),                %Tar bort meteoren ur listan
			      
			       
			       {boxarn,hoppsansa@ubuntu} ! {remove,meteor,MPID},  % meddelar java
			       {boxarn,hoppsansa@ubuntu} ! {score,hej,10},
			    
			       exit(MPID,normal),
			       exit(SPID,normal),               %avslutar processerna.
			       checker(NewMatrix, U,GameOver); 
			   3 -> 
			       io:format("Nytt skott, krock med ett skepp~n")
		       end
	    end;

	{counter,meteor} ->
	    % iterera_over_listan,L och skicka meddelande till processerna som ska förflyttas.
	    
	    A = lists:filter(fun(X) ->
				     element(1,X) =:= 2
			     end,
			     L),
	    
	    lists:keymap(fun(N) ->
				 N ! {move , lists:keyfind(N,2,A) 
				     } end,2,A),
	    checker(Matrix,L,GameOver);
	{counter,shot} ->
	    A = lists:filter(fun(X) ->
				     element(1,X) =:= 1
			     end,
			     L),
	    
	    lists:keymap(fun(N) ->
				 N ! {move , lists:keyfind(N,2,A) 
			 } end,2,A),
	    checker(Matrix,L,GameOver)
    end.


meteorCreator(CheckerStart,X) ->
    timer:sleep(800),    
    O = random:uniform(51),   %10 
    MeteorPID = spawn_link(kon,spawnMeteor,[CheckerStart]),
    CheckerStart ! {meteor,{O,1},MeteorPID,1},
    meteorCreator(CheckerStart,O).

shotCreator(CheckerStart) ->

    receive
	{new,{Pos}} ->
	    io:format("receive shotcreator ~p~n", [Pos]),
	    ShotPID = spawn_link(kon,spawnShot,[CheckerStart]),
	    CheckerStart ! {shot,{Pos,50},ShotPID,1}, %9
	    shotCreator(CheckerStart)
    end.

counter(Checker) ->
    timer:sleep(200),
    Checker ! {counter,meteor},
    counter(Checker).

counterShot(Checker) ->
    timer:sleep(40),
    Checker ! {counter,shot},
    counterShot(Checker).

spawnShot(Checker) ->
    receive
	{move,{_S,Pid,{X,Y}}} ->
	    Checker ! {shot,{X,Y},Pid}, %% SKA VARA X;Y!!!!
	    spawnShot(Checker)
	end.


spawnMeteor(Checker) ->
    receive
	{move,{_S,Pid,{X,Y}}} ->
	    Checker ! {meteor,{X,Y},Pid},  %% SKA VARA X;Y!!!!
	    spawnMeteor(Checker)
		
	end.
    
gameOver(Listan) ->
    receive 
	{X,Y,Z} ->
	    A = lists:append([X],[Y]),
	    B = lists:append(A,[Z]),
	    gameOver(B);
	
	{X,Objectlist} ->         % X = checker pid.
	    
	    io:format("GameOver ~n"),
	    
	    lists:map(fun(N) ->  exit(N,normal) end,Listan),
	    lists:keymap(fun(N) ->  exit(N,normal) end,2,Objectlist),
	    io:format("Listan:~p ~n",[Listan]),
	    io:format("ObjectListanListan:~p ~n",[Objectlist]),
	    {P,A,{C,M}} = lists:keyfind(2,1,Objectlist),
	    exit(A,normal),
	    I = erlang:process_info(A),
	    io:format("Process_info:~p ~n",[I]),
	    exit(X,normal),
	    halt(),
	    exit(self(),normal)
	    
    end.

