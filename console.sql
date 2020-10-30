truncate table prices;
truncate table tasks;
truncate table task_power;
truncate table output;
truncate table i;

create or replace function readInput()
returns text as $$
declare
    tosplit text;
begin
    tosplit = pg_read_file('in/lvl4/level4_1.in');
--     raise notice '%', tosplit;
    return tosplit;
end; $$ LANGUAGE plpgsql;


create or replace function parseInput()
returns text as $$
declare
    i int := 3;
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
    insert into i values (SPLIT_PART(tosplit, E'\n', 1)::int);
    n := SPLIT_PART(tosplit, E'\n', i)::int;
    raise notice 'before prices';
    loop
        i := i+1;
        if (n+4 = i ) then
            exit;
        end if;
        price := SPLIT_PART(tosplit, E'\n', i)::int;
        insert into prices values (price, i-4);
    end loop;
    m := SPLIT_PART(tosplit, E'\n', i)::int;
    raise notice 'before tasks %',m;
    loop
        i := i+1;
        if (m+n+5 = i ) then
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
    price prices%ROWTYPE;
    task tasks%ROWTYPE;
    remainingpower int;
    wanttouse int;
    consumed int;
    task_powervar task_power%ROWTYPE;
begin
    for price in (select * from prices order by price asc) loop
        select powermax from i into remainingpower;


        for task in select * from tasks where tasks.taskstart <= price.id and tasks.taskend >= price.id loop


            select coalesce(sum(powerconsumed),0) from task_power where taskid = task.taskid group by taskid into consumed;
            if (remainingpower > consumed) then
                wanttouse = remainingpower;
            else
                wanttouse = consumed;
            end if;
            remainingpower = remainingpower - wanttouse;
            raise notice 'consumed: %', consumed;
            raise notice 'remainingpower: %', remainingpower;
            raise notice 'wanttouse: %', wanttouse;
            insert into task_power values (task.taskid, price.id, wanttouse);
            if (remainingpower = 0) then
                exit;
            end if;
        end loop;
    end loop;
            raise notice 'FUUU';
    out = '' || ((select count(*) from tasks)::text) || E'\n';
            raise notice 'WAT1 %', out;
    for task in select * from tasks loop
        out = out || task.taskid::text;
            raise notice 'WAT2 %', out;
        for task_powervar in select * from task_power where taskid = task.taskid loop
            out = out || ' ' || task_powervar.priceid::text || ' ' || task_powervar.powerconsumed::text;
            raise notice 'WAT3 %', out;
        end loop;
        out = out || E'\n';
            raise notice 'WAT4 %', out;
    end loop;
            raise notice 'WAT5 %', out;
    insert into output values (out);
    return out;
end; $$ LANGUAGE plpgsql;

select findMin();

COPY (SELECT * from output) TO '/in/some_file_name' CSV QUOTE ' ';
