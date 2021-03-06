%%%-----------------------------------------------------------------------------
%%% @author tgrk <tajgur@gmail.com>
%%% @doc
%%% Ybot brain HTTP API server.
%%% @end
%%%-----------------------------------------------------------------------------
-module(ybot_brain_api_server).

-behaviour(gen_server).

-export([start_link/2]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {}).

%% API
start_link(Host, Port) ->
    Host1 = binary_to_list(Host),
    lager:info("Start brain REST API: http://~s:~p/memories", [Host1, Port]),
    gen_server:start_link(?MODULE, [Host1, Port], []).

init([Host, Port]) ->
    % start server
    ok = gen_server:cast(self(), {start_server, Host, Port}),
    % init state
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

%% @doc Start HTTP REST API
handle_cast({start_server, Host, Port}, State) ->
    % cowboy routes
    Dispatch = cowboy_router:compile([
        {Host, [{"/memories/[:memory_id]", ybot_brain_api, []}]}
    ]),

    {ok, _} = cowboy:start_http(http, 100, [{port, Port}], [
        {env, [{dispatch, Dispatch}]}
    ]),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
