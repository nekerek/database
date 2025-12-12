-- Bonus Laboratory Work
-- Nursultan Yerbatyr

-- DATABASE
CREATE DATABASE bonus_task;

-- TABLES
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    status TEXT NOT NULL CHECK (status IN ('active','blocked','frozen')),
    created_at timestamptz DEFAULT now(),
    daily_limit_kzt NUMERIC(18,2) NOT NULL DEFAULT 1000000
);

CREATE TABLE accounts (
  account_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  account_number TEXT UNIQUE NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('KZT','USD','EUR','RUB')),
  balance NUMERIC(20,2) NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  opened_at timestamptz DEFAULT now(),
  closed_at timestamptz
);

CREATE TABLE transactions (
  transaction_id SERIAL PRIMARY KEY,
  from_account_id INT REFERENCES accounts(account_id),
  to_account_id INT REFERENCES accounts(account_id),
  amount NUMERIC(20,2) NOT NULL,
  currency CHAR(3) NOT NULL CHECK (currency IN ('KZT','USD','EUR','RUB')),
  exchange_rate NUMERIC(24,12),
  amount_kzt NUMERIC(20,2),
  type TEXT NOT NULL CHECK (type IN ('transfer','deposit','withdrawal','salary')),
  status TEXT NOT NULL CHECK (status IN ('pending','completed','failed','reversed')),
  created_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ,
  description TEXT
);


CREATE TABLE exchange_rates (
  rate_id SERIAL PRIMARY KEY,
  from_currency CHAR(3) NOT NULL CHECK (from_currency IN ('KZT','USD','EUR','RUB')),
  to_currency CHAR(3) NOT NULL CHECK (to_currency IN ('KZT','USD','EUR','RUB')),
  rate NUMERIC(24,12) NOT NULL,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_to TIMESTAMPTZ
);


CREATE TABLE audit_log (
  log_id SERIAL PRIMARY KEY,
  table_name TEXT,
  record_id TEXT,
  action TEXT NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  old_values JSONB,
  new_values JSONB,
  changed_by TEXT,
  changed_at TIMESTAMPTZ DEFAULT now(),
  ip_address TEXT
);


-- Customers
INSERT INTO customers(iin, full_name, phone, email, status, daily_limit_kzt) VALUES
('770101100111','Nurbekzat Nulybekuly','+7-775-0000001','nurbekzat@gmail.com','blocked',5000000),
('870202200222','Arman Norsultanov','+7-775-0000002','Arman@gmail.com','active',2000000),
('970303300333','Zhandos Bazargaliev','+7-775-0000003','zhandos@gmail.com','frozen',1000000),
('670404400444','Amanbek Anurabekuly','+7-775-0000004','amanbek@gmail.com','active',3000000),
('770505500555','Amangerey Amankossov','+7-775-0000005','amangerey@gmail.com','blocked',1000000),
('970606600666','Dimash Baizakov','+7-775-0000006','dimash@gmail.com','active',1500000),
('870707700777','Dorash Berik','+7-775-0000007','dorash@gmail.com','active',500000),
('770808800888','Kazybek Kydyrbai','+7-775-0000008','kazybek@gmail.com','active',10000000),
('070909900999','Yerbatyr Nursultan','+7-777-7777777','batyr@gmail.com','active',2000000),
('660606600666','Mukhammed Garifolla','+7-775-0000010','mukha@gmail.com','active',1200000);

-- Accounts
INSERT INTO accounts(customer_id, account_number, currency, balance, is_active) VALUES
(1,'KZ86125KZT00000000001','KZT',2000000,true),
(1,'KZ86125USD00000000002','USD',2000,true),
(2,'KZ86125KZT00000000003','KZT',500000,true),
(3,'KZ86125EUR00000000004','EUR',1000,true),
(4,'KZ86125KZT00000000005','KZT',100000,true),
(5,'KZ86125KZT00000000006','KZT',1000,false),
(6,'KZ86125USD00000000007','USD',500,true),
(7,'KZ86125KZT00000000008','KZT',250000,true),
(8,'KZ86125RUB00000000009','RUB',100000,true),
(9,'KZ86125KZT00000000010','KZT',900000000000000,true),
(10,'KZ86125EUR00000000011','EUR',300,true);


