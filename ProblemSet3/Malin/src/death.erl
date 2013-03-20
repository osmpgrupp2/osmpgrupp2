%% @author Karl Marklund <karl.marklund@it.uu.se>
-module(death).
-export([start/1, gamble/1]).

%% To use EUnit we must include this:
-include_lib("eunit/include/eunit.hrl").

%% @doc Starts a new death service such that the probability of dying is defined by DieRate `(0 <= DieRate <= 100)'.

-opaque death()::pid().
-spec start(DieRate) -> death() when DieRate::integer().

start(DieRate) when DieRate >= 0, DieRate =< 100 -> 
    spawn(fun() -> init(DieRate) end).
init(DieRate) ->
    random:seed(erlang:now()),
    loop(DieRate).

loop(DieRate) when DieRate >= 0, DieRate =< 100 ->
    receive 
	{hello, PID} ->
	    R = random:uniform(100),
	    if R >= DieRate ->
		    PID ! live;
	       true -> 
		    PID ! die
	    end
    end,
    loop(DieRate).

%% @doc Gamle with Death. If you're unlucky you will die (terminate). 
-spec gamble(Death) -> ok | no_return() when Death::death().

gamble(Death) ->
    Death ! {hello, self()},
    receive 
	live -> ok;
	die  -> exit(random_death)
    end.
	    
fake_gamble(Death) ->
    Death ! {hello, self()},
    receive 
	live -> live;
	die  -> die
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         EUnit Test Cases                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EUnit adds the fifo:test() function to this module. 

%% All functions with names ending wiht _test() or _test_() will be
%% called automatically by death:test()

start_test() ->
    ?assertMatch(true, is_pid(start(10))).

gamble_die_test() ->
    D = start(100),
    ?assertException(exit, random_death, gamble(D)).

gamble_live_test() ->
    D = start(0),
    R = [gamble(D) || _ <- lists:seq(1, 100)],
    E = [ok || _ <- lists:seq(1, 100)],
    ?assertMatch(E, R).


fake_gamble_test_() ->
    Rates  = [10, 20, 30, 40, 50, 60],

    Test = fun(Rate) ->
		   D = start(50),
		   N = 1000,
		   R = [fake_gamble(D) || _ <- lists:seq(1, N)],
		   {Dies, Lives} = lists:partition(fun(X) -> X == die end, R),
		   ND = length(Dies),
		   NL = length(Lives),
		   ?assertEqual(N, ND + NL),
		   P = ND/N,
		   io:format("~w, ~w~n", [P, (Rate-2)/100]),
		   ?_assertEqual(true, (P > (Rate-1)/100) orelse (P < (Rate+1)/100) ) end,
    [Test(Rate) || Rate <- Rates].
    
    
				    
    

    
