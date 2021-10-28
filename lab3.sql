-- Горизонтальное представление
CREATE
OR REPLACE VIEW orders_worder_denton AS
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
            Lname = 'Denton'
    ) WITH CHECK OPTION CONSTRAINT worker_denton;

-- работает.
INSERT INTO
    orders_worder_denton(ord_date, cl_id, w_id)
VALUES
    (to_date('01.01.21 05:03', 'dd.mm.yy hh24:mi'),4,7);

-- не работает.
INSERT INTO
    orders_worder_denton(ord_date, cl_id, w_id)
VALUES
    (to_date('01.02.21 05:03', 'dd.mm.yy hh24:mi'),3,8);

-- вертикальное представление
CREATE
OR REPLACE VIEW orders_view AS
SELECT
    ord_date,
    clients.LName as client,
    workers.LName as worker
FROM
    orders
    JOIN clients clients USING(cl_id)
    JOIN workers workers USING(w_id);

-- не работает
DELETE FROM
    orders_view
WHERE
    client = 'Salt';


/*Обновляемое представление*/
CREATE
OR REPLACE VIEW clients_view AS
SELECT
    *
FROM
    clients
WHERE
    (
        SELECT
            to_number(to_char(sysdate, 'd'))
        FROM
            dual
    ) BETWEEN 2 AND 6
    AND (
        SELECT
            to_number(to_char(sysdate, 'hh24'))
        FROM
            dual
    ) BETWEEN 9 AND 17
    WITH CHECK OPTION;

-- работает, а я ещё нет
INSERT INTO clients_view VALUES(clients_seq.nextval,'John','Tyler','John_Tyler1992@deons.tech','5468-7744-8855-9642');