-- Transactions
INSERT INTO transactions(from_account_id,to_account_id,amount,currency,amount_kzt,type,status,completed_at,description) VALUES
(2,3,100.00,'USD',47000.00,'transfer','completed',now()-interval '10 day','USD tx'),
(1,8,50000.00,'KZT',50000.00,'transfer','completed',now()-interval '9 day','KZT tx'),
(NULL,1,200000.00,'KZT',200000.00,'deposit','completed',now()-interval '8 day','cash dep'),
(3,4,50.00,'EUR',25500.00,'transfer','completed',now()-interval '7 day','EUR tx'),
(7,9,15000.00,'KZT',15000.00,'transfer','completed',now()-interval '6 day','service pay'),
(11,12,30000.00,'KZT',30000.00,'transfer','completed',now()-interval '5 day','payroll'), -- REMOVE/UPDATE if 11/12 don't exist
(6,7,250.00,'USD',117500.00,'transfer','completed',now()-interval '4 day','USD transfer'),
(4,11,400.00,'EUR',204000.00,'transfer','completed',now()-interval '3 day','EUR transfer'), -- REMOVE/UPDATE if 11 doesn't exist
(9,2,100000.00,'KZT',100000.00,'transfer','completed',now()-interval '2 day','large KZT'),
(1,7,7500.00,'KZT',7500.00,'transfer','completed',now()-interval '36 hour','micro pay'),
(5,NULL,50000.00,'USD',23500000.00,'deposit','completed',now()-interval '1 hour','company dep');
-- exchange rates
INSERT INTO exchange_rates(from_currency, to_currency, rate, valid_from) VALUES
('USD','KZT',470.00, now()-interval '1 day'),
('EUR','KZT',510.00, now()-interval '1 day'),
('RUB','KZT',5.50, now()-interval '1 day'),
('KZT','KZT',1.0, now()-interval '10 years'),
('USD','EUR',0.92, now()-interval '2 day'),
('EUR','USD',1.08, now()-interval '2 day'),
('USD','RUB',93.0, now()-interval '3 day'),
('RUB','USD',0.011, now()-interval '3 day'),
('EUR','RUB',101.0, now()-interval '3 day'),
('RUB','EUR',0.0099, now()-interval '3 day');

-- TASK 1
DROP FUNCTION IF EXISTS process_transfer(TEXT, TEXT, NUMERIC, CHAR, TEXT);

