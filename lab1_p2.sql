CREATE TABLE clients(
    cl_id INTEGER NOT NULL,
    Fname VARCHAR2(20) NOT NULL,
    Lname VARCHAR2(20) NOT NULL,
    email VARCHAR2(30),
    cr_card VARCHAR2(19),
    PRIMARY KEY(cl_id),
    CONSTRAINT ch_cr_card_clients CHECK(cr_card LIKE '%___%-%___%-%___%-%___%'),
    CONSTRAINT uni_cr_card_clients UNIQUE(cr_card)
);

CREATE TABLE workers(
    w_id INTEGER NOT NULL,
    Fname VARCHAR2(20) NOT NULL,
    Lname VARCHAR2(20) NOT NULL,
    tel_no VARCHAR2(14) NOT NULL,
    position VARCHAR2(40) NOT NULL,
    birthday DATE,
    salary NUMBER(5, 2),
    PRIMARY KEY(w_id),
    CONSTRAINT ch_telno_workers CHECK(tel_no LIKE '%_%-%___%-%___%-%____%')
    ),
    CONSTRAINT uni_telno_workers UNIQUE(tel_no)
);

CREATE TABLE orders(
    ord_id INTEGER NOT NULL,
    ord_date DATE,
    cl_id INTEGER,
    w_id INTEGER,
    PRIMARY KEY(ord_id),
    CONSTRAINT cl_id_fk_orders FOREIGN KEY(cl_id) REFERENCES clients,
    CONSTRAINT w_id_fk_orders FOREIGN KEY(w_id) REFERENCES workers
);

ALTER TABLE orders
MODIFY ord_date NOT NUll;

CREATE TABLE goods(
    g_id INTEGER NOT NULL,
    g_name VARCHAR2(20) NOT NULL,
    price NUMBER(4, 2) NOT NULL,
    amount NUMBER(3),
    PRIMARY KEY(g_id)
);

CREATE TABLE basket_of_orders(
    ord_id INTEGER,
    g_id INTEGER,
    amount NUMBER(3) NOT NULL,
    CONSTRAINT ord_id_fk_basket_of_orders FOREIGN KEY(ord_id) REFERENCES orders,
    CONSTRAINT g_id_fk_basket_of_orders FOREIGN KEY(g_id) REFERENCES goods
);

CREATE SYNONYM cart for basket_of_orders;

CREATE TABLE suppliers(
    sup_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sup_name VARCHAR2(15),
    sup_tel_no VARCHAR2(14),
    CONSTRAINT ch_telno_suppliers CHECK(sup_tel_no LIKE '%_%-%___%-%___%-%____%')
);

CREATE TABLE supply(
    waybill_number INTEGER NOT NULL,
    sup_id INTEGER NOT NULL,
    application_date DATE NOT NULL,
    PRIMARY KEY(waybill_number),
    CONSTRAINT sup_id_fk_supply FOREIGN KEY(sup_id) REFERENCES suppliers
);

CREATE TABLE supply_basket(
    waybill_number INTEGER NOT NULL,
    g_id INTEGER NOT NULL,
    amount NUMBER(3) NOT NULL,
    PRIMARY KEY(waybill_number,g_id),
    CONSTRAINT waybill_number_fk_supply_basket FOREIGN KEY(waybill_number) REFERENCES supply,
    CONSTRAINT g_id_fk_supply_basket FOREIGN KEY(g_id) REFERENCES goods
);

CREATE INDEX key_of_clients_in_orders ON orders(cl_id);
CREATE INDEX key_of_suppliers_in_supply ON supply(sup_id);

CREATE SEQUENCE clients_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE workers_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE orders_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE goods_seq
START WITH 1
INCREMENT BY 1;

-- CREATE SEQUENCE suppliers_seq
-- START WITH 1
-- INCREMENT BY 1;

CREATE SEQUENCE supply_seq
START WITH 1
INCREMENT BY 1;

ALTER TABLE clients
    ADD CONSTRAINT ch_email_clients CHECK(email LIKE '%___@___%.__%');

ALTER TABLE basket_of_orders 
    ADD PRIMARY KEY(ord_id,g_id);

