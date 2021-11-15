-- ! Пакет 
--Create a new Package
create or replace NONEDITIONABLE PACKAGE pack IS 

-- Add a procedure
PROCEDURE orders_current_month;

-- Add a function
FUNCTION check_valid_month (selected_month VARCHAR2) RETURN boolean;

FUNCTION money_of_month (selected_month VARCHAR2) RETURN NUMBER;

FUNCTION money_of_good_in_month (selected_month VARCHAR2, sel_good VARCHAR2) RETURN NUMBER;

END pack;

/

--Create a new Package Body

CREATE OR REPLACE PACKAGE BODY pack IS
  --! Процедура
  PROCEDURE orders_current_month IS counter_orders NUMBER;

  line_atr orders % rowtype;

  CURSOR required_orders IS
  SELECT
      *
  FROM
      orders
  WHERE
      to_char(orders.ord_date, 'mm.yy') = (
          SELECT
              to_char(sysdate, 'mm.yy')
          FROM
              dual
      );

  CURSOR exist_months IS
  SELECT
      selected_month
  FROM
      orders_vspomog
  ORDER BY
      selected_month;

  err EXCEPTION;

  BEGIN 
  delete from
      orders_vspomog;

  OPEN required_orders;

  FETCH required_orders INTO line_atr;

  IF required_orders % notfound THEN RAISE err;

  END IF;

  LOOP EXIT
  WHEN required_orders % notfound;

  counter_orders := required_orders % rowcount;

  INSERT INTO
      orders_vspomog
  VALUES
      (
          line_atr.ord_id,
          line_atr.ord_date,
          line_atr.cl_id,
          line_atr.w_id,
          to_char(
              sysdate,
              'mm.yyyy'
          )
      );

  FETCH required_orders INTO line_atr;

  END LOOP;

  COMMIT;

  CLOSE required_orders;

  dbms_output.put_line('Количество заказов:' || counter_orders);

  EXCEPTION
  WHEN storage_error THEN raise_application_error(
      -6500,
      'Не хватает оперативной памяти!'
  );

  WHEN err THEN dbms_output.put_line('В этом месяце нет заказов');

  END;

  --! локальная программа

  FUNCTION check_valid_month (selected_month VARCHAR2) RETURN boolean IS valid boolean DEFAULT true;
  BEGIN
    IF LOWER(selected_month) NOT IN (
        'january',
        'february',
        'march',
        'april',
        'may',
        'june',
        'july',
        'august',
        'september',
        'october',
        'november',
        'december'
    ) THEN valid := false;
    END IF;
    RETURN valid;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Неверный месяц');
            RETURN NULL;
  END check_valid_month;

  --! локальная + функция
  FUNCTION money_of_month (selected_month VARCHAR2) RETURN NUMBER IS allmoney NUMBER default 0;

  CURSOR curs_money IS
  SELECT
      basket.amount as amount,
      goods.price as price
  FROM
      goods
      LEFT JOIN basket_of_orders basket ON goods.g_id = basket.g_id
      LEFT JOIN orders orders ON basket.ord_id = orders.ord_id
  WHERE
      TRIM(to_char(orders.ord_date, 'month')) = LOWER(selected_month);

  err EXCEPTION;

  BEGIN 
  IF NOT check_valid_month(selected_month)
      THEN RAISE err;
  END IF;

  FOR elem IN curs_money
  LOOP 
      allmoney := allmoney + elem.amount*elem.price;
  END LOOP;

  RETURN allmoney;

  EXCEPTION
  WHEN value_error THEN raise_application_error(
      -20004,
      'Ошибка в операции преобразования или математической операции!'
  );
  RETURN NULL;

  WHEN err THEN dbms_output.put_line('Неверно введён месяц');
  RETURN NULL;
  END money_of_month;

  --! перегрузка 
  -- no_data_found
  FUNCTION money_of_good_in_month (selected_month VARCHAR2, sel_good VARCHAR2) RETURN NUMBER IS allmoney NUMBER default 0;

  CURSOR curs_money IS
  SELECT
      basket.amount as amount,
      goods.price as price
  FROM
      goods
      LEFT JOIN basket_of_orders basket ON goods.g_id = basket.g_id
      LEFT JOIN orders orders ON basket.ord_id = orders.ord_id
  WHERE
      TRIM(to_char(orders.ord_date, 'month')) = LOWER(selected_month)
      AND goods.g_name = sel_good;

  good_name goods.g_name%type;
  err EXCEPTION;

  BEGIN 
  select g_name into good_name from goods WHERE goods.g_name = sel_good;

  IF NOT check_valid_month(selected_month)
      THEN RAISE err;
  END IF;

  FOR elem IN curs_money
  LOOP 
      allmoney := allmoney + elem.amount*elem.price;
  END LOOP;

  RETURN allmoney;

  EXCEPTION
  WHEN no_data_found THEN
      dbms_output.put_line('неизвестный товар');
      RETURN NULL;

  WHEN err THEN 
      dbms_output.put_line('Неверно введён месяц');
      RETURN NULL;
  END money_of_good_in_month;
END pack;

--! Анонимный блок

BEGIN
    dbms_output.put_line('Процедура нормальная:');
    pack.orders_current_month;
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('15.11.21 05:03', 'dd.mm.yy hh24:mi'),8,7);
    COMMIT;
    dbms_output.put_line('Процедура (если в текущем месяце новый заказ, то он допишется, если поменялся текущий месяц, то будут новые данные, потому что зачем нам старые):');
    pack.orders_current_month;
    
    dbms_output.put_line('Функция + локалка:');
    dbms_output.put_line('Деньги за октябрь: ');
    dbms_output.put_line(pack.money_of_month('october'));

    dbms_output.put_line('Перегруз: ');
    dbms_output.put_line(pack.money_of_good_in_month('october', 'I2zod'));
END;
/