CREATE OR REPLACE FUNCTION process_transfer(
  p_from_account_number TEXT,
  p_to_account_number TEXT,
  p_amount NUMERIC,
  p_currency CHAR(3),
  p_description TEXT
) RETURNS JSONB
LANGUAGE plpgsql AS $$
DECLARE
  v_from       accounts%ROWTYPE;
  v_to         accounts%ROWTYPE;
  v_sender     customers%ROWTYPE;
  v_rate       NUMERIC;
  v_amount_kzt NUMERIC;
  v_today_sum  NUMERIC := 0;
  v_sender_to_kzt NUMERIC;
  v_p_to_rate  NUMERIC;
  v_txid       BIGINT;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    INSERT INTO audit_log(table_name, action, new_values)
      VALUES ('process_transfer','ERROR', jsonb_build_object('code','INVALID_AMOUNT','amount', p_amount));
    RETURN jsonb_build_object('status','error','code','INVALID_AMOUNT','message','amount must be > 0');
  END IF;

  SAVEPOINT sp_transfer;

  /* find accounts (no lock yet) */
  SELECT * INTO v_from FROM accounts WHERE account_number = p_from_account_number;
  IF NOT FOUND THEN
    INSERT INTO audit_log(table_name, action, new_values)
      VALUES ('process_transfer','FAILED', jsonb_build_object('code','FROM_NOT_FOUND','from',p_from_account_number));
    ROLLBACK TO SAVEPOINT sp_transfer;
    RETURN jsonb_build_object('status','error','code','FROM_ACCOUNT_NOT_FOUND');
  END IF;

  SELECT * INTO v_to FROM accounts WHERE account_number = p_to_account_number;
  IF NOT FOUND THEN
    INSERT INTO audit_log(table_name, action, new_values)
      VALUES ('process_transfer','FAILED', jsonb_build_object('code','TO_NOT_FOUND','to',p_to_account_number));
    ROLLBACK TO SAVEPOINT sp_transfer;
    RETURN jsonb_build_object('status','error','code','TO_ACCOUNT_NOT_FOUND');
  END IF;

  /* lock rows deterministically to avoid deadlocks */
  IF v_from.account_id < v_to.account_id THEN
    SELECT * INTO v_from FROM accounts WHERE account_id = v_from.account_id FOR UPDATE;
    SELECT * INTO v_to   FROM accounts WHERE account_id = v_to.account_id   FOR UPDATE;
  ELSE
    SELECT * INTO v_to   FROM accounts WHERE account_id = v_to.account_id   FOR UPDATE;
    SELECT * INTO v_from FROM accounts WHERE account_id = v_from.account_id FOR UPDATE;
  END IF;

  /* sender status */
  SELECT * INTO v_sender FROM customers WHERE customer_id = v_from.customer_id;
  IF NOT FOUND OR v_sender.status <> 'active' THEN
    INSERT INTO audit_log(table_name, action, new_values)
      VALUES ('process_transfer','FAILED', jsonb_build_object('code','SENDER_NOT_ACTIVE','customer',COALESCE(v_sender.customer_id::text,'NULL'),'status',COALESCE(v_sender.status,'NULL')));
    ROLLBACK TO SAVEPOINT sp_transfer;
    RETURN jsonb_build_object('status','error','code','SENDER_NOT_ACTIVE');
  END IF;

  /* today's completed outgoing in KZT */
  SELECT COALESCE(SUM(amount_kzt),0) INTO v_today_sum
    FROM transactions
    WHERE from_account_id = v_from.account_id
      AND created_at >= date_trunc('day', now())
      AND status = 'completed';

  /* find direct rate p_currency -> KZT */
  SELECT rate INTO v_rate
    FROM exchange_rates
    WHERE from_currency = p_currency AND to_currency = 'KZT'
    ORDER BY valid_from DESC
    LIMIT 1;

  IF v_rate IS NULL THEN
    INSERT INTO audit_log(table_name, action, new_values)
      VALUES ('process_transfer','FAILED', jsonb_build_object('code','NO_RATE','currency',p_currency));
    ROLLBACK TO SAVEPOINT sp_transfer;
    RETURN jsonb_build_object('status','error','code','NO_EXCHANGE_RATE');
  END IF;

  v_amount_kzt := round(p_amount * v_rate, 2);

  IF (v_today_sum + v_amount_kzt) > v_sender.daily_limit_kzt THEN
    INSERT INTO audit_log(table_name, action, new_values)
      VALUES ('process_transfer','FAILED', jsonb_build_object('code','DAILY_LIMIT_EXCEEDED','today_sum',v_today_sum,'limit',v_sender.daily_limit_kzt));
    ROLLBACK TO SAVEPOINT sp_transfer;
    RETURN jsonb_build_object('status','error','code','DAILY_LIMIT_EXCEEDED','today_sum',v_today_sum,'limit',v_sender.daily_limit_kzt);
  END IF;

  /* check and debit sender */
  IF v_from.currency = p_currency THEN
    IF v_from.balance < p_amount THEN
      INSERT INTO audit_log(table_name, action, new_values)
        VALUES ('process_transfer','FAILED', jsonb_build_object('code','INSUFFICIENT_FUNDS','account',v_from.account_id,'balance',v_from.balance));
      ROLLBACK TO SAVEPOINT sp_transfer;
      RETURN jsonb_build_object('status','error','code','INSUFFICIENT_FUNDS');
    END IF;

    UPDATE accounts SET balance = balance - p_amount WHERE account_id = v_from.account_id;
  ELSE
    /* convert p_amount (p_currency) -> KZT (v_amount_kzt) and then KZT -> sender.currency */
    SELECT rate INTO v_sender_to_kzt
      FROM exchange_rates
      WHERE from_currency = v_from.currency AND to_currency = 'KZT'
      ORDER BY valid_from DESC LIMIT 1;

    IF v_sender_to_kzt IS NULL THEN
      INSERT INTO audit_log(table_name, action, new_values)
        VALUES ('process_transfer','FAILED', jsonb_build_object('code','NO_RATE_FOR_SENDER','currency',v_from.currency));
      ROLLBACK TO SAVEPOINT sp_transfer;
      RETURN jsonb_build_object('status','error','code','NO_RATE_FOR_SENDER_CURRENCY');
    END IF;

    /* debit = v_amount_kzt / (sender_currency -> KZT rate) */
    UPDATE accounts SET balance = balance - round(v_amount_kzt / v_sender_to_kzt,2)
      WHERE account_id = v_from.account_id;
  END IF;

  /* credit recipient */
  IF v_to.currency = p_currency THEN
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = v_to.account_id;
  ELSE
    SELECT rate INTO v_p_to_rate
      FROM exchange_rates
      WHERE from_currency = p_currency AND to_currency = v_to.currency
      ORDER BY valid_from DESC LIMIT 1;

    IF v_p_to_rate IS NOT NULL THEN
      UPDATE accounts SET balance = balance + round(p_amount * v_p_to_rate,2) WHERE account_id = v_to.account_id;
    ELSE
      /* fallback via KZT: recipient_currency -> KZT rate must exist */
      SELECT rate INTO v_p_to_rate
        FROM exchange_rates
        WHERE from_currency = v_to.currency AND to_currency = 'KZT'
        ORDER BY valid_from DESC LIMIT 1;

      IF v_p_to_rate IS NULL THEN
        INSERT INTO audit_log(table_name, action, new_values)
          VALUES ('process_transfer','FAILED', jsonb_build_object('code','NO_RATE_FOR_RECIPIENT','currency',v_to.currency));
        ROLLBACK TO SAVEPOINT sp_transfer;
        RETURN jsonb_build_object('status','error','code','NO_RATE_FOR_RECIPIENT_CURRENCY');
      END IF;

      UPDATE accounts SET balance = balance + round(v_amount_kzt / v_p_to_rate,2) WHERE account_id = v_to.account_id;
    END IF;
  END IF;

  /* insert transaction */
  INSERT INTO transactions(from_account_id,to_account_id,amount,currency,exchange_rate,amount_kzt,type,status,completed_at,description)
    VALUES (v_from.account_id, v_to.account_id, p_amount, p_currency, v_rate, v_amount_kzt, 'transfer','completed', now(), p_description)
    RETURNING transaction_id INTO v_txid;

  /* audit success */
  INSERT INTO audit_log(table_name, action, new_values)
    VALUES ('transactions','INSERT', (SELECT to_jsonb(t) FROM transactions t WHERE t.transaction_id = v_txid));

  RETURN jsonb_build_object('status','ok','transaction_id', v_txid, 'amount_kzt', v_amount_kzt);

