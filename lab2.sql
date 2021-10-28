-- условный запрос 
-- заказы за 2020 год
SELECT
    orders.*
FROM
    orders
WHERE
    ord_date < TO_DATE('01.01.2021', 'dd.mm.yyyy')
    and ord_date >= TO_DATE('01.01.2020', 'dd.mm.yyyy');

-- итоговый запрос
-- сводка сумм заказов по клиентам
SELECT
    clients.Lname,
    NVL(Sum(basket.amount * goods.price), 0) AS total_price
FROM
    clients
    LEFT JOIN orders orders ON orders.cl_id = clients.cl_id
    LEFT JOIN basket_of_orders basket ON orders.ord_id = basket.ord_id
    LEFT JOIN goods goods ON goods.g_id = basket.g_id
GROUP BY
    clients.Lname;

--параметрический запрос
--товара на складе меньше заданного
SELECT
    g_name AS goods_name,
    amount
FROM
    goods
WHERE
    goods.amount < & enter_the_quantity;

-- запрос на объединение
-- попытка №100500
SELECT
    clients.Lname as Names,
    NVL(Sum(basket.amount * goods.price), 0) AS total_price
FROM
    clients
    LEFT JOIN orders orders ON orders.cl_id = clients.cl_id
    LEFT JOIN basket_of_orders basket ON orders.ord_id = basket.ord_id
    LEFT JOIN goods goods ON goods.g_id = basket.g_id
GROUP BY
    clients.Lname
UNION
SELECT
    goods.g_name as Names,
    NVL(sum(basket.amount * goods.price), 0) as total_price
FROM
    goods
    LEFT JOIN basket_of_orders basket ON goods.g_id = basket.g_id
GROUP BY
    goods.g_name;

--запрос по полю с типом дата
--количество проданного товара по именам до введённой даты
ALTER SESSION
SET
    NLS_DATE_FORMAT = 'DD.MM.YY';

-- более адекватный запрос
-- заказы по кварталам за год
SELECT
    TO_CHAR(ord_date, 'q') AS quarter,
    COUNT(ord_id) AS orders_count
FROM
    orders
WHERE
    TO_CHAR(ord_date, 'yy') between 19
    and 21
GROUP BY
    TO_CHAR(ord_date, 'q')
ORDER BY
    quarter;

--дальше смэртб
-- запрос через IN
-- Все заказы указанного работника через IN
SELECT
    *
FROM
    orders
WHERE
    w_id IN (
        SELECT
            w_id
        FROM
            workers
        WHERE
            Lname = '&enter_worker_name'
    );

-- Denton
-- запрос через ALL
-- вывести все товары, количество которых в заказах > чем во всех поставках
SELECT
    goods.g_name as good_name,
    sum(basket.amount) AS orders_amount
FROM
    basket_of_orders basket
    JOIN goods USING(g_id)
GROUP BY
    goods.g_name
HAVING
    sum(basket.amount) >= ALL (
        SELECT
            sum(supply_basket.amount) AS supply_amount
        FROM
            supply_basket
        GROUP BY
            g_id
    );

-- EXISTS
-- Вывести товары, поставок которых не было последний год 
SELECT
    goods.g_name,
    orders.ord_date
FROM
    goods
    LEFT JOIN basket_of_orders basket ON basket.g_id = goods.g_id
    LEFT JOIN orders orders ON orders.ord_id = basket.ord_id
WHERE
    SYSDATE - orders.ord_date > 365;

-- а тут как вы хотели EXISTS
SELECT
    goods.g_name
FROM
    goods
    LEFT JOIN basket_of_orders basket ON basket.g_id = goods.g_id
WHERE
    EXISTS (
        SELECT
            1
        FROM
            orders
        WHERE
            orders.ord_id = basket.ord_id
            and SYSDATE - orders.ord_date > 365
    );

-- обновить одной командой данные о дате поставки для одного поставщика +10 днeй, для другого -10 дней (поставщики указываются явно)
UPDATE
    supply
SET
    application_date = CASE
        WHEN sup_id = 1 THEN (application_date + 10)
        WHEN sup_id = 2 THEN (application_date - 10)
        ELSE application_date
    END;

-- в одном запросе вывести для каждого сотрудника общее количество обслуженных клиентов и проданных им товаров.
SELECT
    workers.LName as worker,
    COUNT(orders.w_id) as clients_count,
    NVL(SUM(basket_of_orders.amount), 0) as goods_count
FROM workers
    LEFT JOIN orders orders ON workers.w_id = orders.w_id
    LEFT JOIN basket_of_orders basket_of_orders ON orders.ord_id = basket_of_orders.ord_id
HAVING COUNT(orders.w_id) IS NOT NULL
GROUP BY workers.LName;


SELECT
    workers.LName as worker,
    COUNT(orders.w_id) as clients_count,
    NVL(SUM(basket_of_orders.amount), 0) as goods_count
FROM workers
    LEFT JOIN orders orders ON workers.w_id = (

    )
    LEFT JOIN basket_of_orders basket_of_orders ON orders.ord_id = basket_of_orders.ord_id
GROUP BY workers.LName;