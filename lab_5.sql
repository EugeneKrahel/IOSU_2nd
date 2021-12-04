SET LINESIZE 200;

--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * DML-триггер, регистрирующий изменение данных (вставку, обновление, удаление) Таблица GOODS
--!-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE log_dml (
  oper_name CHAR(1),
  pk_key NUMBER,
  column_name VARCHAR2(20),
  old_value VARCHAR2(20),
  new_value VARCHAR2(20),
  username VARCHAR2(10),
  dateoper DATE
);

CREATE
OR REPLACE PROCEDURE logging_dml (
  voper_name IN CHAR,
  vpk_key IN NUMBER,
  vcolumn_name IN VARCHAR2,
  vold_value IN VARCHAR2,
  vnew_value IN VARCHAR2
) IS PRAGMA autonomous_transaction;

date_and_time DATE;

BEGIN IF vold_value <> vnew_value
OR voper_name IN ('I', 'D') THEN
SELECT
  to_char(sysdate) INTO date_and_time
FROM
  dual;

INSERT INTO
  log_dml (
    oper_name,
    pk_key,
    column_name,
    old_value,
    new_value,
    username,
    dateoper
  )
VALUES
  (
    voper_name,
    vpk_key,
    vcolumn_name,
    vold_value,
    vnew_value,
    user,
    date_and_time
  );

COMMIT;
END IF;
END;
/ 

CREATE
OR REPLACE TRIGGER goods_log
AFTER
INSERT
  OR
UPDATE
  OR DELETE ON goods FOR EACH ROW DECLARE op CHAR(1) := 'I';

BEGIN CASE
  WHEN inserting THEN op := 'I';

logging_dml(op, :new.g_id, 'g_name', NULL, :new.g_name);

logging_dml(op, :new.g_id, 'price', NULL, :new.price);

logging_dml(op, :new.g_id, 'amount', NULL, :new.amount);

WHEN updating('g_name')
OR updating('price')
OR updating('amount') THEN op := 'U';

logging_dml(op, :new.g_id, 'g_name', :old.g_name, :new.g_name);
logging_dml(op, :new.g_id, 'price', :old.price, :new.price);
logging_dml(op, :new.g_id, 'amount', :old.amount, :new.amount);

WHEN deleting THEN op := 'D';

logging_dml(op, :old.g_id, 'g_name', :old.g_name, NULL);
logging_dml(op, :old.g_id, 'price', :old.price, NULL);
logging_dml(op, :old.g_id, 'amount', :old.price, NULL);

ELSE NULL;
END CASE;
END goods_log;
/

INSERT INTO goods VALUES (goods_seq.nextval, 'Air', 50, 150);

DELETE FROM goods WHERE g_id = 26;

UPDATE goods SET price = 6 WHERE g_id = 1;

UPDATE goods SET amount = 100 WHERE g_id = 1;

/ 
--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * DDL-триггер, протоколирующий действия пользователей 
--!-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE log_ddl (
  oper_name VARCHAR2(20),
  obj_name VARCHAR2(20),
  obj_type VARCHAR2(20),
  username VARCHAR2(20),
  dateoper DATE
);

CREATE
OR REPLACE PROCEDURE logging_ddl (
  voper_name IN VARCHAR2,
  vobj_name IN VARCHAR2,
  vobj_type IN VARCHAR2
) IS PRAGMA autonomous_transaction;

BEGIN IF voper_name IN ('CREATE', 'ALTER', 'DROP') THEN
INSERT INTO
  log_ddl (
    oper_name,
    obj_name,
    obj_type,
    username,
    dateoper
  )
VALUES
  (
    voper_name,
    vobj_name,
    vobj_type,
    user,
    sysdate
  );

COMMIT;
END IF;
END;
/ 

CREATE
OR REPLACE TRIGGER user_operations_log BEFORE CREATE
OR ALTER
OR DROP ON SCHEMA BEGIN IF to_number(to_char(sysdate, 'HH24')) BETWEEN 0
AND 24 THEN CASE
  ora_sysevent
  WHEN 'CREATE' THEN logging_ddl(
    ora_sysevent,
    ora_dict_obj_name,
    ora_dict_obj_type
  );

WHEN 'ALTER' THEN logging_ddl(
  ora_sysevent,
  ora_dict_obj_name,
  ora_dict_obj_type
);

WHEN 'DROP' THEN logging_ddl(
  ora_sysevent,
  ora_dict_obj_name,
  ora_dict_obj_type
);

ELSE NULL;

END CASE
;

