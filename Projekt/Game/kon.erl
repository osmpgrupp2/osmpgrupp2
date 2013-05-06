%% @author david
%% @doc @todo Add description to receive.
%% erl -sname e_node -setcookie hojjsa


-module(kon).

%% ====================================================================
%% API functions
%% ====================================================================
-export([rec/0,res/0,reccar/1]).



%% ====================================================================
%% Internal functions
%% ====================================================================


res() ->
    io:format("tjena2~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    receive
	{left} ->
	    io:format("left~n",[]),
	    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
	    res();
	{right} ->
	    io:format("right~n",[]),
	    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
	    res()
		
		
    end.


rec() ->
    io:format("tjena1~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
    receive
	{left} ->
	    io:format("left~n",[]),
	    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
	    res();
	{right} ->
	    io:format("right~n",[]),
	    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
	    res()


    end.

reccar(right) ->
    10;
reccar(left) ->
    -10.