EXCEPTION WHEN OTHERS THEN
  INSERT INTO audit_log(table_name, action, new_values)
    VALUES ('process_transfer','ERROR', jsonb_build_object('error', SQLERRM));
  ROLLBACK TO SAVEPOINT sp_transfer;
  RETURN jsonb_build_object('status','error','code','INTERNAL_ERROR','message', SQLERRM);
END;
$$;


-- TASK 2

-- View  customer_balance_summary
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH acct_kzt AS (
  SELECT a.account_id, a.customer_id, a.account_number, a.currency, a.balance,
    CASE WHEN a.currency = 'KZT' THEN a.balance
         ELSE round(a.balance * (SELECT rate FROM exchange_rates er WHERE er.from_currency = a.currency AND er.to_currency = 'KZT' ORDER BY valid_from DESC LIMIT 1),2)
    END AS balance_kzt
  FROM accounts a
)
SELECT
  c.customer_id,
  c.iin,
  c.full_name,
  array_agg(jsonb_build_object('account_id',ak.account_id,'account_number',ak.account_number,'currency',ak.currency,'balance',ak.balance) ORDER BY ak.account_id) AS accounts,
  COALESCE(SUM(ak.balance_kzt),0) AS total_balance_kzt,
  ROUND( (COALESCE(SUM(ak.balance_kzt),0) / NULLIF(c.daily_limit_kzt,0)) * 100,2) AS daily_limit_util_pct,
  RANK() OVER (ORDER BY COALESCE(SUM(ak.balance_kzt),0) DESC) AS balance_rank
