-module(test).
-import(timer).
-export([start/1]).




start(X) ->
    O = (X rem 10) +1,
    io:format("~p",[O]),
    timer:sleep(1000),
	start(O).
