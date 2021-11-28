-- Создать процедуру, копирующую строки с информацией о заказах в текущем 
-- месяце во вспомогательную таблицу. Подсчитать количество извлеченных строк.
--! Серверный вывод результатов
SET SERVEROUTPUT ON;

--! Вспомогательная таблица
CREATE TABLE orders_vspomog(
    ord_id INTEGER NOT NULL,
    ord_date DATE,
    cl_id INTEGER,
    w_id INTEGER,
    selected_month VARCHAR2(10),
    PRIMARY KEY(ord_id, selected_month)
);

--! Процедура
CREATE
OR REPLACE PROCEDURE orders_current_month IS counter_orders NUMBER;

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

BEGIN -- *процедура должна быть многоразовой
-- *допустим через delete 
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

/ exec orders_current_month;

--! функция
-- Определение суммы подписанных контрактов
-- за указанный месяц. В качестве параметра передать название месяца в текстовом виде.
CREATE
OR REPLACE FUNCTION money_of_month (selected_month VARCHAR2) RETURN NUMBER IS allmoney NUMBER default 0;

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

BEGIN IF LOWER(selected_month) NOT IN (
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
) THEN RAISE err;

END IF;

FOR elem IN curs_money LOOP allmoney := allmoney + elem.amount * elem.price;

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

/
select
    money_of_month('october')
from
    dual;

--! локальная программа
CREATE
OR REPLACE FUNCTION check_valid_month (selected_month VARCHAR2) RETURN boolean IS valid boolean DEFAULT true;

BEGIN IF LOWER(selected_month) NOT IN (
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
WHEN no_data_found THEN dbms_output.put_line('Неверный месяц');

RETURN NULL;

END check_valid_month;

--! локальная + функция
CREATE
OR REPLACE FUNCTION money_of_month (selected_month VARCHAR2) RETURN NUMBER IS allmoney NUMBER default 0;

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

FUNCTION check_valid_month (selected_month VARCHAR2) RETURN boolean IS BEGIN IF LOWER(selected_month) NOT IN (
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
) THEN RETURN false;

END IF;

RETURN true;

END;

BEGIN IF NOT check_valid_month(selected_month) THEN RAISE err;

END IF;

FOR elem IN curs_money LOOP allmoney := allmoney + elem.amount * elem.price;

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

/ --! перегрузка 
-- no_data_found
CREATE
OR REPLACE FUNCTION money_of_good_in_month (selected_month VARCHAR2, sel_good VARCHAR2) RETURN NUMBER IS allmoney NUMBER default 0;

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

good_name goods.g_name % type;

err EXCEPTION;

FUNCTION check_valid_month (selected_month VARCHAR2) RETURN boolean IS BEGIN IF LOWER(selected_month) NOT IN (
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
) THEN RETURN false;

END IF;

RETURN true;

END;

BEGIN
select
    g_name into good_name
from
    goods
WHERE
    goods.g_name = sel_good;

IF NOT check_valid_month(selected_month) THEN RAISE err;

END IF;

FOR elem IN curs_money LOOP allmoney := allmoney + elem.amount * elem.price;

END LOOP;

RETURN allmoney;

EXCEPTION
WHEN no_data_found THEN dbms_output.put_line('неизвестный товар');

RETURN NULL;

WHEN err THEN dbms_output.put_line('Неверно введён месяц');

RETURN NULL;

END money_of_good_in_month;

/
select
    money_of_good_in_month('october', 'aff')
from
    dual;