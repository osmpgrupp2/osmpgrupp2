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
-export([start/0,res/0,rand/0]).



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
	    Checker ! {ship,{X,Y},left},
	    
	    res();
	{right} ->
	    io:format("right~n",[]),
	    Checker ! {ship,{X,Y},right},
	    
	    res();
	{space} ->
	    io:format("space~n",[]),
	    ShotCreator ! {new},
		res()
	

		
    end.


start() ->
    io:format("tjena1~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    {boxarn,hoppsansa@ubuntu} ! {self(),1000,1000},
    CheckerStart = spawn_link(kon,checkerStart,[10]),
    Counter = spawn_link(kon,counter,[]),
    ShotCreator = spawn_link(kon,shotCreator,[]),
    MeteorCreator = spawn_link(kon,meteorCreator,[CheckerStart]),
    res(Checker, ShotCreator).


checkerStart(N) ->
    Matrix = grid:matrix(N),
    checker(Matrix).
    


checker(Matrix)
    receive
	{ship,{X,Y},left} ->
	    grid:check_elem(X-1,Y,Matrix),
	    NewMatrix = grid:move_elem_l(3,X,Y,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,ship,left},
	    checker(NewMatrix);

	{ship,{X,Y},right} ->
	    grid:check(X+1,Y,Matrix),
	    grid:move(X+1,Y,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,ship,right};
	{meteor,{X,Y},MPID} ->
	    grid:check(X,Y+1,Matrix),
	    grid:move(X,Y+1,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,meteor,PID};
	{shot,{X,Y},SPID} ->
	    grid:check(X,Y-1,Matrix),
	    grid:move(X,Y-1,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {move,shot,PID};
	
	{meteor,{X,Y},MPID,1} ->
	    grid:check(X,Y+1,Matrix),
	    grid:add(,,),
	    add to list,

%grid:move(X,Y+1,Matrix),
	    
	    {boxarn,hoppsansa@ubuntu} ! {add,meteor,{PID,X}};
	
	{shot,{X,Y},SPID,1} ->
	    grid:check(X,Y-1,Matrix),
	    grid:move(X,Y-1,Matrix),
	    {boxarn,hoppsansa@ubuntu} ! {add,shot,{PID,X}};
	{counter} ->
	    iterera över listan.


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

	end.

spawnMeteor() ->
    receive

	end.
    

rand() ->
    Rand = random:seed(2,5,8),
    {X,Y,Z} = Rand,
    io:format("~p~n",[X]).