ELSE raise_application_error(
  -20000,
  'Вы попали во временной промежуток, когда запрещено выполнять DDL операции.'
);

END IF;
END user_operations_log;
/

CREATE TABLE test (charr VARCHAR2(20));
ALTER TABLE test MODIFY charr CHAR(1);
DROP TABLE test;

--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * Системный триггер, добавляющий запись во вспомогательную таблицу LOG3, когда пользователь подключается или отключается.
--!-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE in_out_log (
  user_name VARCHAR2(30),
  status_connection VARCHAR2(10),
  date_log DATE,
  row_count INTEGER
);

CREATE
OR REPLACE TRIGGER trig_logon
AFTER
  LOGON ON SCHEMA DECLARE row_count NUMBER;

BEGIN
SELECT
  COUNT(*) INTO row_count
FROM
  orders;

INSERT INTO
  in_out_log
VALUES
  (
    ora_login_user,
    ora_sysevent,
    sysdate,
    row_count
  );

EXECUTE IMMEDIATE 'set linesize 200';
END;
/ 

CREATE
OR REPLACE TRIGGER trig_logoff BEFORE LOGOFF ON SCHEMA DECLARE row_count NUMBER;

BEGIN
SELECT
  COUNT(*) INTO row_count
FROM
  orders;

INSERT INTO
  in_out_log
VALUES
  (
    ora_login_user,
    ora_sysevent,
    sysdate,
    row_count
  );
END;
/ 

--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * 1)	Контролировать имеющиеся в наличии количества продукции при заключении контракта.
-- * 2)	Вести скидочную политику для постоянных клиентов фирмы.
-- * 3)	Протоколировать количество проданной продукции.
--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * 1) Контролировать имеющиеся в наличии количества продукции при заключении контракта.
CREATE
OR REPLACE TRIGGER goods_available BEFORE
INSERT
  ON basket_of_orders FOR EACH ROW 
  DECLARE 
  current_good_amount INTEGER;
  current_good INTEGER;
BEGIN
SELECT
  amount INTO current_good_amount
FROM
  goods
WHERE
  (goods.g_id = :new.g_id);
SELECT
  g_id INTO current_good
FROM
  goods
WHERE
  (goods.g_id = :new.g_id);
  
IF :new.amount > current_good_amount THEN raise_application_error(
  -20001,
  'Недостаточно товара'
);
ELSE 
UPDATE goods SET amount = current_good_amount - :new.amount WHERE (g_id = current_good);
END IF;
END;

INSERT INTO basket_of_orders(ord_id, g_id, amount) VALUES (10, 6, 100);
INSERT INTO basket_of_orders(ord_id, g_id, amount) VALUES (11, 6, 10);


-- * 2) Вести скидочную политику для постоянных клиентов фирмы (при 3ем заказе).
CREATE
OR REPLACE TRIGGER client_discount BEFORE
INSERT
  ON basket_of_orders FOR EACH ROW DECLARE count_orders_of_client INTEGER DEFAULT 0;

good_price INTEGER DEFAULT 0;

current_client INTEGER;

BEGIN
SELECT
  price INTO good_price
FROM
  goods
WHERE
  (g_id = :new.g_id);

SELECT
  cl_id INTO current_client
FROM
  orders
WHERE
  (ord_id = :new.ord_id);

SELECT
  COUNT(*) INTO count_orders_of_client
FROM
  orders
WHERE
  (cl_id = current_client);

IF count_orders_of_client > 2 THEN :new.total_price := :new.amount * good_price * 0.9;

dbms_output.put_line('скидка 10%');

ELSE :new.total_price := :new.amount * good_price;

dbms_output.put_line('нет скидки');
END IF;
END;
/

SET SERVEROUTPUT ON;

INSERT INTO
  basket_of_orders(ord_id, g_id, amount)
VALUES
(42, 3, 10);

INSERT INTO
  basket_of_orders(ord_id, g_id, amount)
VALUES
(4, 3, 10);

-- * 3)	Протоколировать количество проданной продукции.
-- !добавить job
CREATE TABLE goods_sold(
  g_id INTEGER,
  g_name VARCHAR2(20),
  amount NUMBER(3)
);

CREATE
OR REPLACE TRIGGER goods_sold
AFTER
INSERT
  ON basket_of_orders FOR EACH ROW DECLARE current_good_name VARCHAR2(10);

BEGIN
SELECT
  g_name INTO current_good_name
FROM
  goods
WHERE
  (goods.g_id = :new.g_id);

INSERT INTO
  goods_sold
VALUES
(:new.g_id, current_good_name, :new.amount);
END;
/