FROM customers c
LEFT JOIN acct_kzt ak ON ak.customer_id = c.customer_id
GROUP BY c.customer_id, c.iin, c.full_name, c.daily_limit_kzt;

-- View 2 daily_transaction_report
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH tx AS (
  SELECT date_trunc('day', created_at) AS day, type, SUM(amount_kzt) AS total_kzt, COUNT(*) AS cnt, AVG(amount_kzt) AS avg_kzt
  FROM transactions
  GROUP BY 1,2
)
SELECT
  day, type, total_kzt, cnt, avg_kzt,
  SUM(total_kzt) OVER (PARTITION BY type ORDER BY day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_kzt,
  LAG(total_kzt) OVER (PARTITION BY type ORDER BY day) AS prev_day_total_kzt,
  CASE WHEN LAG(total_kzt) OVER (PARTITION BY type ORDER BY day) IS NULL THEN NULL
       ELSE round( (total_kzt - LAG(total_kzt) OVER (PARTITION BY type ORDER BY day)) / NULLIF(LAG(total_kzt) OVER (PARTITION BY type ORDER BY day),0) * 100,2) END AS day_over_day_pct
FROM tx;

-- View 3 suspicious_activity_view (security barrier)
CREATE OR REPLACE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH tx_kzt AS (
  SELECT t.*, COALESCE(t.amount_kzt, t.amount * (SELECT rate FROM exchange_rates er WHERE er.from_currency = t.currency AND er.to_currency = 'KZT' ORDER BY valid_from DESC LIMIT 1)) AS amount_kzt_calc
  FROM transactions t
),
large_tx AS (
  SELECT * FROM tx_kzt WHERE amount_kzt_calc > 5000000
),
freq_per_hour AS (
  SELECT from_account_id, date_trunc('hour', created_at) AS hr, COUNT(*) AS cnt
  FROM transactions
  WHERE from_account_id IS NOT NULL
  GROUP BY 1,2
  HAVING COUNT(*) > 10
),
rapid_seq AS (
  SELECT t1.* FROM transactions t1
  JOIN transactions t2 ON t1.from_account_id = t2.from_account_id
    AND t1.created_at > t2.created_at
    AND (t1.created_at - t2.created_at) < interval '1 minute'
)
SELECT 'large_tx' AS reason, l.* FROM large_tx l
UNION ALL
SELECT 'frequent' AS reason, t.* FROM transactions t JOIN freq_per_hour f ON t.from_account_id = f.from_account_id
UNION ALL
SELECT 'rapid' AS reason, r.* FROM rapid_seq r;

-- TASK 3:
-- B-tree: account_number lookup
CREATE INDEX IF NOT EXISTS idx_accounts_account_number ON accounts(account_number);

-- Composite B-tree: transactions by from_account + created_at
CREATE INDEX IF NOT EXISTS idx_tx_from_created ON transactions(from_account_id, created_at DESC);

-- Hash: exact lookup on iin (equality)
CREATE INDEX IF NOT EXISTS idx_customers_iin_hash ON customers USING HASH (iin);

-- GIN: JSONB on audit_log (fast searches)
CREATE INDEX IF NOT EXISTS idx_audit_new_values_gin ON audit_log USING GIN (new_values);

-- Partial index: active accounts only (saves space and speeds active-only queries)
CREATE INDEX IF NOT EXISTS idx_accounts_active_partial ON accounts(account_id) WHERE is_active = true;

-- Expression index: case-insensitive email search
CREATE INDEX IF NOT EXISTS idx_customers_email_ci ON customers(lower(email));

-- Covering index (include created_at) for frequent reporting queries
CREATE INDEX IF NOT EXISTS idx_tx_to_status_amount_kzt ON transactions(to_account_id, status, amount_kzt) INCLUDE (created_at);


EXPLAIN (ANALYZE, BUFFERS, VERBOSE) SELECT * FROM accounts WHERE account_number = 'KZ86125KZT00000000001';
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) SELECT * FROM transactions WHERE from_account_id = 1 ORDER BY created_at DESC LIMIT 50;

