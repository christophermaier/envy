%% -*- erlang-indent-level: 4;indent-tabs-mode: nil; fill-column: 92-*-
%% ex: ts=4 sw=4 et
%%
%% Copyright Opscode, Inc. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% @author Mark Anderson <mark@opscode.com>
%% @copyright 2012 Opscode Inc

%% @doc Simple error checking functions for application:get_env
-module(envy).

-export([get/3,
         get/4
        ]).

-include_lib("eunit/include/eunit.hrl").


fun_ex(any) -> fun(_) -> true end;
fun_ex(integer) -> fun is_integer/1;
fun_ex(bool) -> fun is_boolean/1;
fun_ex(string) -> fun is_list/1;
fun_ex(F) when is_function(F) -> F.

get(Section, Item, TypeCheck) ->
    TypeCheckF = fun_ex(TypeCheck),
    case application:get(Section, Item) of
        {ok, Value} ->
            case TypeCheck(Value) of
                true -> Value;
                Error ->
                    lager:error("Bad typecheck for config item for ~p ~p (~p(~p) -> ~p)",
                                           [Section, Item, TypeCheckF, Value, Error]),
                    error(config_bad_item)
            end;
        undefined ->
            lager:error("Bad config item for ~p ~p ", [Section, Item]),
            error(config_missing_item)
    end.

get(Section, Item, Default, TypeCheck) ->
    TypeCheckF = fun_ex(TypeCheck),
    case application:get(Section, Item) of
        {ok, Value} ->
            case TypeCheck(Value) of
                true -> Value;
                Error ->
                    lager:error("Bad typecheck for config item for ~p ~p (~p(~p) -> ~p)",
                                           [Section, Item, TypeCheckF, Value, Error]),
                    error(config_bad_item)
            end;
        undefined ->
            Default
    end.