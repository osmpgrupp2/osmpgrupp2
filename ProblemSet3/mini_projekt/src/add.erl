%% @doc Erlang mini project.
-module(add).
-export([start/3, start/4]).

-compile(export_all).

%% @doc TODO: add documentation
-spec start(A,B,Base) -> ok when 
      A::string(),
      B::string(), 
      Base::integer().

start(A,B, Base) ->
    T = 1,
    AL = utils:convertBase(A,Base),
    BL = utils:convertBase(B,Base),
    {A_noll,B_noll} = utils:nolligt(utils:listigt(AL, []),utils:listigt(BL,[]), T),
    AN = utils:split(A_noll, T),
    BN = utils:split(B_noll, T),

    ChildArray = array:new(length(AN)),
    ChildArray2 = mainSpawner(AN,BN,ChildArray,Base),
    FirstChild = array:get(length(AN) -1, ChildArray2),
    FirstChild ! {carryIn, 0},
    ResultArray = array:new(length(AN)), 
    ResultArray2 = mainRecieverLoopiloop(ChildArray2, ResultArray, length(AN)), 

    {CarryList, ResultList} = lists:unzip(array:to_list(ResultArray2)),
    TheResultList = lists:append(ResultList),
    utils:print(utils:listIt(A,length(A),[]), utils:listIt(B,length(B),[]), utils:convert_to_N(lists:sublist(CarryList,1) ++ TheResultList, Base), CarryList ++ [0]). 

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
	{carryIn, _Result} ->
	    mainRecieverLoopiloop(ChildArray, ResultArray, Counter);
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
      ParentPID::pid(),
      ChildArray2::array().

mainSpawnerHelp([], _,_ , ChildArray, _, _) -> 
    ChildArray;
mainSpawnerHelp([A | Atl],[B | Btl], 0, ChildArray, Base, ParentPID) ->
    mainSpawnerHelp(Atl, Btl, 1, array:set(0, spawn(add, spawnChild, [A, B, ParentPID, ParentPID, Base]), ChildArray), Base, ParentPID);
mainSpawnerHelp([A | Atl],[B | Btl],Index, ChildArray, Base, ParentPID) ->
    mainSpawnerHelp(Atl, Btl,Index + 1, array:set(Index, spawn(add, spawnChild, [A,B, ParentPID, (array:get((Index - 1), ChildArray)),Base])
						  , ChildArray), Base, ParentPID).




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
      ParentPID::pid(),
      NextPID::pid(),
      Base::integer().

spawnChild(A,B, ParentPID, NextPID, Base) ->
    ChildPID = self(),
    spawn_link(add, spawnBaby, [A, B, 0, Base, ChildPID]),
    spawn_link(add, spawnBaby, [A, B, 1, Base, ChildPID]),
    spawnChildReceiveLoop(ParentPID, NextPID).


%% @doc receives messages from baby processes and prev. process
%% saves results from children
%% send result to parent and carryOut to next process
%% when carryIn from prev. process is recieved
-spec spawnChildReceiveLoop(ParentPID, NextPID) -> none() when
      ParentPID::pid(),
      NextPID::pid().
spawnChildReceiveLoop(ParentPID, NextPID) -> 
receive
	{carryIn, 0} -> %%om vi får veta att carryIn är 0
	    Result = spawnChildReceiveResultZero(),
	    NextPID ! {carryIn, element(1, Result)},
	    ParentPID ! {self(), Result};

	{carryIn, 1} -> %%om vi får veta att carry in är 1
	    Result = spawnChildReceiveResultOne(),
	    NextPID ! {carryIn, element(2, Result)},
	    ParentPID ! {self(), Result}
    end.

spawnChildReceiveResultZero() ->
    receive
	{0, Baby, Result} ->
	    exit(Baby, kill),
	    Result
    end.


spawnChildReceiveResultOne() ->
    receive
	{1, Baby, Result} ->
	    exit(Baby, kill),
	    Result
    end.




%% @doc calls the adding function and the sends the result to its parent
-spec spawnBaby(A,B,CarryIn, Base, ParentPID) -> none() when
      A::[integer()],
      B::[integer()],
      CarryIn::integer(),
      Base::integer(),
      ParentPID::pid().
	      
spawnBaby(A,B,CarryIn, Base, ParentPID) ->
    ParentPID ! {CarryIn, self(), utils:listAdder(A,B,Base,{CarryIn,[]})}.


