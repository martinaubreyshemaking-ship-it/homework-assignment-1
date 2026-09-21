CREATE TABLE customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(100),
  email VARCHAR2(100),
  city VARCHAR2(50)
);

CREATE TABLE products (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(100),
  category VARCHAR2(50),
  price NUMBER(10,2)
);

CREATE TABLE orders (
  order_id NUMBER PRIMARY KEY,
  customer_id NUMBER REFERENCES customers(customer_id),
  order_date DATE
);

CREATE TABLE order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES orders(order_id),
  product_id NUMBER REFERENCES products(product_id),
  quantity NUMBER
);


INSERT INTO customers VALUES (1, 'Amina Yusuf', 'amina.yusuf@example.com', 'Riverton');
INSERT INTO customers VALUES (2, 'Brian Okoye', 'brian.okoye@example.com', 'Northfield');
INSERT INTO customers VALUES (3, 'Chloe Martin', 'chloe.martin@example.com', 'Riverton');
INSERT INTO customers VALUES (4, 'David Kim', 'david.kim@example.com', 'Lakeside');
INSERT INTO customers VALUES (5, 'Elena Rossi', 'elena.rossi@example.com', 'Northfield');
INSERT INTO customers VALUES (6, 'Farid Hassan', 'farid.hassan@example.com', 'Lakeside');

INSERT INTO products VALUES (101, 'Whole Milk 1L', 'Dairy', 1.50);
INSERT INTO products VALUES (102, 'Cheddar Cheese 200g', 'Dairy', 3.20);
INSERT INTO products VALUES (103, 'Sourdough Loaf', 'Bakery', 2.80);
INSERT INTO products VALUES (104, 'Croissant 4-Pack', 'Bakery', 3.50);
INSERT INTO products VALUES (105, 'Orange Juice 1L', 'Beverages', 2.40);
INSERT INTO products VALUES (106, 'Sparkling Water 6-Pack', 'Beverages', 4.10);
INSERT INTO products VALUES (107, 'Ground Coffee 250g', 'Beverages', 6.75);
INSERT INTO products VALUES (108, 'Greek Yogurt 500g', 'Dairy', 2.95);

INSERT INTO orders VALUES (1001, 1, TO_DATE('2026-07-03', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1002, 2, TO_DATE('2026-07-10', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1003, 1, TO_DATE('2026-07-18', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1004, 3, TO_DATE('2026-07-25', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1005, 4, TO_DATE('2026-08-02', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1006, 2, TO_DATE('2026-08-09', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1007, 5, TO_DATE('2026-08-14', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1008, 1, TO_DATE('2026-08-21', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1009, 3, TO_DATE('2026-08-28', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1010, 4, TO_DATE('2026-09-01', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1011, 1, TO_DATE('2026-09-05', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1012, 5, TO_DATE('2026-09-09', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1013, 2, TO_DATE('2026-09-12', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1014, 3, TO_DATE('2026-09-15', 'YYYY-MM-DD'));
INSERT INTO orders VALUES (1015, 4, TO_DATE('2026-09-18', 'YYYY-MM-DD'));

INSERT INTO order_items VALUES (1, 1001, 101, 2);
INSERT INTO order_items VALUES (2, 1001, 103, 1);
INSERT INTO order_items VALUES (3, 1002, 107, 1);
INSERT INTO order_items VALUES (4, 1002, 104, 2);
INSERT INTO order_items VALUES (5, 1003, 105, 3);
INSERT INTO order_items VALUES (6, 1004, 102, 1);
INSERT INTO order_items VALUES (7, 1004, 106, 2);
INSERT INTO order_items VALUES (8, 1005, 101, 4);
INSERT INTO order_items VALUES (9, 1005, 103, 2);
INSERT INTO order_items VALUES (10, 1006, 107, 2);
INSERT INTO order_items VALUES (11, 1007, 104, 1);
INSERT INTO order_items VALUES (12, 1007, 105, 2);
INSERT INTO order_items VALUES (13, 1008, 106, 1);
INSERT INTO order_items VALUES (14, 1008, 102, 2);
INSERT INTO order_items VALUES (15, 1009, 103, 3);
INSERT INTO order_items VALUES (16, 1010, 107, 1);
INSERT INTO order_items VALUES (17, 1010, 101, 2);
INSERT INTO order_items VALUES (18, 1011, 105, 2);
INSERT INTO order_items VALUES (19, 1011, 104, 1);
INSERT INTO order_items VALUES (20, 1011, 106, 1);
INSERT INTO order_items VALUES (21, 1012, 103, 1);
INSERT INTO order_items VALUES (22, 1012, 102, 1);
INSERT INTO order_items VALUES (23, 1013, 101, 3);
INSERT INTO order_items VALUES (24, 1013, 106, 2);
INSERT INTO order_items VALUES (25, 1014, 107, 1);
INSERT INTO order_items VALUES (26, 1014, 105, 1);
INSERT INTO order_items VALUES (27, 1015, 104, 3);

COMMIT;
