%% @doc Erlang mini project.
-module(add).
-export([start/3, start/4]).

%% @doc TODO: add documentation
-spec start(A,B,Base) -> ok when 
      A::integer(),
      B::integer(), 
      Base::integer().

start(A,B, Base) ->
    A1 = A,
    B1 = B,
    ChildArray = array:new(length(A1)),
    ChildArray = mainSpawner(A1,B1,ChildArray,Base),
    ResultArray = array:ner(length(A1)),
    ResultArray = mainRecieverLoopiloop(ChildArray, ResultArray, length(A1)).
%%printa ut saker

%% @doc TODO: add documentation
-spec start(A,B,Base, Options) -> ok when 
      A::integer(),
      B::integer(), 
      Base::integer(),
      Option::atom() | tuple(),
      Options::[Option].

start(A,B,Base, Options) ->
    tbi.


mainRecieverLoopiloop(_ChildArray, ResultArray, 0) ->
    ResultArray;
mainRecieverLoopiloop(ChildArray, ResultArray, Counter) ->
    receive
	{ChildPID, Result} ->
	    exit(ChildPID, kill),
	    mainRecieverLoopiloop(ChildArray, array:set(findArrayIndex(ChildPID, ChildArray,0), Result, ResultArray), Counter - 1)
    end. 


%% hittar index för element N
findArrayIndex(Item, Array, Index) ->
    case(array:get(Index, Array) =:= Item) of
	true ->
	    Index;
	false ->
	    findArrayIndex(Item, Array, Index + 1)
    end.

    


%% @doc returnerar en array med piden till de spawnade barnen i rätt ordning
mainSpawnerHelp([], _,_ , ChildArray, _, _) ->
    ChildArray;
mainSpawnerHelp([A | Atl],[B | Btl], 0, ChildArray, Base, ParentPID) ->
    mainSpawnerHelp(Atl, Btl, 1, array:set(0, spawn(add, spawnChild, [A,B, ParentPID, ParentPID]), ChildArray), Base, ParentPID);
mainSpawnerHelp([A | Atl],[B | Btl],Index, ChildArray, Base, ParentPID) ->
    mainSpawnerHelp(Atl, Btl,Index + 1, array:set(Index, spawn(add, spawnChild, [A,B, ParentPID, array:get(Index - 1, ChildArray) ]), ChildArray), Base,ParentPID).

%% @doc returnerar en array med piden till de spawnade barnen i rätt ordning
mainSpawner(A,B,ChildArray,Base) ->
    mainSpawnerHelp(A,B,0,ChildArray, Base, self()).



%% Barn process
spawnChild(A,B, ParentPID, NextPID, Base) ->
    spawn(add, spawnBaby, [A, B, 0, Base]),
    spawn(add, spawnBaby, [A, B, 1, Base]),
    ResultArray = array:new(2),
    spawnChildReceiveLoop(ResultArray, ParentPID, NextPID).

%% Barn processen väntar på meddelanden
spawnChildReceiveLoop(ResultArray, ParentPID, NextPID) ->
    receive
	{0, Baby, Result} ->
	    ResultArray = array:set(0, Result, ResultArray),
	    exit(Baby, kill);
	{1, Baby, Result} ->
	    ResultArray = array:set(1, Result, ResultArray),
	    exit(Baby, kill);
	{carryIn, 0} -> %%omm vi får veta att carryIn är 0
	    case ((array:get(0, ResultArray)) =/= undefined) of
		true -> %% this line no works....
		    NextPID ! {carryIn, element(0, array:get(0, ResultArray))},
		    ParentPID ! {self(), array:get(0, ResultArray)};
		false -> 
		    spawnChildReceiveLoop(ResultArray, ParentPID, NextPID)
	    end;
	{carryIn, 1} -> %% o vi får veta att carry in är 1
	    case ((array:get(1, ResultArray)) =/= undefined) of
		true ->
		    NextPID ! {carryIn, element(1, array:get(1, ResultArray))},
		    ParentPID ! {self(), array:get(1, ResultArray)};
		false -> spawnChildReceiveLoop(ResultArray, ParentPID, NextPID)
	    end
    end.


%% Baby process
spawnBaby(A,B,CarryIn, Base) ->
    %%do some magic
    {CarryIn, self(), result}.%someAdder(A,B, CarryIn, Base)}.