-- TASK 4: process_salary_batch
CREATE OR REPLACE FUNCTION process_salary_batch(
  p_company_account_number TEXT,
  p_payments JSONB
) RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
  v_company accounts%ROWTYPE;
  v_lock_key BIGINT;
  i INT;
  v_item JSONB;
  v_total NUMERIC := 0;
  v_failed JSONB := '[]'::jsonb;
  v_success INT := 0;
  v_failed_cnt INT := 0;
  v_inserted INT := 0;
BEGIN
  -- locate company account
  SELECT * INTO v_company FROM accounts WHERE account_number = p_company_account_number;
  IF NOT FOUND THEN
    INSERT INTO audit_log(table_name, action, new_values) VALUES ('process_salary_batch','FAILED', jsonb_build_object('code','COMPANY_NOT_FOUND','company',p_company_account_number));
    RETURN jsonb_build_object('status','error','code','COMPANY_NOT_FOUND');
  END IF;

  v_lock_key := v_company.account_id;
  PERFORM pg_advisory_lock(v_lock_key);

  BEGIN
    -- compute total required
    FOR i IN 0 .. jsonb_array_length(p_payments)-1 LOOP
      v_item := p_payments->i;
      IF NOT (v_item ? 'iin' AND v_item ? 'amount') THEN
        v_failed := v_failed || jsonb_build_object('index', i, 'reason', 'invalid_structure', 'value', v_item);
        v_failed_cnt := v_failed_cnt + 1;
        CONTINUE;
      END IF;
      v_total := v_total + (v_item->>'amount')::numeric;
    END LOOP;

    -- validate company balance
    SELECT * INTO v_company FROM accounts WHERE account_id = v_company.account_id FOR UPDATE;
    IF v_company.balance < v_total THEN
      PERFORM pg_advisory_unlock(v_lock_key);
      INSERT INTO audit_log(table_name, action, new_values) VALUES ('process_salary_batch','FAILED', jsonb_build_object('code','INSUFFICIENT_FUNDS','available',v_company.balance,'required',v_total));
      RETURN jsonb_build_object('status','error','code','INSUFFICIENT_COMPANY_FUNDS','available', v_company.balance, 'required', v_total);
    END IF;

    CREATE TEMP TABLE tmp_salary (iin CHAR(12), amount NUMERIC, description TEXT, recipient_account_id INT, amount_kzt NUMERIC) ON COMMIT DROP;

    FOR i IN 0 .. jsonb_array_length(p_payments)-1 LOOP
      v_item := p_payments->i;
      -- SAVEPOINT to continue after failures
      SAVEPOINT sp_item;
      BEGIN
        IF NOT (v_item ? 'iin' AND v_item ? 'amount') THEN
          v_failed := v_failed || jsonb_build_object('index', i, 'reason', 'invalid_structure');
          v_failed_cnt := v_failed_cnt + 1;
          ROLLBACK TO SAVEPOINT sp_item;
          CONTINUE;
        END IF;

        -- find recipient active account
        INSERT INTO tmp_salary(iin, amount, description, recipient_account_id, amount_kzt)
        SELECT (v_item->>'iin')::char(12), (v_item->>'amount')::numeric, v_item->>'description',
               a.account_id,
               round((v_item->>'amount')::numeric * (SELECT rate FROM exchange_rates er WHERE er.from_currency = a.currency AND er.to_currency = 'KZT' ORDER BY valid_from DESC LIMIT 1),2)
        FROM customers c JOIN accounts a ON a.customer_id = c.customer_id
        WHERE c.iin = (v_item->>'iin')::char(12) AND a.is_active = true
        ORDER BY a.account_id LIMIT 1;

        IF NOT FOUND THEN
          v_failed := v_failed || jsonb_build_object('index', i, 'iin', v_item->>'iin', 'reason', 'recipient_not_found');
          v_failed_cnt := v_failed_cnt + 1;
          ROLLBACK TO SAVEPOINT sp_item;
          CONTINUE;
        END IF;

        -- success for this item
        v_success := v_success + 1;
        RELEASE SAVEPOINT sp_item;
      EXCEPTION WHEN OTHERS THEN
        v_failed := v_failed || jsonb_build_object('index', i, 'reason', SQLERRM);
        v_failed_cnt := v_failed_cnt + 1;
        ROLLBACK TO SAVEPOINT sp_item;
      END;
    END LOOP;

    -- subtract total and credit recipients grouped
    UPDATE accounts SET balance = balance - (SELECT COALESCE(SUM(amount),0) FROM tmp_salary) WHERE account_id = v_company.account_id;

    WITH credits AS (
      SELECT recipient_account_id AS account_id, SUM(amount) AS credit_amount FROM tmp_salary GROUP BY recipient_account_id
    )
    UPDATE accounts a SET balance = a.balance + c.credit_amount FROM credits c WHERE a.account_id = c.account_id;

    -- insert transactions
    INSERT INTO transactions(from_account_id,to_account_id,amount,currency,amount_kzt,type,status,completed_at,description)
    SELECT v_company.account_id, recipient_account_id, amount, v_company.currency, amount_kzt, 'salary','completed', now(), description
    FROM tmp_salary;

    GET DIAGNOSTICS v_inserted = ROW_COUNT;

    -- audit and return
    INSERT INTO audit_log(table_name, action, new_values) VALUES ('process_salary_batch','COMMITTED', jsonb_build_object('company', p_company_account_number, 'total', v_total, 'successful', v_success, 'failed', v_failed_cnt));
    PERFORM pg_advisory_unlock(v_lock_key);

    RETURN jsonb_build_object('status','ok','successful_count', v_success, 'failed_count', v_failed_cnt, 'failed_details', v_failed);
  EXCEPTION WHEN OTHERS THEN
    PERFORM pg_advisory_unlock(v_lock_key);
    INSERT INTO audit_log(table_name, action, new_values) VALUES ('process_salary_batch','ERROR', jsonb_build_object('err', SQLERRM));
    RETURN jsonb_build_object('status','error','code','BATCH_INTERNAL_ERROR','message',SQLERRM);
  END;