begin
    INSERT INTO clients VALUES(clients_seq.nextval,'Clint','Dyson','Clint_Dyson2258@twipet.com','3680-4063-0242-0154');
    INSERT INTO clients VALUES(clients_seq.nextval,'Harry','Robertson','Harry_Robertson8911@bulaffy.com','4352-8746-2742-4013');
    INSERT INTO clients VALUES(clients_seq.nextval,'Mark','Dubois','Mark_Dubois8863@eirey.tech','2726-1830-4873-3822');
    INSERT INTO clients VALUES(clients_seq.nextval,'Rowan','Ebden','Rowan_Ebden2255@vetan.org','6308-5131-6260-5153');
    INSERT INTO clients VALUES(clients_seq.nextval,'Marigold','Salt','Marigold_Salt566@nickia.com','7868-0180-5745-5532');
    INSERT INTO clients VALUES(clients_seq.nextval,'Jacqueline','Ballard','Jacqueline_Ballard101@bungar.biz','6502-6658-2531-8742');
    INSERT INTO clients VALUES(clients_seq.nextval,'Martha','Roberts','Martha_Roberts4561@deons.tech','1413-0510-5280-6125');
    INSERT INTO clients VALUES(clients_seq.nextval,'Eryn','Evans','Eryn_Evans2826@nanoff.biz','2104-6688-7074-7408');
    INSERT INTO clients VALUES(clients_seq.nextval,'Julius','Murphy','Julius_Murphy4381@zorer.org','5241-1616-2151-8720');
    INSERT INTO clients VALUES(clients_seq.nextval,'Emery','Tyler','Emery_Tyler2720@deons.tech','7204-8516-6627-2675');
end;
/

begin
    INSERT INTO workers VALUES(workers_seq.nextval,'Josephine','Farrant','0-043-202-5017','director',to_date('3/12/1993', 'dd.mm.yy'),776);
    INSERT INTO workers VALUES(workers_seq.nextval,'Manuel','Nayler','2-134-887-7158','manager',to_date('4/3/1983', 'dd.mm.yy'),166);
    INSERT INTO workers VALUES(workers_seq.nextval,'Bob','Corbett','7-771-153-4463','manager',to_date('10/7/1983', 'dd.mm.yy'),617);
    INSERT INTO workers VALUES(workers_seq.nextval,'Aiden','Keys','1-443-232-5328','IT Support Staff',to_date('10/2/1999', 'dd.mm.yy'),338);
    INSERT INTO workers VALUES(workers_seq.nextval,'Sylvia','Hale','5-234-282-0131','Business Broker',to_date('9/10/1980', 'dd.mm.yy'),322);
    INSERT INTO workers VALUES(workers_seq.nextval,'Cedrick','Yates','3-601-780-3634','manager',to_date('12/1/1992', 'dd.mm.yy'),169);
    INSERT INTO workers VALUES(workers_seq.nextval,'Maxwell','Denton','1-130-174-6781','seller',to_date('7/2/1986', 'dd.mm.yy'),280);
    INSERT INTO workers VALUES(workers_seq.nextval,'Ron','Lewis','8-736-754-6482','Cash Manager',to_date('3/10/1985', 'dd.mm.yy'),353);
    INSERT INTO workers VALUES(workers_seq.nextval,'William','Clark','4-246-152-8275','seller',to_date('7/9/1987', 'dd.mm.yy'),658);
    INSERT INTO workers VALUES(workers_seq.nextval,'Ethan','Bryant','2-627-686-6074','seller',to_date('10/9/1983', 'dd.mm.yy'),314);
end;
/

CREATE OR REPLACE TRIGGER seq_orders
	BEFORE INSERT ON orders
	FOR EACH ROW
	BEGIN	
	SELECT orders_seq.nextval 
		INTO :NEW.ord_id 
	FROM DUAL;
END seq_orders;

begin
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('03.06.22 05:03', 'dd.mm.yy hh24:mi'),8,7);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('08.12.20 10:08', 'dd.mm.yy hh24:mi'),3,7);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('08.02.22 10:08', 'dd.mm.yy hh24:mi'),2,10);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('07.01.22 03:07', 'dd.mm.yy hh24:mi'),1,9);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('09.09.20 03:09', 'dd.mm.yy hh24:mi'),7,9);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('07.12.20 01:07', 'dd.mm.yy hh24:mi'),8,3);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('10.11.21 12:10', 'dd.mm.yy hh24:mi'),6,7);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('10.01.21 03:10', 'dd.mm.yy hh24:mi'),10,2);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('01.09.21 01:01', 'dd.mm.yy hh24:mi'),9,3);
    INSERT INTO orders(ord_date,cl_id,w_id) VALUES (to_date('06.12.22 04:06', 'dd.mm.yy hh24:mi'),5,10);
