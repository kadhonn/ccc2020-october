truncate table prices;
-- truncate table output;
drop sequence serial;
CREATE SEQUENCE serial START 1;

create or replace function readInput()
returns text as $$
declare
    tosplit text;
begin
    tosplit = pg_read_file('in/lvl1/level1_5.in');
--     raise notice '%', tosplit;
    return tosplit;
end; $$ LANGUAGE plpgsql;


create or replace function parseInput()
returns text as $$
declare
    current int;
    price int;
    tosplit text;
    n int;
begin
    tosplit := readInput();
    raise notice 'wat % ',tosplit;
    n := SPLIT_PART(tosplit, E'\n', 1)::int;
    raise notice 'the fuck %', n;
    loop
        current := nextval('serial');
        if (n = current ) then
            exit;
        end if;
        price := SPLIT_PART(tosplit, E'\n', current+1)::int;
        insert into prices values (price, current);
    end loop;
    return tosplit;
end; $$ LANGUAGE plpgsql;

select parseInput();
select id-1, price from prices where price = any(select min(price) from prices);