END;
$$;

-- Materialized view salary summary
CREATE MATERIALIZED VIEW mv_salary_summary AS
SELECT date_trunc('day', completed_at) AS day, COUNT(*) AS total_count, SUM(amount_kzt) AS total_kzt
FROM transactions WHERE type = 'salary' AND status = 'completed' GROUP BY 1;



1) Successful transfer (same currency)
SELECT process_transfer('KZ86125KZT00000000001','KZ86125KZT00000000008', 10000, 'KZT', 'Test payment');

2) Transfer with currency conversion (USD -> KZT)
SELECT process_transfer('KZ86125USD00000000002','KZ86125KZT00000000003', 50, 'USD', 'USD -> KZT');

3) Daily limit exceeded (craft test by multiple transfers)
(run multiple transfers until exceed)

4) Salary batch
SELECT process_salary_batch('KZ86125KZT00000000001',
 '[{"iin":"870202200222","amount":100000,"description":"Salary Jan"},{"iin":"700808800888","amount":120000,"description":"Salary Jan"}]'::jsonb);

5) Views
SELECT * FROM customer_balance_summary ORDER BY total_balance_kzt DESC LIMIT 10;
SELECT * FROM daily_transaction_report ORDER BY day DESC LIMIT 10;
SELECT * FROM suspicious_activity_view LIMIT 20;

6) Index EXPLAIN (run locally and capture output)
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM accounts WHERE account_number = 'KZ86125KZT00000000001';
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM transactions WHERE from_account_id = 1 ORDER BY created_at DESC LIMIT 50;

