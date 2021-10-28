CREATE TABLE branch(bno INTEGER NOT NULL,
                    street VARCHAR2(30) NOT NULL,
                    city VARCHAR2(15) NOT NULL,
                    tel_no VARCHAR2(17),
                    PRIMARY KEY(bno),
                    CONSTRAINT ch_telno_branch
                                CHECK(REGEXP_LIKE(tel_no, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
                    CONSTRAINT uni_telno_branch UNIQUE(tel_no));

CREATE TABLE staff(sno INTEGER NOT NULL,
                    fname VARCHAR2(20) NOT NULL,
                    lname VARCHAR2(20) NOT NULL,
                    address VARCHAR2(60) NOT NULL,
                    tel_no VARCHAR2(17) NOT NULL,
                    position VARCHAR2(40) NOT NULL,
                    sex VARCHAR2(6),
                    dob DATE,
                    salary NUMBER(5,2),
                    bno INTEGER,
                    PRIMARY KEY(sno),
                    CONSTRAINT ch_telno_staff
                               CHECK(REGEXP_LIKE(tel_no, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
                    CONSTRAINT uni_telno_staff 
                               UNIQUE(tel_no),
                    CONSTRAINT ch_sex
                               CHECK(sex IN('male','female')),
                    CONSTRAINT bno_fk_staff
                               FOREIGN KEY(bno)
                               REFERENCES branch
                     );

CREATE TABLE property_for_rent(pno INTEGER NOT NULL,
                    street VARCHAR2(30) NOT NULL,
                    city VARCHAR2(15) NOT NULL,
                    type_obj CHAR(1) NOT NULL,
                    rooms INTEGER,
                    rent NUMBER(5,2),
                    ono INTEGER,
                    sno INTEGER,
                    bno INTEGER,
                    PRIMARY KEY(pno),
                    CONSTRAINT ch_obj_type
                               CHECK(type_obj IN('h','f')),
                    CONSTRAINT sno_fk_pfrent
                               FOREIGN KEY(sno)
                               REFERENCES staff,           
                    CONSTRAINT bno_fk_pfrent
                               FOREIGN KEY(bno)
                               REFERENCES branch
                     );

CREATE SYNONYM objects for property_for_rent;

CREATE TABLE renter(rno INTEGER NOT NULL,
                    fname VARCHAR2(20) NOT NULL,
                    lname VARCHAR2(20),
                    address VARCHAR2(60),
                    tel_no VARCHAR2(17),
                    pref_type CHAR(1),
                    max_rent NUMBER(5,2),
                    bno INTEGER,
                    PRIMARY KEY(rno),
                    CONSTRAINT ch_pref_type
                               CHECK(pref_type IN('h','f')),
                    CONSTRAINT ch_telno_renter
                                CHECK(REGEXP_LIKE(tel_no, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
                    CONSTRAINT uni_telno_renter
                               UNIQUE(tel_no),                                    
                    CONSTRAINT bno_fk_renter
                               FOREIGN KEY(bno)
                               REFERENCES branch
                     );

CREATE TABLE owner(ono INTEGER NOT NULL,
                    fname VARCHAR2(20),
                    lname VARCHAR2(20),
                    address VARCHAR2(60),
                    tel_no VARCHAR2(17),
                    PRIMARY KEY(ono),
                    CONSTRAINT ch_telno_owner
                                CHECK(REGEXP_LIKE(tel_no, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
                    CONSTRAINT uni_telno_owner
                               UNIQUE(tel_no)                                   
                     ); 

ALTER TABLE property_for_rent
ADD CONSTRAINT ono_fk1
               FOREIGN KEY(ono)
               REFERENCES owner;

CREATE TABLE viewing(rno INTEGER NOT NULL,
                     pno INTEGER NOT NULL,
                    date1 DATE NOT NULL,
                    comment1 VARCHAR2(300),
                    PRIMARY KEY(rno,pno),
                    CONSTRAINT rno_fk_viewing
                               FOREIGN KEY(rno)
                               REFERENCES renter,
                    CONSTRAINT pno_fk_viewing
                               FOREIGN KEY(pno)
                               REFERENCES property_for_rent                             
                     );      

Последовательности:
CREATE SEQUENCE branch_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE staff_seq
START WITH 10
INCREMENT BY 5;

CREATE SEQUENCE property_for_rent_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE renter_seq
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER seq_branch
	BEFORE INSERT ON branch
	FOR EACH ROW
	BEGIN	
	SELECT branch_seq.nextval 
		INTO :NEW.bno 
	FROM DUAL;
END seq_branch ;

begin
insert into branch(street, city, tel_no) values('Ленина 42','Минск','+375(29)221-11-71');
insert into branch(street, city, tel_no) values('Якуба Коласа 13','Минск','+375(33)222-11-71');
insert into branch(street, city, tel_no) values('Пролетарская 17','Брест','+375(25)223-11-71');
insert into branch (street, city, tel_no)values('Совецкая','Брест','+375(29)224-11-71');
insert into branch (street, city, tel_no)values('Комсомольская 764','Витебск','+375(29)225-11-71');
insert into branch (street, city, tel_no)values('Янки Купалы 123','Гомель','+375(29)226-11-71');
insert into branch(street, city, tel_no) values('Максима Танка 64','Гродно','+375(29)227-11-71');
insert into branch (street, city, tel_no)values('Ленина 88','Могилев','+375(29)228-11-71');
insert into branch (street, city, tel_no)values('Машерова 44','Могилев','+375(33)229-11-71');
insert into branch (street, city, tel_no)values('Октябрьская 58','Витебск','+375(29)230-11-71');
insert into branch (street, city, tel_no)values('Октябрьская 102','Гродно','+375(29)255-11-71');
end;
/

insert into staff values(staff_seq.nextval,'Якубов','Виктор','Минск, Горького 19','+375(25)225-11-71','director',
'male', to_date('17.03.86', 'dd.mm.yy'),300,1);
insert into staff values(staff_seq.nextval,'Якубова','Анна','Брест, Горького 19','+375(29)225-11-71','manager',
'female', to_date('22.09.87', 'dd.mm.yy'),250,2);
insert into staff values(staff_seq.nextval,'Шевцов','Дмитрий','Гомель, Красноармейская 14','+375(33)225-11-71','seller',
'male', to_date('25.04.90', 'dd.mm.yy'),800,2);
insert into staff values(staff_seq.nextval,'Карпеш','Елизавета','Гродно, Притыцкого 33','+375(29)221-11-71','manager',
'female', to_date('30.12.91', 'dd.mm.yy'),200,3);
insert into staff values(staff_seq.nextval,'Самсонова','Дарья','Могилев, Советская 12','+375(29)225-12-71','manager',
'female', to_date('30.08.78', 'dd.mm.yy'),280,5);
insert into staff values(staff_seq.nextval,'Шостак','Руслан','Минск, Ленина 13','+375(29)225-31-71','manager',
'male', to_date('04.05.96', 'dd.mm.yy'),190,6);
insert into staff values(staff_seq.nextval,'Минич','Виктор','Гродно, Хлебобулочная 33','+375(29)225-41-71','seller',
'male', to_date('12.08.88', 'dd.mm.yy'),700,6);
insert into staff values(staff_seq.nextval,'Потапенко','Максим','Минск, Беспощадня 19','+375(29)225-51-71','seller',
'male', to_date('25.06.80', 'dd.mm.yy'),900,7);
insert into staff values(staff_seq.nextval,'Кенда','Яна','Витебск, Пролетарская 73','+375(29)225-22-71','seeller',
'male', to_date('17.03.86', 'dd.mm.yy'),300,8);


insert into owner(ono,fname,lname,address,tel_no) select staff_seq.nextval,fname,lname,address,tel_no from staff;

begin
insert into objects values (property_for_rent_seq.nextval,'Якуба Коласа 43','Минск','h',2,600,55,20,1);
insert into objects values (property_for_rent_seq.nextval,'Пролетарская 13','Минск','f',3,500,60,30,1);
insert into objects values (property_for_rent_seq.nextval,'Совецкая 77','Брест','f',4,100,65,20,3);
insert into objects values (property_for_rent_seq.nextval,'Янки купалы 105','Гомель','h',4,400, 65,35,6);

insert into renter values(renter_seq.nextval,'Иванов','Иван','Минск, Минина 5','+375(29)225-11-71','h',500,1);
insert into renter values(renter_seq.nextval,'Петров','Петр','Брест, Малорийская 76','+375(29)225-11-72','f',400,1);
insert into renter values(renter_seq.nextval,'Козяк','Инокентий','Гродно, Пролетарская 666','+375(29)225-11-73','h',900,3);
insert into renter values(renter_seq.nextval,'Алексеев','Максим','Могилев, Болотная 9','+375(29)225-11-74','f',700,3);
insert into renter values(renter_seq.nextval,'Романов','Роман','Гомель, Советская 73','+375(29)225-11-75','h',500,6);
end;
/
begin
insert into viewing values(1, 4,to_date('03.12.19', 'dd.mm.yy'),'ok');
insert into viewing values(1, 3,to_date('03.10.20', 'dd.mm.yy'),'good');
insert into viewing values(2, 1,to_date('15.08.20', 'dd.mm.yy'),'');
insert into viewing values(4, 1,to_date('16.08.19', 'dd.mm.yy'),'bad');
insert into viewing values(5, 2,to_date('04.12.20', 'dd.mm.yy'),'');
end;
/
