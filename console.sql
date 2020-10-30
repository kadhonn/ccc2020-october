truncate table prices;
truncate table tasks;
truncate table task_costs;
truncate table output;

create or replace function readInput()
returns text as $$
declare
    tosplit text;
begin
    tosplit = pg_read_file('in/lvl2/level2_5.in');
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
    taskduration int;
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
        taskduration := SPLIT_PART(task, ' ', 2)::int;
        insert into tasks values (taskid, taskduration);
    end loop;
    return tosplit;
end; $$ LANGUAGE plpgsql;

select parseInput();


create or replace function calcCosts()
returns text as $$
declare
    task tasks%ROWTYPE;
    i int;
begin
    for task in select * from tasks loop
        i := 0;
        loop
            if ( i + task.taskduration > (select count(*) from prices) ) then
                exit;
            end if;
            insert into task_costs values( task.taskid,(select sum(price) from prices where id >= i and id <i+task.taskduration),i);
            i := i+1;
        end loop;
    end loop;
    return 0;
end; $$ LANGUAGE plpgsql;

create or replace function findMin()
returns text as $$
declare
    out text;
    mintask task_costs%ROWTYPE;
begin
    out = '' || ((select count(*) from tasks)::text) || E'\n';
    for mintask in (select taskid, price, beginwtf from task_costs where taskid::text||price::text in (select taskid::text||min(price)::text from task_costs group by taskid)) loop

        raise notice '%', mintask;
        out = out || mintask.taskid || ' ' || mintask.beginwtf || E'\n';
    end loop;
    insert into output values (out);
    return out;
end; $$ LANGUAGE plpgsql;

select calcCosts();
select findMin();

COPY (SELECT * from output) TO '/in/some_file_name' CSV QUOTE ' ';