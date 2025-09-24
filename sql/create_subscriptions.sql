-- Create SUBSCRIPTIONS table to track member plan purchases
-- Price is derived client/server side as 2000 per month, but we store the amount paid.

-- Table
CREATE TABLE subscriptions (
  subscription_id NUMBER PRIMARY KEY,
  user_id         NUMBER NOT NULL,
  start_date      DATE   NOT NULL,
  end_date        DATE   NOT NULL,
  months          NUMBER NOT NULL,
  amount          NUMBER(12,2) NOT NULL,
  CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Sequence
CREATE SEQUENCE subscriptions_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Simple audit log table per requirement (name per user text: subscribi_auditlog)
CREATE TABLE subscribi_auditlog (
  audit_id        NUMBER PRIMARY KEY,
  subscription_id NUMBER,
  user_id         NUMBER,
  months          NUMBER,
  amount          NUMBER(12,2),
  action          VARCHAR2(30),
  action_date     DATE DEFAULT SYSDATE
);

CREATE SEQUENCE subscribi_auditlog_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Trigger to log on insert into subscriptions
CREATE OR REPLACE TRIGGER trg_subscriptions_audit
AFTER INSERT ON subscriptions
FOR EACH ROW
BEGIN
  INSERT INTO subscribi_auditlog (
    audit_id, subscription_id, user_id, months, amount, action
  ) VALUES (
    subscribi_auditlog_seq.NEXTVAL, :NEW.subscription_id, :NEW.user_id, :NEW.months, :NEW.amount, 'INSERT'
  );
END;
/
SHOW ERRORS TRIGGER trg_subscriptions_audit;
