%% @doc Erlang mini project.
-module(add).
-export([start/3, start/4]).

%% @doc TODO: add documentation
-spec start(A,B,Base) -> ok when 
      A::integer(),
      B::integer(), 
      Base::integer().

start(A,B, Base) ->
    AL = utils:listigt(A,Base,[]),
    BL = utils:listigt(B,Base,[]),
    {AN,BN} = utils:nolligt(AL,BL,3),
    AS = utils:split(AN,3),
    BS = utils:split(BN,3),
    io:format("~p ~p ~n",[AS,BS]),

    ChildArray = array:new(length(AS)),
    io:format("hejhej2 ~n"),
    ChildArray = mainSpawner(AS,BS,ChildArray,Base),
    io:format("hejhej3 ~n"),
    ResultArray = array:new(length(AS)), 
    io:format("hejhej4 ~n"),
    ResultArray = mainRecieverLoopiloop(ChildArray, ResultArray, length(AS)), 
    
io:format("Print ~p ~n", [ResultArray]).
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


%% @doc Loop to receive results from all children and then kill them
%% ChildArray is a vector with the pID of all children in the right order
%% ResultArray is where the results from the children are stored
%% The results are stored in the same order as the children
%% Counter is the number of results that is left to receive
-spec mainRecieverLoopiloop(ChildArray, ResultArray, Counter) -> ResultArray2 when
      ChildArray::array(),
      ResultArray::array(),
      Counter::integer(),
      ResultArray2::array().

mainRecieverLoopiloop(_ChildArray, ResultArray, 0) ->
    ResultArray;
mainRecieverLoopiloop(ChildArray, ResultArray, Counter) ->
    receive
	{ChildPID, Result} ->
	    exit(ChildPID, kill),
	    mainRecieverLoopiloop(ChildArray, array:set(findArrayIndex(ChildPID, ChildArray,0), Result, ResultArray), Counter - 1)
    end. 




%% @doc Find the index of the element Item in the array Array
-spec findArrayIndex(Item, Array, Index) -> Index2 when
      Item::term(),
      Array::array(),
      Index::integer(),
      Index2::integer().

findArrayIndex(Item, Array, Index) ->
    case(array:get(Index, Array) =:= Item) of
	true ->
	    Index;
	false ->
	    findArrayIndex(Item, Array, Index + 1)
    end.




%% @doc helpfunction to mainSpawner
%% spawns children and returns an array with the pID
%% of the children in the right order
-spec mainSpawnerHelp(A, B, Index, ChildArray, Base, ParentPID) -> ChildArray2 when
      A::nil() |[[integer()]], 
      B::nil() | [[integer()]], 
      Index::integer(), 
      ChildArray::array(), 
      Base::integer(), 
      ParentPID::integer(),
      ChildArray2::array.

mainSpawnerHelp([], _,_ , ChildArray, _, _) ->
    ChildArray;
mainSpawnerHelp([A | Atl],[B | Btl], 0, ChildArray, Base, ParentPID) ->
    io:format("MainSpawnerHelp/2 ~n"),
    mainSpawnerHelp(Atl, Btl, 1, array:set(0, spawn_link(add, spawnChild, [A,B, ParentPID, ParentPID,Base]), ChildArray), Base, ParentPID);
mainSpawnerHelp([A | Atl],[B | Btl],Index, ChildArray, Base, ParentPID) ->
    io:format("MainSpawnerHelp/3 ~n"),
    mainSpawnerHelp(Atl, Btl,Index + 1, array:set(Index, spawn_link(add, spawnChild, [A,B, ParentPID, array:get(Index - 1, ChildArray),Base ]), ChildArray), Base,ParentPID).







%% @doc spawns children and returns an array with the pID
%% of the children in the right order
-spec mainSpawner(A, B, ChildArray, Base) -> ChildArray2 when
      A::nil() | [[integer()]], 
      B::nil() | [[integer()]],
      ChildArray::array(), 
      Base::integer(),
      ChildArray2::array(). 

mainSpawner(A,B,ChildArray,Base) ->
    mainSpawnerHelp(A,B,0,ChildArray, Base, self()).


%% @doc spaws two babys that returns result
%% waits for carryIn to know which result to
%% send to parent and which carryOut to
%% send to the next process
-spec spawnChild(A,B,ParentPID, NextPID, Base) -> none() when
      A::[integer()],
      B::[integer()],
      ParentPID::integer(),
      NextPID::integer(),
      Base::integer().
      
spawnChild(A,B, ParentPID, NextPID, Base) ->
    io:format("spawnChild ~n"),
    spawn_link(add, spawnBaby, [A, B, 0, Base, self()]),
    spawn_link(add, spawnBaby, [A, B, 1, Base, self()]),
    ResultArray = array:new(2),
    spawnChildReceiveLoop(ResultArray, ParentPID, NextPID).


%% @doc receives messages from baby processes and prev. process
%% saves results from children
%% send result to parent and carryOut to next process
%% when carryIn from prev. process is recieved
-spec spawnChildReceiveLoop(ResultArray, ParentPID, NextPID) -> none() when
      ResultArray::array(),
      ParentPID::integer(),
      NextPID::integer().
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
		true -> 
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



%% @doc calls the adding function and the sends the result to its parent
-spec spawnBaby(A,B,CarryIn, Base, ParentPID) -> none() when
      A::[integer()],
      B::[integer()],
      CarryIn::integer(),
      Base::integer(),
      ParentPID::integer().
	      
spawnBaby(A,B,CarryIn, Base, ParentPID) ->
    io:format("spawnBaby ~n"),
    ParentPID ! {CarryIn, self(), utils:listAdder(A,B,Base,{CarryIn,[]})}.


