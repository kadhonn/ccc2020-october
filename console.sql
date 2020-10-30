truncate table prices;
truncate table tasks;
truncate table task_costs;
truncate table output;

create or replace function readInput()
returns text as $$
declare
    tosplit text;
begin
    tosplit = pg_read_file('in/lvl3/level3_5.in');
--     raise notice '%', tosplit;
    return tosplit;
end; $$ LANGUAGE plpgsql;


create or replace function parseInput()
returns text as $$
declare
    i int := 1;
    price int;
    tosplit text;
    task text;
    taskid int;
    taskpower int;
    taskstart int;
    taskend int;
    n int;
    m int;
begin
    tosplit := readInput();
    n := SPLIT_PART(tosplit, E'\n', i)::int;
    raise notice 'before prices';
    loop
        i := i+1;
        if (n+2 = i ) then
            exit;
        end if;
        price := SPLIT_PART(tosplit, E'\n', i)::int;
        insert into prices values (price, i-2);
    end loop;
    m := SPLIT_PART(tosplit, E'\n', i)::int;
    raise notice 'before tasks %',m;
    loop
        i := i+1;
        if (m+n+3 = i ) then
            exit;
        end if;
        task := SPLIT_PART(tosplit, E'\n', i);
        taskid := SPLIT_PART(task, ' ', 1)::int;
        taskpower := SPLIT_PART(task, ' ', 2)::int;
        taskstart := SPLIT_PART(task, ' ', 3)::int;
        taskend := SPLIT_PART(task, ' ', 4)::int;
        insert into tasks values (taskid, taskpower, taskstart, taskend);
    end loop;
    return tosplit;
end; $$ LANGUAGE plpgsql;

select parseInput();

create or replace function findMin()
returns text as $$
declare
    out text;
    task tasks%ROWTYPE;
    minid int;
begin
    out = '' || ((select count(*) from tasks)::text) || E'\n';
    for task in (select * from tasks) loop
        select min(id) from prices where id >= task.taskstart and id <=task.taskend and price = any(select min(price) from prices where id >= task.taskstart and id <=task.taskend) into minid;
        raise notice '%', task;
        out = out || task.taskid || ' ' || minid || ' ' || task.taskpower || E'\n';
    end loop;
    insert into output values (out);
    return out;
end; $$ LANGUAGE plpgsql;

select findMin();

COPY (SELECT * from output) TO '/in/some_file_name' CSV QUOTE ' ';