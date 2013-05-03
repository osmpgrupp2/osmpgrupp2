%% @author david
%% @doc @todo Add description to receive.


-module(kon).

%% ====================================================================
%% API functions
%% ====================================================================
-export([rec/0]).



%% ====================================================================
%% Internal functions
%% ====================================================================



rec() ->
    io:format("tjeenna~n"),
    Text = net_adm:ping(hoppsansa@ubuntu),
    io:format("~p~n",[Text]),
    Nod = erlang:nodes(this),
    io:format("~p~n",[Nod]),
    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
    receive
	{1} ->
	    io:format("hej~n",[]),
	    {boxarn,hoppsansa@ubuntu} ! {self(), 10},
	    rec();
	Unexpected ->
	    io:format("va i helvete~p",[Unexpected])
	    
	    
    end.
	
