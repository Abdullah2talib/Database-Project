create table emp_info
(
emp_id int,
emp_name varchar2 (20),
date_of_birth date,
email varchar2 (30),
phone_num int,
address varchar2 (20),
primary key (emp_id)
);

create table emp_employment_info
(
emp_id int,
position varchar2 (40),
salary number (10,2),
hire_date date,
arrival_time timestamp,
leaving_time timestamp,
primary key (emp_id),
foreign key (emp_id) references emp_info(emp_id)
);

create table department (
department_id int primary key,
department_name varchar2(50),
department_description varchar2(100),
emp_id int,
foreign key (emp_id) references emp_info(emp_id)
);

/*INSERT INTO department (department_id, department_name, department_description, emp_id)
VALUES (1, 'Produce', 'Responsible for the fruits and vegetables section', 1001);
 an example for depatment description */

create table sales (
sale_id int primary key,
sale_date date,
total_amount number(10,2),
emp_id int,
foreign key (emp_id) references emp_employment_info(emp_id)
);

create table sales_items (
sale_id int,
product_id int,
quantity_sold int,
unit_price number(10,2),
foreign key (sale_id) references sales(sale_id)
);

create table supplier (
supplier_id int primary key,
supplier_name varchar2(50),
contact_phone varchar2(20),
email varchar2(50),
address varchar2(100)
);

create table product (
product_id int primary key,
product_name varchar2(50),
description varchar2(100),
category varchar2(50),
unit_price number (10,2),
supplier_id int,
foreign key (supplier_id) references supplier(supplier_id)
);

create table inventory (
product_id int,
stock_quantity int,
last_stock_date date,
price_per_unit number(10,2),
primary key (product_id),
foreign key (product_id) references product(product_id)
);


-- Trigger for logging all modifications to the inventory table
CREATE OR REPLACE TRIGGER inventory_log_trigger
AFTER INSERT OR UPDATE OR DELETE ON inventory
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO inventory_log (product_id, action_type, action_date)
        VALUES (:NEW.product_id, 'INSERT', SYSDATE);
    ELSIF UPDATING THEN
        INSERT INTO inventory_log (product_id, action_type, action_date)
        VALUES (:NEW.product_id, 'UPDATE', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO inventory_log (product_id, action_type, action_date)
        VALUES (:OLD.product_id, 'DELETE', SYSDATE);
    END IF;
END;
/

-- Trigger for automatically updating the total amount in the sales table
CREATE OR REPLACE TRIGGER sales_total_trigger
AFTER INSERT OR UPDATE OR DELETE ON sales_items
FOR EACH ROW
DECLARE
    v_total number(10,2);
BEGIN
    SELECT SUM(quantity_sold * unit_price) INTO v_total
    FROM sales_items
    WHERE sale_id = :NEW.sale_id;
    
    UPDATE sales SET total_amount = v_total WHERE sale_id = :NEW.sale_id;
END;

-- Trigger to insert a new sales record in the sales table whenever a new sales item is added:

CREATE OR REPLACE TRIGGER insert_sales_record
AFTER INSERT ON sales_items
FOR EACH ROW
BEGIN
  INSERT INTO sales (sale_id, sale_date, total_amount, emp_id)
  VALUES (:new.sale_id, SYSDATE, :new.quantity_sold * :new.unit_price, :new.emp_id);
END;
