create or replace function splitinput()
returns int as $$
declare
    tosplit text;
begin
    tosplit = pg_read_file('in/lvl1/level1_1.in');
    raise notice '%', tosplit;
    return 0;
end; $$ LANGUAGE plpgsql;

select splitinput();