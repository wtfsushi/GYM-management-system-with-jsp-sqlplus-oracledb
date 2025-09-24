-- Update USERS.ROLE check constraint to allow 'user'.
-- This version avoids using SEARCH_CONDITION (LONG) by joining USER_CONS_COLUMNS.

SET SERVEROUTPUT ON

DECLARE
BEGIN
  FOR c IN (
    SELECT uc.constraint_name
      FROM user_constraints uc
      JOIN user_cons_columns ucc
        ON uc.constraint_name = ucc.constraint_name
     WHERE uc.table_name = 'USERS'
       AND uc.constraint_type = 'C'
       AND ucc.column_name = 'ROLE'
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'ALTER TABLE users DROP CONSTRAINT ' || c.constraint_name;
      dbms_output.put_line('Dropped check constraint: ' || c.constraint_name);
    EXCEPTION WHEN OTHERS THEN
      dbms_output.put_line('Skip '||c.constraint_name||' -> '||SQLERRM);
    END;
  END LOOP;
END;
/

ALTER TABLE users ADD CONSTRAINT ck_users_role
  CHECK (LOWER(role) IN ('admin','trainer','member','user'));

SHOW ERRORS
