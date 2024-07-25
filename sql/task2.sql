-- Может быть устаревшей
-- https://sqlfiddle.com/oracle-plsql/online-compiler?id=7b2a0d5a-8bbf-46cd-9361-874b07410591

-- Создание временной таблицы
drop table if exists temp_fio;

create table temp_fio (
  name varchar2(100)
);

-- Заполнение временной таблицы данными
insert into temp_fio (name) values ('ivan');
insert into temp_fio (name) values ('John');
insert into temp_fio (name) values ('sidr');

-- НО ПО ЗАДАНИЮ У НАС ФАЙЛ
-- В песочнице нет доступа к файловой системе, но примерный код выглядел бы так:
/*
declare
  F1 utl_file.file_type;
  L1 varchar2(32767);
begin
  -- Открытие файла для чтения
  F1 := utl_file.fopen('DIRECTORY', 'example.txt', 'r');

  -- Чтение данных из файла и вставка в таблицу temp_fio
  loop
    begin
      utl_file.get_line(F1, L1);
      insert into temp_fio (name) values (L1);
    exception
      when no_data_found then
        exit;
    end;
  end loop;

  -- Закрытие файла
  utl_file.fclose(F1);
end;
*/

drop table if exists employees;

create table employees (
  id number not null,
  name varchar2(100) not null,
  department_id number not null,
  hire_date date not null
);

-- Insert Section
INSERT INTO employees(id, name, department_id, hire_date) VALUES (1, 'John', 1, CURRENT_DATE);
INSERT INTO employees(id, name, department_id, hire_date) VALUES (2, 'Wick', 1, CURRENT_DATE);
INSERT INTO employees(id, name, department_id, hire_date) VALUES (3, 'Wayn', 1, CURRENT_DATE);

-- Запрос для нахождения ФИО, которых нет в таблице employees
select name
from temp_fio
where name not in (select name from employees);