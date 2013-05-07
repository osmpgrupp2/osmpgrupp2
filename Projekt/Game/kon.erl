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

%% meddelanden ska skickas på detta format: {move/add/delete, ship/meteor/shot, left/right eller pid eller { pid,pos}}

% {pid,pos} används när vi ska skapa ett objekt.


res(Checker, ShotCreator) ->
    io:format("tjena2~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),

    receive
	{left} ->
	    io:format("left~n",[]),
	    Checker ! {ship,{x,y},left}, %% {x,y} ska vara den faktiska positionen för skeppet
	    
	    res(Checker, ShotCreator);
	{right} ->
	    io:format("right~n",[]),
	    Checker ! {ship,{x,y},right}, %% {x,y} ska vara den faktiska positionen för skeppet
	    
	    res(Checker, ShotCreator);
	{space} ->
	    io:format("space~n",[]),
	    ShotCreator ! {new},
		res(Checker, ShotCreator)		
    end.


start() ->
    io:format("tjena1~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    {boxarn,hoppsansa@ubuntu} ! {self(),1000,1000},
    CheckerStart = spawn_link(kon,checkerStart,[10]),
    _Counter = spawn_link(kon,counter,[]),
    ShotCreator = spawn_link(kon,shotCreator,[]),
    _MeteorCreator = spawn_link(kon,meteorCreator,[CheckerStart]),
    res(CheckerStart, ShotCreator).


checkerStart(N) ->
    Matrix = grid:matrix(N),
    checker(Matrix).
    


checker(Matrix) ->
    receive
	{ship,{X,Y},left} ->
	    {Bool, Type} = grid:check_elem(X-1,Y,Matrix),
	    if Bool ->
		    NewMatrix = grid:move_elem_l(3,X,Y,Matrix),
		    {boxarn,hoppsansa@ubuntu} ! {move,ship,left},
		    checker(NewMatrix);
	       true ->
		    case Type of
			1 ->
			    skott;
			2 ->
			    meteor
		    end
	    end;

	{ship,{X,Y},right} ->
	    grid:check(X+1,Y,Matrix),
	    NewMatrix = grid:move_elem_r(3,X,Y,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,ship,right},
	    checker(NewMatrix);

	{meteor,{X,Y},MPID} ->
	    grid:check(X,Y+1,Matrix),
	    NewMatrix = grid:move_elem_down(2,X,Y,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,meteor,MPID},
	    checker(NewMatrix);

	{shot,{X,Y},SPID} ->
	    grid:check(X,Y-1,Matrix),
	    NewMatrix = grid:move_elem_up(1,X,Y,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,shot,SPID},
	    checker(NewMatrix);
	
	{meteor,{X,Y},MPID,1} ->
	    grid:check(X,Y+1,Matrix),
	    NewMatrix = grid:change_elem(2,X,Y,Matrix),
	    add_to_list,
      	    {boxarn,hoppsansa@ubuntu} ! {add,meteor,{MPID,X}},
	    checker(NewMatrix);
	
	{shot,{X,Y},SPID,1} ->
	    grid:check(X,Y-1,Matrix),
	    NewMatrix = grid:change_elem(1, X, Y, Matrix),
	    add_to_list,
	    {boxarn,hoppsansa@ubuntu} ! {add,shot,{SPID,X}},
	    checker(NewMatrix);

	{counter} ->
	    iterera_over_listan,
	    checker(Matrix)
	end.


meteorCreator(CheckerStart,X) ->
    timer:sleep(4000),    
    X = X rem 10, 
    MeteorPID = spawn_link(kon,spawnMeteor,[]),
    CheckerStart ! {meteor,{X,0},MeteorPID,1},
    meteorCreator(CheckerStart,X+1).

shotCreator(CheckerStart,X) ->

    receive
	{new} ->
    ShotPID = spawn_link(kon,spawnshot,[]),
    CheckerStart ! {shot,{X,10},ShotPID,1}
end.

counter(Checker) ->
    timer:sleep(3000),
    Checker ! {counter},
    counter(Checker).

spawnshot() ->
    receive
	_ -> ok
	end.

spawnMeteor() ->
    receive
	_ -> ok
	end.
    

rand() ->
    Rand = random:seed(2,5,8),
    {X,_Y,_Z} = Rand,
    io:format("~p~n",[X]).