end;
/

begin
    INSERT INTO goods VALUES(goods_seq.nextval,'Ecko Unlimited',35,142);
    INSERT INTO goods VALUES(goods_seq.nextval,'Six Deuce',58,148);
    INSERT INTO goods VALUES(goods_seq.nextval,'Dollie',63,86);
    INSERT INTO goods VALUES(goods_seq.nextval,'Ethika',21,141);
    INSERT INTO goods VALUES(goods_seq.nextval,'Koton',96,138);
    INSERT INTO goods VALUES(goods_seq.nextval,'Real Gold',12,67);
    INSERT INTO goods VALUES(goods_seq.nextval,'Six Deuce',27,473);
    INSERT INTO goods VALUES(goods_seq.nextval,'Izod',18,178);
    INSERT INTO goods VALUES(goods_seq.nextval,'Lilli Ann',91,171);
    INSERT INTO goods VALUES(goods_seq.nextval,'Baby Gap',94,145);
end;
/

begin 
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Comodo','');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Areon Impex','');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Mars','7-676-821-2577');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Vodafone','7-786-318-6383');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Apple Inc.','6-033-070-8677');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Erickson','');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Danone','3-264-066-6123');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Demaco','4-355-323-8348');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('ExxonMobil','');
    INSERT INTO suppliers(sup_name, sup_tel_no) VALUES('Boeing','8-716-774-0073');
end;
/

CREATE OR REPLACE TRIGGER seq_supply
	BEFORE INSERT ON supply
	FOR EACH ROW
	BEGIN	
	SELECT supply_seq.nextval 
		INTO :NEW.waybill_number 
	FROM DUAL;
END seq_supply;

INSERT ALL
    INTO supply(sup_id, application_date) VALUES(1,to_date('28/08/2021', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(1,to_date('14/05/2021', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(2,to_date('04/12/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(7,to_date('13/08/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(3,to_date('02/02/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(4,to_date('09/12/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(9,to_date('08/09/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(7,to_date('04/05/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(1,to_date('04/12/2020', 'dd.mm.yy'))
    INTO supply(sup_id, application_date) VALUES(5,to_date('11/12/2020', 'dd.mm.yy'))
SELECT * FROM dual;
/

INSERT ALL
    INTO cart VALUES(8,2,107)
    INTO cart VALUES(8,4,126)
    INTO cart VALUES(8,7,156)
    INTO cart VALUES(6,8,32)
    INTO cart VALUES(5,8,116)
    INTO cart VALUES(7,1,103)
    INTO cart VALUES(8,1,12)
    INTO cart VALUES(9,8,35)
    INTO cart VALUES(9,7,15)
    INTO cart VALUES(1,6,112)
SELECT * FROM dual;
/

begin
    INSERT INTO supply_basket VALUES(4,6,157);
    INSERT INTO supply_basket VALUES(7,6,100);
    INSERT INTO supply_basket VALUES(7,3,170);
    INSERT INTO supply_basket VALUES(2,8,15);
    INSERT INTO supply_basket VALUES(9,9,118);
    INSERT INTO supply_basket VALUES(1,5,192);
    INSERT INTO supply_basket VALUES(7,4,58);
    INSERT INTO supply_basket VALUES(8,4,118);
    INSERT INTO supply_basket VALUES(7,1,29);
    INSERT INTO supply_basket VALUES(8,1,99);
end;
/


INSERT ALL
    INTO cart VALUES(2,3,97)
    INTO cart VALUES(2,4,56)
    INTO cart VALUES(3,7,136)
    INTO cart VALUES(4,7,32)
    INTO cart VALUES(4,1,16)
    INTO cart VALUES(3,1,143)
    INTO cart VALUES(5,1,102)
    INTO cart VALUES(5,10,95)
    INTO cart VALUES(10,9,75)
    INTO cart VALUES(10,7,112)
    INTO cart VALUES(11,2,11)
SELECT * FROM dual;