INSERT INTO basket_of_orders VALUES (10, 6, 10);

--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * COMPOUND 
--!-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE
OR REPLACE TRIGGER black_friday
AFTER
UPDATE
  OF price on goods FOR EACH ROW 
DECLARE
CURSOR all_goods IS
SELECT
  *
FROM
goods
WHERE (price <> :new.price);
BEGIN
  FOR good in all_goods LOOP
    UPDATE goods SET price = good.price * (:new.price / :old.price) WHERE (price = good.price);
  END LOOP;
END;

UPDATE goods set price = 30 WHERE g_name = 'Ecko Unlimited';

-- 
--! тут не смотерть
-- !
-- !
-- !
-- !
CREATE
OR REPLACE TRIGGER black_friday_normal
FOR UPDATE
  OF price on goods
  compound trigger
  can_activate boolean;
  percents NUMBER;
  price_new NUMBER;
  CURSOR all_goods IS
    SELECT *
    FROM goods
    WHERE (price != price_new);
  BEFORE EACH ROW IS
  BEGIN
    IF :new.price < :old.price THEN
      SELECT price INTO price_new
        FROM goods
        WHERE (price = :new.price);
      can_activate := true;
      percents := ROUND(:new.price / :old.price, 2);
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    IF can_activate THEN
      dbms_output.put_line('ХУЙ');
    END IF;
  END AFTER STATEMENT;

END black_friday_normal;
/
-- FOR good IN all_goods LOOP
--         dbms_output.put_line(percents);
--       END LOOP;
-- UPDATE goods SET price = good.price * percents WHERE (g_id = good.g_id);
UPDATE goods set price = 70 WHERE (g_id = 1);
-- !
-- !
-- !
--! тут не смотерть
CREATE
OR REPLACE TRIGGER black_friday_normal
FOR UPDATE
  OF price on goods
  compound trigger
  can_activate boolean;
  
  BEFORE EACH ROW IS
  BEGIN
    IF :new.price < :old.price THEN
      can_activate := true;
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    IF can_activate THEN
      UPDATE goods SET price = 10 WHERE (g_id = 2);
    END IF;
  END AFTER STATEMENT;

END black_friday_normal;

UPDATE goods set price = 70 WHERE (g_id = 1);

--!-----------------------------------------------------------------------------------------------------------------------------------------------------
-- * Триггер INSTEAD OF для работы с необновляемым представлением.
--!-----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER ord_view_instead_of INSTEAD OF
    UPDATE OR INSERT OR DELETE ON orders_view
    FOR EACH ROW
DECLARE
    id_c NUMBER;
    id_w NUMBER;
    id_c1 NUMBER;
    id_w1 NUMBER;
BEGIN
  CASE
    WHEN inserting THEN
      SELECT cl_id INTO id_c FROM clients WHERE (LName = :new.client);
      SELECT w_id INTO id_w FROM workers WHERE (LName = :new.worker);
      INSERT INTO orders(ord_date,cl_id,w_id) VALUES(:new.ord_date, id_c, id_w);
    
    WHEN updating THEN
      SELECT cl_id INTO id_c FROM clients WHERE (LName = :new.client);
      SELECT w_id INTO id_w FROM workers WHERE (LName = :new.worker);
      SELECT cl_id INTO id_c1 FROM clients WHERE (LName = :old.client);
      SELECT w_id INTO id_w1 FROM workers WHERE (LName = :old.worker);
      UPDATE orders SET 
        ord_date = :new.ord_date,
        cl_id = id_c,
        w_id = id_w
      WHERE (ord_date = :old.ord_date 
        AND cl_id = id_c1 
        AND w_id = id_w1);

    WHEN deleting THEN
      SELECT cl_id INTO id_c FROM clients WHERE (LName = :old.client);
      SELECT w_id INTO id_w FROM workers WHERE (LName = :old.worker);
      DELETE from orders 
      WHERE (ord_date = :old.ord_date 
        AND cl_id = id_c 
        AND w_id = id_w);
  END CASE;
END;

INSERT INTO orders_view(ord_date, client, worker) 
  VALUES (to_date('03.06.21', 'dd.mm.yy'),'Dyson','Lewis');

DELETE FROM orders_view 
  WHERE (ord_date = to_date('03.06.21', 'dd.mm.yy'));

UPDATE orders_view SET client = 'Ebden' 
  WHERE client = 'Robertson';


  -- 5.4 (3) сделать через job
  -- +при проверке наличия товара, если он есть, отнимать количество товара
  -- курсор в компаунде пофиксить на переменную
  -- эксепшн для INSTEAD OF