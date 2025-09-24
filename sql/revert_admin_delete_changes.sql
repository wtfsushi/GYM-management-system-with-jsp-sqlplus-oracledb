SET SERVEROUTPUT ON

-- Drop users delete audit trigger if it exists
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER trg_users_delete_audit';
  dbms_output.put_line('Dropped TRG_USERS_DELETE_AUDIT');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -4080 THEN dbms_output.put_line('TRG_USERS_DELETE_AUDIT not found');
  ELSE dbms_output.put_line('Skip TRG_USERS_DELETE_AUDIT: '||SQLERRM); END IF;
END;
/

-- Drop audit log before-insert trigger if it exists
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_log_bi';
  dbms_output.put_line('Dropped TRG_AUDIT_LOG_BI');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -4080 THEN dbms_output.put_line('TRG_AUDIT_LOG_BI not found');
  ELSE dbms_output.put_line('Skip TRG_AUDIT_LOG_BI: '||SQLERRM); END IF;
END;
/

-- Drop audit_log_seq if present
DECLARE v_cnt NUMBER; BEGIN
  SELECT COUNT(*) INTO v_cnt FROM user_sequences WHERE sequence_name='AUDIT_LOG_SEQ';
  IF v_cnt>0 THEN EXECUTE IMMEDIATE 'DROP SEQUENCE audit_log_seq'; dbms_output.put_line('Dropped AUDIT_LOG_SEQ');
  ELSE dbms_output.put_line('AUDIT_LOG_SEQ not found'); END IF;
END;
/

PROMPT Revert complete.
