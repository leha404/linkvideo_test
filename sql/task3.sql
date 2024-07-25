-- Может быть устаревшей
-- https://sqlfiddle.com/oracle-plsql/online-compiler?id=fe36a0fd-bded-4cf0-bb3c-fae3e1cbd13a

drop table if exists events;

create table events (
  id_event number not null,
  description varchar2(100) not null,
  type number not null,
  start_date date not null,
  expiration_date date not null
)
PARTITION BY RANGE (expiration_date)
-- Fix: minimun 1 date is needed
INTERVAL (NUMTODSINTERVAL(1, 'DAY'))
(
  PARTITION p0 VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD'))
);

insert into events(id_event, description, type, start_date, expiration_date)
values(1, '123', 1, CURRENT_DATE - 1, CURRENT_DATE + 1);

insert into events(id_event, description, type, start_date, expiration_date)
values(2, '456', 2, CURRENT_DATE - 1, CURRENT_DATE + 1);

-- ...

-- Основная проблема при большом количестве записей - медленное обновление
-- Так же оно может блокировать всю базу

-- Как вариант (не самый удачный) - запускать обновление как есть, но ночью или по событиям
-- Как более адекватный вариант - разбить обновление на части
-- Тут нам может помочь специальный тип в Oracle: 
-- Курсор (CURSOR) - набор строк, возвращаемых запросом

-- До обновления
select id_event, description, type, 
       TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') AS start_date, 
       TO_CHAR(expiration_date, 'YYYY-MM-DD HH24:MI:SS') AS expiration_date
from events;

DECLARE
  -- Определяем курсор
  CURSOR curs 
  IS
    SELECT id_event, start_date, type
    FROM events
    WHERE type IN (1, 2)
    FOR UPDATE;
  
  TYPE temp_type IS TABLE OF curs%ROWTYPE;
  temp_table temp_type;
  
  -- Размер пакета обновления
  batch_limit PLS_INTEGER := 10000;
BEGIN
  OPEN curs;
  LOOP
  	--  BULK COLLECT, чтобы получить все строки одновременно
    FETCH curs BULK COLLECT INTO temp_table LIMIT batch_limit;
    EXIT WHEN temp_table.COUNT = 0;
    
    FORALL i IN 1..temp_table.COUNT
      UPDATE events
      SET start_date = CASE
                        WHEN temp_table(i).type = 1 THEN temp_table(i).start_date + INTERVAL '1' DAY
                        WHEN temp_table(i).type = 2 THEN temp_table(i).start_date - INTERVAL '1' HOUR
                      END
      WHERE id_event = temp_table(i).id_event;
    
    -- Коммит после каждого пакета
    COMMIT;
  END LOOP;
  
  -- Закрыть курсор
  CLOSE curs;
END;
/

-- Проверяем после обновления
select id_event, description, type, 
       TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') AS start_date, 
       TO_CHAR(expiration_date, 'YYYY-MM-DD HH24:MI:SS') AS expiration_date
from events;