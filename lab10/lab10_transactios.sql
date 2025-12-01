CREATE DATABASE LAB10
    WITH OWNER = postgres;



CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
                                                ('Joe''s Shop', 'Coke', 2.50),
                                                ('Joe''s Shop', 'Pepsi', 3.00);


-- Task 1: Basic Transaction with COMMIT
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
COMMIT;

SELECT name, balance FROM accounts WHERE name IN ('Alice','Bob');

/*
a)Alice: 900.00, Bob: 600.00.
b)atomicity — both updates succeed together or not at all.
c)Without a transaction, partial update could persist leaving inconsistent state
*/

-- Task 2: Using ROLLBACK
BEGIN;
UPDATE accounts SET balance = balance - 500.00
    WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';

ROLLBACK;

SELECT * FROM accounts WHERE name = 'Alice';

/*
a)After UPDATE before ROLLBACK you see decreased balance in this session
b)After ROLLBACK balance returns to original
c)Use ROLLBACK when an error occurs or validation fails
*/

-- Task 3: Working with SAVEPOINTs
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';

ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally'

COMMIT;

/*
a)Alice: decreased by 100 Bob: unchanged Wally: increased by 100
b) Bob was not credited in final state because we rolled back the step that credited Bob before commit.
c) SAVEPOINT allows partial undo inside a long transaction without aborting everything.
*/

-- Task 4: Isolation Level Demonstration
-- Terminal 1:
 BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to make changes and COMMIT-- Then re-run:
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;
--  Terminal 2 (while Terminal 1 is still running):
 BEGIN;
 DELETE FROM products WHERE shop = 'Joe''s Shop';
 INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
 COMMIT;

/*
a)T1 first read shows original rows; after T2 commits T1’s second read sees the changes
b)In SERIALIZABLE, T1 should not see changes made by T2; depending on actions, T2 commit may succeed but T1 might get a serialization error on COMMIT if a true conflict exists.
c)READ COMMITTED shows committed changes made after the transaction started; SERIALIZABLE prevents non-serializable interleavings—either you don’t see changes or a conflict produces error to maintain serializability.
*/


-- Task 5: Phantom Read Demonstration

--  Terminal 1:
 BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
 SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2
 SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
 COMMIT;
--  Terminal 2:
 BEGIN;
 INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Sprite', 4.00);
 COMMIT;



/*
a)T1 under REPEATABLE READ will not see the new row inserted
b)A phantom read is when a transaction re-executes a query and sees new rows
c)SERIALIZABLE prevents phantom reads; REPEATABLE READ in PostgreSQL  prevents non-repeatable reads
*/


-- Task 6: Dirty Read Demonstration
--  Terminal 1:
 BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to UPDATE but NOT commit
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to ROLLBACK
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;
--  Terminal 2:
 BEGIN;
 UPDATE products SET price = 99.99
    WHERE product = 'Fanta';-- Wait here (don't commit yet)-- Then:
 ROLLBACK;


/*
a)In DBs that allow dirty reads, T1 would see 99.99 in read 2 even though T2 rolled back — problematic because T1 saw uncommitted (and later aborted) data. PostgreSQL doesn't allow this; READ UNCOMMITTED behaves like READ COMMITTED.
b)Dirty read = reading data written by another transaction that hasn't committed.
c) it can produce inconsistent/invalid results.
*/

-- 4. Independent Exercises
-- Exercise 1
BEGIN;
SELECT id, balance FROM accounts WHERE name IN ('Bob','Wally') FOR UPDATE;
DO $$
DECLARE
  bob_bal NUMERIC;
BEGIN
  SELECT balance INTO bob_bal FROM accounts WHERE name = 'Bob';
  IF bob_bal < 200 THEN
    RAISE NOTICE 'Insufficient funds';
    ROLLBACK;
    RETURN;
  END IF;
  UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob';
  UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';
END;
$$ LANGUAGE plpgsql;
COMMIT;




--  Exercise 2
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('TestShop','TempProduct',10.00);
SAVEPOINT sp1;
UPDATE products SET price = 12.00 WHERE shop='TestShop' AND product='TempProduct';
SAVEPOINT sp2;
DELETE FROM products WHERE shop='TestShop' AND product='TempProduct';

ROLLBACK TO sp1;
COMMIT;

SELECT * FROM products WHERE shop='TestShop';

--  Exercise 3
--A
BEGIN;
SELECT balance FROM accounts WHERE name='Alice'; -- suppose 1000
UPDATE accounts SET balance = balance - 900 WHERE name='Alice';
-- wait
COMMIT;

--B
BEGIN;
SELECT balance FROM accounts WHERE name='Alice';
UPDATE accounts SET balance = balance - 200 WHERE name='Alice';
COMMIT;

/*
With READ COMMITTED: updates use row locks; second session will block until first commits;
depending on order you can avoid overdraft if you SELECT FOR UPDATE and re-check.
With SERIALIZABLE: one transaction may get a serialization error and must retry.
*/


--  Exercise 4
--SALLY
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT MAX(price)
FROM Sells
WHERE shop = 'Joe''s Shop';

SELECT MIN(price)
FROM Sells
WHERE shop = 'Joe''s Shop';

COMMIT;


--JOE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DELETE FROM Sells
WHERE shop = 'Joe''s Shop';

INSERT INTO Sells VALUES
('Joe''s Shop', 'Fanta', 3.50);

COMMIT;


--  5. Questions for Self-Assessment
/*
ACID:
Atomicity — all-or-nothing (transfer money both debit & credit).
Consistency — DB remains valid after transaction (constraints hold).
Isolation — concurrent transactions don't interfere (appear serial).
Durability — committed changes survive crashes.

COMMIT vs ROLLBACK:
COMMIT: makes changes permanent; ROLLBACK: undo since transaction start (or to savepoint).

When to use SAVEPOINT:
To partially undo steps inside a long transaction without aborting whole job.

Isolation levels (short):
READ UNCOMMITTED: can see uncommitted data (dirty reads) — PostgreSQL treats as READ COMMITTED.
READ COMMITTED: sees only committed data; repeating read may see new commits.
REPEATABLE READ: repeated reads are consistent (no non-repeatable reads).
SERIALIZABLE: strictest — transactions execute as if serial.

Dirty read: reading uncommitted change from another transaction.
Non-repeatable read: reading same row twice yields different values (another committed transaction updated it).
Phantom read: re-running a query returns new rows inserted by another transaction.
What happens on crash? Uncommitted changes are lost (rolled back). Committed changes are durable.
  */



-- Conclusion

-- In this lab, I learned how SQL transactions ensure reliable and consistent database operations, especially in multi-user environments.
-- By practicing COMMIT, ROLLBACK, SAVEPOINT, and different isolation levels,
-- I saw how problems like dirty reads, non-repeatable reads, and phantom reads occur when transactions are not used.

