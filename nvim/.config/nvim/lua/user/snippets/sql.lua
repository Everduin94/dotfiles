
local M = {}

M.sql_table = [[create table
  public.notebook_short_public_link (
    id uuid not null default gen_random_uuid (),
    created_at timestamp with time zone null default now(),
    short_public_link text not null,
    description character varying null default ''::character varying,
    is_public boolean not null default false,
    constraint short_public_link unique (short_link_id),
    constraint notebook_short_public_link_pkey primary key (id),
    constraint notebook_short_public_link_notebook_id_fkey foreign key (notebook_id) references decks (id) on delete cascade
  ) tablespace pg_default;]]

M.sql_query_join = [[select d.id, d.title, d.description, pu.user_name, pu.full_name, pu.avatar_url, COUNT(distinct nu.id) as users, COUNT(distinct c.id) as cards from notebook_short_link as sl
  join decks as d on d.id = sl.notebook_id
  left join notebook_users as nu on  d.id = nu.notebook_id
  left join public_users as pu on d.user_id = pu.id
  left join cards as c on d.id = c.deck_id
  where sl.short_link = select_id
  group by d.id, pu.user_name, pu.full_name, pu.avatar_url;]]

M.sql_query_array_lateral = [[select d.id, sr.id as session_id, sr.last_practice_date ,sr.num_of_sessions, d.user_id, d.created_at, d.num_of_cards, d.description, d.title, d.short_public_link_id, d.short_link_id, sr.status, nu.role, pu.user_name, pu.full_name, pu.avatar_url, t.tag_array from notebook_users as nu
  left join decks as d on nu.notebook_id = d.id 
  left join spaced_repetition as sr on sr.notebook_id = nu.notebook_id
  left join public_users as pu on d.user_id = pu.id, LATERAL(
   SELECT ARRAY (
      SELECT nt.id
      FROM   notebook_tags nt
      WHERE  nt.notebook_id = d.id
      ) AS tag_array
  ) as t(tag_array)
  where nu.user_id = auth.uid()
  and (sr.id is null or sr.status != 'ARCHIVE');]]

M.sql_query_array_agg = [[select d.id, sr.id as spaced_repetition_id, sr.last_practice_date, sr.num_of_sessions, d.user_id, d.created_at, d.num_of_cards, d.description, d.title, sr.status, array_agg(nt.tag_id), d.short_link_id, d.short_public_link_id from decks as d
  left join spaced_repetition as sr on sr.notebook_id = d.id
  left join notebook_tags as nt on nt.notebook_id = d.id  
  where d.user_id = auth.uid()
  and (sr.id is null or sr.status != 'ARCHIVE')
  group by d.id, sr.id;]]

-- What is user_role again? Is that custom and how do we make them?
M.sql_function = [[create or replace function example() -- 1
returns table(id uuid,
last_practice_date date,
num_of_sessions numeric, 
created_at timestamptz,
description varchar,
title varchar,
status varchar,
role user_role,
tag_ids uuid[],
) -- 2
language plpgsql -- 3
as $$  -- 4
begin -- plpgsql
  return query -- plpgsql
  select * from table; -- 5 (Must have semicolon w/ plgpgsql)
end; -- plpgsql
$$; --6]]

return M
