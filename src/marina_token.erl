-module(marina_token).
-include("marina_internal.hrl").

-export([
    m3p/1,
    shard_id/2
]).

-define(INT64_MINIMUM, -16#8000000000000000).

%% public
-spec m3p(binary()) ->
    integer().

m3p(Key) ->
    <<Hash:64/signed-little-integer, _/binary>> =
        murmur:murmur3_cassandra_x64_128(Key),
    Hash.

-spec shard_id(integer(), shard_info()) -> integer().

shard_id(Token, ShardInfo) ->
    Token2 = Token + ?INT64_MINIMUM,
    Token3 = Token2 bsl ShardInfo#shard_info.ignore_msb,
    TokenLow = Token3 band 16#FFFFFFFF,
    TokenHigh = (Token bsr 32) band 16#FFFFFFFF,
    Multiply1 = TokenLow * #shard_info.shards_number,
    Multiply2 = TokenHigh * #shard_info.shards_number,
    Sum = (Multiply1 bsr 32) + Multiply2,
    Sum bsr 32.
