%% @author david
%% @doc @todo Add description to receive.
%% erl -sname e_node -setcookie hojjsa


-module(kon).

-import(random).
-import(timer).
-import(testing.erl).


%% ====================================================================
%% API functions
%% ====================================================================
-export([rec/0,res/0,rand/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================

%% meddelanden ska skickas på detta format: {move/add/delete, ship/meteor/shot, left/right eller pid}


res() ->
    io:format("tjena2~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),

    receive
	{left} ->
	    io:format("left~n",[]),
	    {boxarn,hoppsansa@ubuntu} ! {move,ship,left},
	    res();
	{right} ->
	    io:format("right~n",[]),





	    {boxarn,hoppsansa@ubuntu} ! {move,ship,right},
	    res();
	{space} ->
	    io:format("space~n",[])

		
    end.


rec() ->
    io:format("tjena1~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    {boxarn,hoppsansa@ubuntu} ! {self()},
    res().

rand() ->
    testing:test(),
    Rand = random:seed(2,5,8),
    {X,Y,Z} = Rand,
    io:format("~p~n",[X]).

